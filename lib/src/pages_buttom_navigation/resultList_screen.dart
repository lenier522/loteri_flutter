import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:lotengo/src/model/resultado.dart';

class ResultListScreen extends StatefulWidget {
  @override
  _ResultListScreenState createState() => _ResultListScreenState();
}

class _ResultListScreenState extends State<ResultListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Resultado> resultados = [];
  bool isLoading = true;
  String fechaMostrada = '';
  DateTime? fechaActual;
  //String userName = '';
  Timer? _refreshTimer;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  //_loadUserName();
  fechaActual = DateTime.now(); // Establece la fecha inicial aquí
  _fetchResultados(fechaActual);
  _refreshTimer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
    if (mounted && !isLoading) {  // Verifica si el widget está montado
      _fetchResultados(fechaActual);
    }
  });
}


  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /* Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Usuario';
    });
  } */

Future<void> _fetchResultados(DateTime? date) async {
  if (date == null) return;

  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  final uri = Uri.parse(
    'https://api.perf3ctsolutions.com/api/resultados?fecha=$formattedDate',
  );

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Resultado> fetchedResultados =
          jsonResponse.map((result) => Resultado.fromJson(result)).toList();

      if (fetchedResultados.isNotEmpty) {
        // Agrupar por sesión y obtener la fecha más reciente de cada sesión
        DateTime fechaDia = fetchedResultados
            .where((r) => r.session.toLowerCase() == 'día')
            .map((r) => DateTime.parse(r.fecha))
            .reduce((a, b) => a.isAfter(b) ? a : b);

        DateTime fechaNoche = fetchedResultados
            .where((r) => r.session.toLowerCase() == 'noche')
            .map((r) => DateTime.parse(r.fecha))
            .reduce((a, b) => a.isAfter(b) ? a : b);

        if (mounted) { // Verifica si el widget sigue montado
          setState(() {
            // Filtrar resultados por la fecha más reciente de cada sesión
            resultados = fetchedResultados
                .where((r) =>
                    (r.session.toLowerCase() == 'día' &&
                        DateTime.parse(r.fecha).isAtSameMomentAs(fechaDia)) ||
                    (r.session.toLowerCase() == 'noche' &&
                        DateTime.parse(r.fecha).isAtSameMomentAs(fechaNoche)))
                .toList();
            fechaMostrada = _formatDate(fechaActual!.toIso8601String());
            isLoading = false;
          });
        }
      } else {
        if (mounted) { // Verifica si el widget sigue montado
          setState(() {
            resultados = [];
            fechaMostrada = '';
            isLoading = false;
          });
        }
      }
    } else {
      throw Exception('Fallo al cargar los resultados');
    }
  } catch (e) {
    print('Error al cargar los resultados: $e');
    if (mounted) { // Verifica si el widget sigue montado
      setState(() {
        isLoading = false;
      });
    }
  }
}


  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "Resultado Diario",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          //- Resultados - $fechaMostrada'),  esta es la opcion de mostrar la fecha
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.sunny),
                text: 'Pronóstico Día',
              ),
              Tab(
                icon: Icon(Icons.nightlight_round),
                text: 'Pronóstico Noche',
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : resultados.isEmpty
                ? const Center(child: Text('No hay resultados disponibles'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResultTab('Día'),
                      _buildResultTab('Noche'),
                    ],
                  ),
      ),
    );
  }

  Widget _buildResultTab(String session) {
    final filteredResults = resultados
        .where((r) => r.session.trim().toLowerCase() == session.trim().toLowerCase())
        .toList();

    if (filteredResults.isEmpty) {
      return Center(child: Text('No hay resultados para la sesión $session'));
    }

    String allFijos = filteredResults.map((r) => r.fijo).join(',');
    String allCorridos = filteredResults.map((r) => r.corrido).join(',');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Fijo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildNumberCircles(allFijos, isFijo: true),
          ),
          SizedBox(height: 20),
          Text(
            'Corridos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildNumberCircles(allCorridos),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNumberCircles(String numbers, {bool isFijo = false}) {
    List<String> numberList = numbers.split(',');
    return numberList.asMap().entries.map((entry) {
      int idx = entry.key;
      String number = entry.value.trim();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: isFijo && idx == 0 ? Colors.grey : Colors.blue,
          child: Text(
            number,
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      );
    }).toList();
  }
}

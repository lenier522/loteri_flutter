import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lotengo/src/utils/AppStoreClass.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

AppStore appStore = AppStore();

class _SearchScreenState extends State<SearchScreen> {
  final dateNow = DateTime.now();
  late bool isLoading = true;
  String fechaMostrada = ''; // Variable para almacenar la fecha seleccionada
  DateTime? fechaActual;
  late List<Resultado> resultadosDia = [];
  late List<Resultado> resultadosNoche = [];
  late List<Resultado> resultadosPorNumero = []; // Para resultados por número
  final TextEditingController _numberController = TextEditingController();

  Widget mHeading(var value) {
    return Text(value);
  }

  // Método para seleccionar la fecha y obtener los resultados
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: fechaActual ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != fechaActual) {
      if (mounted) {
        setState(() {
          fechaActual = selectedDate;
          fechaMostrada = DateFormat('dd/MM/yyyy').format(fechaActual!);
          isLoading =
              true; // Mostrar el indicador de carga mientras se obtienen los resultados
        });
      }

      // Llamar a fetchResultados con la fecha seleccionada
      await fetchResultados(fechaActual!);
    }
  }

  // Método para obtener los resultados desde la API
  Future<void> fetchResultados(DateTime fecha) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.perf3ctsolutions.com/api/resultados?fecha=${DateFormat('yyyy-MM-dd').format(fecha)}'),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        // Para depuración: imprimir los resultados completos en la consola
        print("Datos obtenidos de la API: $jsonResponse");

        // Formato de fecha para comparar con el campo 'fecha' de la API
        String fechaSeleccionada = DateFormat('yyyy-MM-dd').format(fecha);

        // Filtrar los resultados por fecha y luego separarlos por sesión
        List<Resultado> fetchedResultadosDia = jsonResponse
            .where((result) =>
                result['session'] == 'día' &&
                result['fecha'].substring(0, 10) == fechaSeleccionada)
            .map<Resultado>((result) => Resultado.fromJson(result))
            .toList();

        List<Resultado> fetchedResultadosNoche = jsonResponse
            .where((result) =>
                result['session'] == 'noche' &&
                result['fecha'].substring(0, 10) == fechaSeleccionada)
            .map<Resultado>((result) => Resultado.fromJson(result))
            .toList();
        if (mounted) {
          setState(() {
            resultadosDia = fetchedResultadosDia;
            resultadosNoche = fetchedResultadosNoche;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Error al cargar los resultados');
      }
    } catch (e) {
      print('Error al cargar los resultados: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Método para buscar números en la base de datos
  Future<void> searchByNumber(String number) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.perf3ctsolutions.com/api/resultados'),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        // Filtrar los resultados que contengan el número buscado
        List<Resultado> filteredResults = jsonResponse
            .where((result) =>
                result['fijo'].contains(number) ||
                result['corrido'].contains(number))
            .map<Resultado>((result) => Resultado.fromJson(result))
            .toList();
        if (mounted) {
          setState(() {
            resultadosPorNumero = filteredResults;
          });
        }
      } else {
        throw Exception('Error al cargar los resultados');
      }
    } catch (e) {
      print('Error al buscar números: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fechaMostrada = DateFormat('dd/MM/yyyy').format(dateNow);
    fechaActual = dateNow;
    fetchResultados(fechaActual!); // Cargar resultados al inicio
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "Buscar Resultados",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            bottom: tabBarMethod(),
          ),
          body: tabBarViewMethod(),
        ),
      ),
    );
  }

  TabBar tabBarMethod() {
    var icon1 = Icon(
      Icons.date_range_outlined,
      color: appStore.primaryColor,
    );
    var icon2 = Icon(
      Icons.numbers_outlined,
      color: appStore.primaryColor,
    );

    return TabBar(
      labelStyle: const TextStyle(fontSize: 16),
      indicatorColor: appStore.primaryColor,
      physics: const BouncingScrollPhysics(),
      labelColor: appStore.primaryColor,
      tabs: [
        tabsMethod("Por Fecha", icon1),
        tabsMethod("Por Número", icon2),
      ],
    );
  }

  TabBarView tabBarViewMethod() {
    return TabBarView(
      children: [
        container("Por Fecha"),
        containerPorNumero("Por Número"),
      ],
    );
  }

  Tab tabsMethod(String titulo, icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(
            width: 5,
          ),
          Text(
            titulo,
          ),
        ],
      ),
    );
  }

  // Contenido de la pestaña "Por Fecha"
  SingleChildScrollView container(String nombreContainer) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: const Color.fromARGB(255, 252, 252, 252),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Fecha: $fechaMostrada",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      )),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    alignment: Alignment.topRight,
                    color: Colors.red,
                    onPressed: () => _selectDate(
                        context), // Mostrar el calendario al tocar el ícono
                  ),
                ],
              ),
            ),
            isLoading
                ? CircularProgressIndicator() // Indicador de carga mientras se obtienen los datos
                : (resultadosDia.isEmpty && resultadosNoche.isEmpty)
                    ? Center(
                      child: Text(
                          "No hay resultados disponibles para la fecha seleccionada.",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                    )
                    : Column(
                        children: [
                          Text(
                            "Día",
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                          buildResultsSection(
                              resultadosDia, "Fijos", "Corridos"),
                          const SizedBox(height: 20),
                          Text(
                            "Noche",
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                          buildResultsSection(
                              resultadosNoche, "Fijos", "Corridos"),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget buildResultsSection(
      List<Resultado> resultados, String fijoLabel, String corridoLabel) {
    if (resultados.isEmpty) return SizedBox.shrink();

    // Obtener los números fijos y corridos por separado
    var fijos = resultados.map((resultado) => resultado.fijo).toList();
    var corridos = resultados.map((resultado) => resultado.corrido).toList();

    return Column(
      children: [
        Text(
          fijoLabel,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: fijos.asMap().entries.map((entry) {
            int index = entry.key;
            String number = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: buildNumberCircle(number, isFirst: index == 0),
            );
          }).toList(),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          corridoLabel,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: corridos.map((number) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: buildNumberCircle(number, isFirst: false),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildNumberCircle(String number, {required bool isFirst}) {
    Color circleColor = isFirst ? Colors.grey : Colors.blue;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Contenido de la pestaña "Por Número"
  SingleChildScrollView containerPorNumero(String nombreContainer) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: const Color.fromARGB(255, 252, 252, 252),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: "Ingrese el Número",
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLength: 2,
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                if (text.isNotEmpty) {
                  searchByNumber(text);
                } else {
                  setState(() {
                    resultadosPorNumero = [];
                  });
                }
              },
            ),
            const SizedBox(
              height: 15,
            ),
            tablaNumeros(),
          ],
        ),
      ),
    );
  }

  // Tabla de datos para la pestaña "Por Número"
  ListView tablaNumeros() {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato deseado

    return ListView(
      padding: EdgeInsets.all(16),
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        Text('Resultados Encontrados'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: <DataColumn>[
              DataColumn(label: mHeading('Fecha'), tooltip: 'Fecha'),
              DataColumn(label: mHeading('Fijo')),
              DataColumn(label: mHeading('Corridos')),
              DataColumn(label: mHeading('Sesión')),
            ],
            rows: resultadosPorNumero.map((resultado) {
              return DataRow(cells: [
                DataCell(Text(dateFormat.format(
                    DateTime.parse(resultado.fecha)))), // Formatear la fecha
                DataCell(Text(resultado.fijo)),
                DataCell(Text(resultado.corrido)),
                DataCell(Text(resultado.session)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class Resultado {
  String fijo;
  String corrido;
  String fecha; // Añadido para mostrar la fecha en la tabla
  String session; 

  Resultado({required this.fijo, required this.corrido, required this.fecha, required this.session});

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      fijo: json['fijo'].toString(),
      corrido: json['corrido'].toString(),
      fecha: json['fecha'].toString(), // Asegúrate de que la fecha esté disponible en el JSON
      session:json['session'].toString(),
    );
  }
}

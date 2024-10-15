import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lotengo/src/widgets/AppStructure/dashboard.dart';

class LatestResultsScreen extends StatefulWidget {
  @override
  _LatestResultsScreenState createState() => _LatestResultsScreenState();
}

class _LatestResultsScreenState extends State<LatestResultsScreen> {
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestResults();
  }

  // Método para obtener los últimos 10 resultados
  Future<void> _fetchLatestResults() async {
    final response = await http.get(
      Uri.parse('https://api.perf3ctsolutions.com/api/resultados/latest'),
    );

    if (response.statusCode == 200) {
      setState(() {
        results = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar resultados: ${response.body}')),
      );
    }
  }

  // Método para eliminar un resultado por ID
  Future<void> _deleteResult(int id) async {
    final response = await http.delete(
      Uri.parse('https://api.perf3ctsolutions.com/api/resultados/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resultado eliminado exitosamente')),
      );
      _fetchLatestResults(); // Volver a cargar los resultados después de eliminar uno
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar resultado: ${response.body}')),
      );
    }
  }

  // Función para formatear la fecha
  String formatDate(String fecha) {
    DateTime parsedDate = DateTime.parse(fecha);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Column(
          children: [
            Dashboard(),
            SizedBox(height: 45), // Ajusta el espacio superior si es necesario
            Expanded(
              // Solución para ocupar todo el espacio disponible
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                ),
                child: results.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];

                          // Formatear la fecha a dd/MM/yyyy
                          String formattedDate = formatDate(result['fecha']);

                          return ListTile(
                            title: Text(
                                'Fijos: ${result['fijo']} | Corridos: ${result['corrido']}'),
                            subtitle: Text(
                                'Sesión: ${result['session']} | Fecha: $formattedDate'), // Mostrar fecha formateada
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteResult(
                                    result['id']); // Eliminar resultado por ID
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

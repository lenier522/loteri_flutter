import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lotengo/src/widgets/AppStructure/dashboard.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _fijoController = TextEditingController();
  final TextEditingController _corridoController = TextEditingController();

  String _session = 'día';
  String _estado = 'completo';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false; // Indicador de carga

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> saveResult() async {
    if (_fijoController.text.isEmpty || _corridoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, complete todos los campos'),
      ));
      return;
    }

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    String fijo =
        "${_fijoController.text.substring(0, 1)},${_fijoController.text.substring(1, 3)}";
    String corrido =
        "${_corridoController.text.substring(0, 2)},${_corridoController.text.substring(2, 4)}";

    print("los numeros fijos son ${corrido}");
    try {
      final response = await http.post(
        Uri.parse('https://api.perf3ctsolutions.com/api/resultados'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'fijo': fijo,
          'corrido': corrido,
          'session': _session,
          'estado': _estado,
          'fecha': _selectedDate.toIso8601String(), // Enviar fecha directamente
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Resultado guardado correctamente'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar el resultado'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error de red: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Column(
        children: [
          Dashboard(),
          SizedBox(
            height: 45,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 40),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                //color: Color.fromARGB(153, 224, 217, 217),
                color: Colors.white,
                /* borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24), topRight: Radius.circular(24)) */
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texto "Registrar Resultado"
                      Text(
                        'Registrar Resultado',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Card que contiene el formulario
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Campo de "Fijo"
                              TextField(
                                controller: _fijoController,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  labelText: 'Fijo',
                                  prefixIcon: Icon(Icons.format_list_numbered),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Campo de "Corrido"
                              TextField(
                                controller: _corridoController,
                                maxLength: 4,
                                decoration: InputDecoration(
                                  labelText: 'Corrido',
                                  prefixIcon: Icon(Icons.format_list_numbered),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Dropdown para "Sesión"
                              DropdownButtonFormField<String>(
                                value: _session,
                                decoration: InputDecoration(
                                  labelText: 'Sesión',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: ['día', 'noche'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _session = newValue!;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              // Dropdown para "Estado"
                              DropdownButtonFormField<String>(
                                value: _estado,
                                decoration: InputDecoration(
                                  labelText: 'Estado',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: ['completo', 'en espera']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _estado = newValue!;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              // Selector de fecha
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Fecha:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "${_selectedDate.toLocal()}".split(' ')[
                                        0], // Mostrar la fecha seleccionada después de "Fecha:"
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () => _selectDate(context),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              // Botón de Guardar
                              _isLoading
                                  ? CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: saveResult,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        textStyle: TextStyle(fontSize: 18),
                                      ),
                                      child: Text('Guardar'),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          child: Text('Ver resultado'))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

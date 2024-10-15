import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int currStep = 0;
  List<Step> steps = [];
  List<String> listaFijos = [];
  List<String> listaFechas = [];
  List<String> listaDecenas = [];
  List<String> fechasDecenas = [];
  List<String> listaCentenas = [];
  List<String> fechasCentenas = [];
  List<String> listaTerminales = [];
  List<String> fechasTerminales = [];
  List<String> listaDobles = [];
  List<String> fechasDobles = [];
  bool isLoading = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDatosFijos();
    _fetchDatosDecenas();
    _fetchDatosCentenas();
    _fetchDatosTerminales();
    _fetchDatosDobles();
  }

  Future<void> _fetchDatosFijos() async {
    final uri = Uri.parse('https://api.perf3ctsolutions.com/api/resultados');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        Map<String, DateTime> fijosMap = {};

        for (var item in jsonResponse) {
          String fijo = item['fijo'].toString();
          DateTime fecha = DateTime.parse(item['fecha']);

          if (fijosMap.containsKey(fijo)) {
            if (fecha.isAfter(fijosMap[fijo]!)) {
              fijosMap[fijo] = fecha;
            }
          } else {
            fijosMap[fijo] = fecha;
          }
        }

        List<MapEntry<String, DateTime>> sortedFijos = fijosMap.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        List<MapEntry<String, DateTime>> fetchedFijos =
            sortedFijos.take(3).toList();

        List<String> numerosFijos =
            fetchedFijos.map((entry) => entry.key).toList();
        List<String> fechas =
            fetchedFijos.map((entry) => entry.value.toIso8601String()).toList();
        if (mounted) {
          setState(() {
            listaFijos = numerosFijos;
            listaFechas = fechas;
            isLoading = false;
            _updateSteps();
          });
        }
      } else {
        throw Exception('Fallo al cargar los datos de números fijos');
      }
    } catch (e) {
      print('Error al cargar los números fijos: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDatosDecenas() async {
    final uri = Uri.parse('https://api.perf3ctsolutions.com/api/resultados');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Mapa para almacenar la fecha más reciente para cada decena
        Map<String, DateTime> decenasMap = {};
        DateTime now = DateTime.now();
        Duration diasDeAtraso =
            Duration(days: 30); // Ajustar el rango según necesidad

        for (var item in jsonResponse) {
          String numeroCompleto = item['fijo'].toString();

          // Solo procesar números de dos cifras
          if (numeroCompleto.length == 2) {
            String decena = (int.parse(numeroCompleto) ~/ 10)
                .toString(); // Obtener la decena

            // Convertir la fecha a DateTime, manejando el formato correcto
            DateTime fecha;
            try {
              fecha = DateTime.parse(item['fecha']);
            } catch (e) {
              print('Formato de fecha inválido en item: ${item['fecha']}');
              continue;
            }

            // Verificar si la decena ya está en el mapa y actualizar si la nueva fecha es más reciente
            if (decenasMap.containsKey(decena)) {
              if (fecha.isAfter(decenasMap[decena]!)) {
                decenasMap[decena] = fecha;
              }
            } else {
              // Si la decena no está en el mapa, agregarla con su fecha
              decenasMap[decena] = fecha;
            }
          }
        }

        // Filtrar decenas que NO hayan salido en los últimos 30 días
        List<MapEntry<String, DateTime>> decenasAtrasadas = decenasMap.entries
            .where((entry) => now.difference(entry.value) > diasDeAtraso)
            .toList();

        // Ordenar las decenas atrasadas por la fecha más antigua
        decenasAtrasadas.sort((a, b) => a.value.compareTo(b.value));

        // Tomar las 3 decenas más atrasadas
        List<MapEntry<String, DateTime>> fetchedDecenas =
            decenasAtrasadas.take(3).toList();

        // Convertir las decenas filtradas y sus fechas en listas separadas
        List<String> numerosDecenas =
            fetchedDecenas.map((entry) => entry.key).toList();
        List<String> fechasDecenas = fetchedDecenas
            .map((entry) => entry.value.toIso8601String())
            .toList();

        // Actualizar el estado del widget con los datos procesados
        if (mounted) {
          setState(() {
            listaDecenas = numerosDecenas;
            this.fechasDecenas = fechasDecenas;
            isLoading = false;
            _updateSteps(); // Asumo que esta función actualiza la UI según los pasos requeridos
          });
        }
      } else {
        throw Exception('Fallo al cargar los datos de decenas');
      }
    } catch (e) {
      print('Error al cargar las decenas: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDatosCentenas() async {
    final uri = Uri.parse('https://api.perf3ctsolutions.com/api/resultados');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Mapa para almacenar la fecha más reciente para cada número de un dígito
        Map<String, DateTime> digitosMap = {};
        DateTime now = DateTime.now();
        Duration diasDeAtraso =
            Duration(days: 30); // Ajustar según tu necesidad

        for (var item in jsonResponse) {
          String numeroCompleto = item['fijo'].toString();

          // Solo procesar números de un dígito
          if (numeroCompleto.length == 1) {
            String digito = numeroCompleto; // Mantener el dígito tal cual
            DateTime fecha = DateTime.parse(item['fecha']);

            // Verificar si el dígito ya está en el mapa y actualizar si la nueva fecha es más reciente
            if (digitosMap.containsKey(digito)) {
              if (fecha.isAfter(digitosMap[digito]!)) {
                digitosMap[digito] = fecha;
              }
            } else {
              // Si el dígito no está en el mapa, agregarlo con su fecha
              digitosMap[digito] = fecha;
            }
          }
        }

        // Filtrar los dígitos que NO hayan salido en los últimos 30 días
        List<MapEntry<String, DateTime>> digitosAtrasados = digitosMap.entries
            .where((entry) => now.difference(entry.value) > diasDeAtraso)
            .toList();

        // Ordenar los dígitos atrasados por la fecha más antigua
        digitosAtrasados.sort((a, b) => a.value.compareTo(b.value));

        // Tomar los 3 dígitos más atrasados
        List<MapEntry<String, DateTime>> fetchedDigitos =
            digitosAtrasados.take(3).toList();

        // Convertir los dígitos filtrados y sus fechas en listas separadas
        List<String> numerosDigitos =
            fetchedDigitos.map((entry) => entry.key).toList();
        List<String> fechasDigitos = fetchedDigitos
            .map((entry) => entry.value.toIso8601String())
            .toList();

        if (mounted) {
          setState(() {
            listaCentenas =
                numerosDigitos; // Utilizamos la misma lista para almacenar los dígitos
            this.fechasCentenas = fechasDigitos; // Fechas de los dígitos
            isLoading = false;
            _updateSteps();
          });
        }
      } else {
        throw Exception('Fallo al cargar los datos de centenas (dígitos)');
      }
    } catch (e) {
      print('Error al cargar los dígitos: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDatosTerminales() async {
    final uri = Uri.parse('https://api.perf3ctsolutions.com/api/resultados');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Diccionario para almacenar la última fecha de cada terminal
        Map<String, DateTime> terminalesMap = {};

        // Función para procesar y almacenar los terminales de números de dos dígitos
        void procesarTerminal(String numero, DateTime fecha) {
          if (numero.length == 2) {
            String terminal = numero.substring(1); // Obtener el último dígito

            if (terminalesMap.containsKey(terminal)) {
              if (fecha.isAfter(terminalesMap[terminal]!)) {
                terminalesMap[terminal] = fecha;
              }
            } else {
              terminalesMap[terminal] = fecha;
            }
          }
        }

        // Iterar sobre todos los números tanto en 'fijo' como en 'corrido'
        for (var item in jsonResponse) {
          String fijo = item['fijo'].toString();
          String corrido = item['corrido'].toString();

          // Obtener la fecha del resultado
          DateTime fecha = DateTime.parse(item['fecha']);

          // Procesar terminales para 'fijo' y 'corrido'
          procesarTerminal(fijo, fecha);
          procesarTerminal(corrido, fecha);
        }

        // Ordenar los terminales por fecha (de más antiguo a más reciente)
        List<MapEntry<String, DateTime>> sortedTerminales =
            terminalesMap.entries.toList()
              ..sort((a, b) => a.value.compareTo(b.value));

        // Tomar los 3 terminales que más tiempo llevan sin salir
        List<MapEntry<String, DateTime>> fetchedTerminales =
            sortedTerminales.take(3).toList();

        // Crear listas con los terminales y sus fechas correspondientes
        List<String> numerosTerminales =
            fetchedTerminales.map((entry) => entry.key).toList();
        List<String> fechasTerminales = fetchedTerminales
            .map((entry) => entry.value.toIso8601String())
            .toList();

        // Actualizar el estado con los terminales y las fechas
        if (mounted) {
          setState(() {
            listaTerminales = numerosTerminales;
            this.fechasTerminales = fechasTerminales;
            isLoading = false;
            _updateSteps();
          });
        }
      } else {
        throw Exception('Fallo al cargar los datos de terminales');
      }
    } catch (e) {
      print('Error al cargar los terminales: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDatosDobles() async {
    final uri = Uri.parse('https://api.perf3ctsolutions.com/api/resultados');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Diccionario para almacenar la última fecha de cada número doble
        Map<String, DateTime> doblesMap = {};

        // Iterar sobre todos los números tanto en 'fijo' como en 'corrido'
        for (var item in jsonResponse) {
          // Extraer y convertir 'fijo' y 'corrido' a cadenas
          String fijo = item['fijo'].toString();
          String corrido = item['corrido'].toString();

          // Función para procesar y almacenar números dobles
          void procesarDoble(String numero, DateTime fecha) {
            if (numero.length == 2 && numero[0] == numero[1]) {
              if (doblesMap.containsKey(numero)) {
                if (fecha.isAfter(doblesMap[numero]!)) {
                  doblesMap[numero] = fecha;
                }
              } else {
                doblesMap[numero] = fecha;
              }
            }
          }

          // Obtener la fecha del resultado
          DateTime fecha = DateTime.parse(item['fecha']);

          // Procesar los números dobles de 'fijo' y 'corrido'
          procesarDoble(fijo, fecha);
          procesarDoble(corrido, fecha);
        }

        // Ordenar los dobles por fecha (de más antiguo a más reciente)
        List<MapEntry<String, DateTime>> sortedDobles = doblesMap.entries
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        // Tomar los 3 números dobles que más tiempo llevan sin salir
        List<MapEntry<String, DateTime>> fetchedDobles =
            sortedDobles.take(3).toList();

        // Crear listas con los números dobles y sus fechas correspondientes
        List<String> numerosDobles =
            fetchedDobles.map((entry) => entry.key).toList();
        List<String> fechasDobles = fetchedDobles
            .map((entry) => entry.value.toIso8601String())
            .toList();

        // Actualizar el estado con los números dobles y las fechas
        if (mounted) {
          setState(() {
            listaDobles = numerosDobles;
            this.fechasDobles = fechasDobles;
            isLoading = false;
            _updateSteps();
          });
        }
      } else {
        throw Exception('Fallo al cargar los datos de dobles');
      }
    } catch (e) {
      print('Error al cargar los dobles: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateSteps() {
    if (mounted) {
      setState(() {
        steps = [
          Step(
            title: const Text("Fijos",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            subtitle: const Text("Muestra los números fijos más atrasados",
                style: TextStyle(fontSize: 14, color: Colors.black)),
            isActive: true,
            content: NumerosWidget(
              listaFijo: listaFijos.join(','),
              fechas: listaFechas.join(','),
            ),
          ),
          Step(
            title: const Text("Decenas",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            subtitle: const Text("Muestra las decenas más atrasadas",
                style: TextStyle(fontSize: 14, color: Colors.black)),
            isActive: true,
            content: NumerosWidget(
              listaFijo: listaDecenas.join(','),
              fechas: fechasDecenas.join(','),
            ),
          ),
          Step(
            title: const Text("Centenas",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            subtitle: const Text("Muestra las centenas más atrasadas",
                style: TextStyle(fontSize: 14, color: Colors.black)),
            isActive: true,
            content: NumerosWidget(
              listaFijo: listaCentenas.join(','),
              fechas: fechasCentenas.join(','),
            ),
          ),
          Step(
            title: const Text("Terminales",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            subtitle: const Text("Muestra los terminales más atrasados",
                style: TextStyle(fontSize: 14, color: Colors.black)),
            isActive: true,
            content: NumerosWidget(
              listaFijo: listaTerminales.join(','),
              fechas: fechasTerminales.join(','),
            ),
          ),
          Step(
            title: const Text("Dobles",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            subtitle: const Text("Muestra los números dobles más atrasados",
                style: TextStyle(fontSize: 14, color: Colors.black)),
            isActive: true,
            content: NumerosWidget(
              listaFijo: listaDobles.join(','),
              fechas: fechasDobles.join(','),
            ),
          ),
        ];

        if (currStep >= steps.length) {
          currStep = steps.isNotEmpty ? steps.length - 1 : 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "Datos Estadísticos",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : steps.isEmpty
                ? const Center(child: Text('No hay resultados disponibles'))
                : Stepper(
                    steps: steps,
                    type: StepperType.vertical,
                    currentStep: currStep,
                    controlsBuilder:
                        (BuildContext context, ControlsDetails controls) {
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          TextButton(
                            onPressed: controls.onStepContinue,
                            child: const Text('CONTINUAR'),
                          ),
                          TextButton(
                            onPressed: controls.onStepCancel,
                            child: const Text('ANTERIOR'),
                          ),
                        ],
                      );
                    },
                    onStepContinue: () {
                      setState(() {
                        if (currStep < steps.length - 1) {
                          currStep++;
                        }
                      });
                    },
                    onStepCancel: () {
                      setState(() {
                        if (currStep > 0) {
                          currStep--;
                        }
                      });
                    },
                    onStepTapped: (step) {
                      setState(() {
                        currStep = step;
                      });
                    },
                  ),
      ),
    );
  }
}

class NumerosWidget extends StatelessWidget {
  final String listaFijo;
  final String fechas;

  const NumerosWidget({
    super.key,
    required this.listaFijo,
    required this.fechas,
  });

  @override
  Widget build(BuildContext context) {
    List<String> numerosFijos = listaFijo.split(',');
    List<String> fechasList = fechas.split(',');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numerosFijos.map((numero) {
            return Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Center(
                child: Text(numero,
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(numerosFijos.length, (index) {
            try {
              DateTime fecha = DateTime.parse(fechasList[index]);
              return Text('${calcularDias(fecha)} días ',
                  style: const TextStyle(fontSize: 18, color: Colors.red));
            } catch (e) {
              return Text('Fecha inválida',
                  style: const TextStyle(fontSize: 18, color: Colors.red));
            }
          }),
        ),
      ],
    );
  }

  String calcularDias(DateTime fecha) {
    DateTime dateNow = DateTime.now();
    Duration fechaRest = dateNow.difference(fecha);
    return "${fechaRest.inDays}";
  }
}

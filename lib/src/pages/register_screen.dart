import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotengo/src/widgets/AppStructure/dashboard.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no continuar
    }

    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

    final response = await http.post(
      Uri.parse('https://api.perf3ctsolutions.com/api/register'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      },
    );

    setState(() {
      _isLoading = false; // Ocultar el indicador de carga
    });

    if (response.statusCode == 201) {
      print('Usuario registrado con éxito');
      Navigator.pop(context); // Regresar a la pantalla de login
    } else {
      print('Error: ${response.body}');
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Texto Registrarse
                        Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Card con el formulario de registro
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Campo de Nombre
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nombre',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su nombre';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                // Campo de Email
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'Por favor ingrese un email válido';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                // Campo de Contraseña
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su contraseña';
                                    }
                                    if (value.length < 6) {
                                      return 'La contraseña debe tener al menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                // Campo de Confirmar Contraseña
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar Contraseña',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 30),
                                // Botón de Registrar
                                _isLoading
                                    ? CircularProgressIndicator() // Mostrar indicador de carga si está cargando
                                    : ElevatedButton(
                                        onPressed: () => register(context),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        child: Text('Registrar'),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

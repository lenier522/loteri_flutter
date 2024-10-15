import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.perf3ctsolutions.com/api/login'),
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('user') &&
            data['user'].containsKey('name') &&
            data['user'].containsKey('created_at')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true); // Guarda estado de login
          await prefs.setString('userName', data['user']['name']); // Nombre
          await prefs.setString('userEmail', _emailController.text); // Email
          await prefs.setString('userRegisteredAt',
              data['user']['created_at']); // Fecha de registro

          // Navegar a HomePage y reemplazar la pantalla de Login
          Navigator.pushReplacementNamed(context, '/');
        } else {
          _showErrorDialog('Error', 'Datos del servidor inválidos.');
        }
      } else {
        _showErrorDialog('Error', 'Credenciales inválidas.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error', 'Error de conexión.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Column(
          children: [
            SizedBox(
              width: 45,
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
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          SizedBox(height: 20),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
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
                                        return 'Por favor ingresa tu email';
                                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return 'Por favor ingresa un email válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
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
                                        return 'Por favor ingresa tu contraseña';
                                      } else if (value.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  _isLoading
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: () => login(context),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 50, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            textStyle: TextStyle(fontSize: 18),
                                          ),
                                          child: Text('Iniciar Sesión'),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              '¿No tienes cuenta? Regístrate aquí',
                              style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}

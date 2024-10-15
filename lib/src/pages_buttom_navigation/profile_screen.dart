import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double? width;
  bool showOptions = false; // Controla si el FAB se ha desplegado
  String email = '';
  String nombreUsuario = '';
  String fechaRegistro = '';

  // Controladores para los campos de contraseña
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();

  // Variables para manejar la visibilidad de las contraseñas
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isObscureCurrentPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar el correo, el nombre y la fecha de registro al iniciar
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('userEmail') ??
          'correo@gmail.com'; // Valor predeterminado
      nombreUsuario = prefs.getString('userName') ??
          'Nombre y Apellidos'; // Valor predeterminado
      String? fechaRaw =
          prefs.getString('userRegisteredAt'); // Cargar la fecha de registro

      if (fechaRaw != null) {
        // Formatear la fecha al formato día/mes/año
        DateTime fecha = DateTime.parse(fechaRaw);
        fechaRegistro = DateFormat('dd/MM/yyyy').format(fecha);
      } else {
        fechaRegistro = 'Desconocida'; // Valor por defecto si no hay fecha
      }
    });
  }

  // Función para cambiar la contraseña
  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      // Mostrar un mensaje si las contraseñas no coinciden
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    try {
      final url =
          Uri.parse('https://api.perf3ctsolutions.com/api/change-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        }),
      );

      // Log de la respuesta para depurar
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña cambiada exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al cambiar la contraseña: ${response.body}')),
        );
      }
    } catch (error) {
      // Log para depurar el error
      print('Error al cambiar la contraseña: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña: $error')),
      );
    }
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Elimina todos los datos guardados en SharedPreferences
    Navigator.pushReplacementNamed(
        context, '/'); // Redirige a la pantalla de login
  }

  void toggleOptions() {
    setState(() {
      showOptions = !showOptions; // Alterna la visibilidad de las opciones
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 2, right: 2),
          physics: const ScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color.fromARGB(153, 224, 217, 217),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24))),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Stack(
                    children: <Widget>[profileContent()],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Divider(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                           const Expanded(
                              child: Text(
                                "Cambiar Contraseña",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                              width: 50,
                            ),
                            MaterialButton(
                              onPressed: _changePassword,
                              shape: const CircleBorder(),
                              color: Colors.black45,
                              textColor: Colors.white,
                              child: const Icon(Icons.save),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Contraseña Actual',
                          obscureText: _isObscureCurrentPassword,
                          onVisibilityToggle: () {
                            setState(() {
                              _isObscureCurrentPassword =
                                  !_isObscureCurrentPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'Nueva Contraseña',
                          obscureText: _isObscureNewPassword,
                          onVisibilityToggle: () {
                            setState(() {
                              _isObscureNewPassword = !_isObscureNewPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Contraseña',
                          obscureText: _isObscureConfirmPassword,
                          onVisibilityToggle: () {
                            setState(() {
                              _isObscureConfirmPassword =
                                  !_isObscureConfirmPassword;
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Divider(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              _logout, // Llamada a la función para cerrar sesión
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Color del botón de cerrar sesión
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showOptions) ...[
              FloatingMethod(
                context,
                "opt1",
                const Color.fromARGB(255, 85, 176, 250),
                'addresult',
                'Agregar Resultado',
                const Icon(Icons.numbers, color: Colors.white),
              ),
              // Mostrar las demás opciones solo si el email es 'leniercruz02@gmail.com'
              if (email == 'leniercruz02@gmail.com' || email == 'lotengo@gmail.com') ...[
                const SizedBox(height: 16.0),
                FloatingMethod(
                  context,
                  "opt2",
                  Colors.green,
                  '/last',
                  'Lista de Números',
                  const Icon(Icons.format_list_numbered_rounded,
                      color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                FloatingMethod(
                  context,
                  "opt3",
                  const Color.fromARGB(255, 85, 176, 250),
                  '/register',
                  'Agregar Usuario',
                  const Icon(Icons.person_add_alt, color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                FloatingMethod(
                  context,
                  "opt4",
                  Colors.green,
                  '/userlist',
                  'Mostrar Usuarios',
                  const Icon(Icons.list_rounded, color: Colors.white),
                ),
              ]
            ],
            FloatingActionButton.extended(
              heroTag: "extend1",
              onPressed: () {
                toggleOptions(); // Al presionar, alterna las opciones
              },
              label: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton FloatingMethod(BuildContext context, String heroTag,
      Color color, String ruta, String tooltip, Icon icon) {
    return FloatingActionButton(
      heroTag: heroTag,
      elevation: 10.0,
      backgroundColor: color,
      mini: true,
      onPressed: () {
        Navigator.pushNamed(
          context,
          ruta,
        );
      },
      tooltip: tooltip,
      child: icon,
    );
  }

  Widget profileContent() {
    return Container(
      margin: const EdgeInsets.only(top: 40.0),
      decoration: const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Text(nombreUsuario,
                style: const TextStyle(fontSize: 30, color: Colors.black)),
            Text(email,
                style: const TextStyle(fontSize: 20, color: Colors.black)),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Divider(color: Colors.blueAccent, height: 0.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Fecha de registro: "),
                Expanded(
                  // Agregado el widget Expanded
                  child: Text(
                    fechaRegistro, // Mostrar la fecha formateada
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    overflow: TextOverflow
                        .ellipsis, // Evitar desbordamiento del texto
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
    );
  }
}

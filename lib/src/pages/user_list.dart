import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lotengo/src/widgets/AppStructure/dashboard.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Método para obtener la lista de usuarios
  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse(
          'https://api.perf3ctsolutions.com/api/users'), // Cambia por la ruta de tu API
    );

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: ${response.body}')),
      );
    }
  }

  // Método para eliminar usuario
  Future<void> _deleteUser(String email) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.perf3ctsolutions.com/api/eliminar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario eliminado exitosamente')),
        );
        _fetchUsers(); // Volver a cargar la lista de usuarios después de eliminar uno
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar usuario: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error al intentar eliminar el usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Column(
          children: [
            Dashboard(),
            SizedBox(height: 45),
            Expanded(
              // Solución para evitar el error del ListView con altura indefinida
              child: Container(
                padding: EdgeInsets.only(bottom: 140),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                ),
                child: users.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteUser(user[
                                    'email']); // Llamar al método para eliminar
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

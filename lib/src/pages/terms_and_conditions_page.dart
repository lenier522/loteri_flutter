import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Condiciones de Uso"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Center(
              child: Image.asset(
                'data/images/logo.png', // Asegúrate de que esta imagen esté en tu carpeta de assets
                height: 200, // Puedes ajustar la altura
              ),
            ),
            SizedBox(height: 20), // Espacio entre la imagen y el texto
            // Texto de condiciones
            Text(
              "Al continuar, aceptas nuestras condiciones de uso y políticas de privacidad.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20), // Espacio antes del botón
            // Botón de aceptar
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para aceptar las condiciones, por ejemplo, redirigir a otra página
                 Navigator.pushReplacementNamed(context,'/'); // Volver a la página anterior
                },
                child: Text("Aceptar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

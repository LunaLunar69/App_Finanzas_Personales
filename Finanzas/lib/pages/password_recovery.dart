import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  RecuperarPasswordPageState createState() => RecuperarPasswordPageState();
}

class RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para enviar el correo de recuperación
  void _enviarRecuperacion() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        // Mostrar diálogo de confirmación
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Correo Enviado'),
            content: Text('Se ha enviado un correo de recuperación a $email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } catch (e) {
        // Manejo de errores y mostrar mensaje
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } else {
      // Si el campo email está vacío, se muestra un error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Por favor ingresa un email válido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para el email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Ingresa tu correo electrónico',
              ),
            ),
            const SizedBox(height: 20),
            // Botón para iniciar el proceso de recuperación
            ElevatedButton(
              onPressed: _enviarRecuperacion,
              child: const Text('Recuperar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

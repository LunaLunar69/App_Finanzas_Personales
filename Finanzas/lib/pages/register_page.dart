import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'package:minimallogin/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de texto
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Método para registrar usuario
 void register() async {
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  if (passwordController.text != confirmPasswordController.text) {
    if (mounted) {
      Navigator.pop(context); // Cerrar loading de forma segura
    }
    displayMesaageToUser("¡Las contraseñas no coinciden!", context);
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    String uid = userCredential.user!.uid;

    await FirebaseFirestore.instance.collection("usuarios").doc(uid).set({
      "nombre": nombreController.text.trim(),
      "apellidos": apellidosController.text.trim(),
      "email": emailController.text.trim(),
      "created_time": Timestamp.now(),
      "uid": uid
    });

    if (mounted) {
      Navigator.pop(context); // Cerrar loading de forma segura
    }
    displayMesaageToUser("¡Registro exitoso!", context);
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      Navigator.pop(context); // Cerrar loading de forma segura
    }

    String message = "Error al registrarse";
    if (e.code == 'email-already-in-use') {
      message = "El correo ya está en uso.";
    } else if (e.code == 'weak-password') {
      message = "La contraseña es demasiado débil.";
    }

    displayMesaageToUser(message, context);
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // Cerrar loading de forma segura
    }
    displayMesaageToUser("Ocurrió un error inesperado.", context);
    print("Error desconocido: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('lib/images/unlock.png', height: 100, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 50),
                Text('Creemos una cuenta para ti', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                const SizedBox(height: 25),

                // Campos de texto
                MyTextField(controller: nombreController, hintText: 'Nombre(s)', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: apellidosController, hintText: 'Apellido(s)', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: passwordController, hintText: 'Contraseña', obscureText: true),
                const SizedBox(height: 10),
                MyTextField(controller: confirmPasswordController, hintText: 'Confirmar Contraseña', obscureText: true),
                const SizedBox(height: 25),

                // Botón de registro
                MyButton(onTap: register, text: "Registrarse"),
                const SizedBox(height: 50),

                // Enlace a iniciar sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya está registrado?', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Inicia sesión ahora', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

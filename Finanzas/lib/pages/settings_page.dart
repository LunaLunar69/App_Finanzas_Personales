import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimallogin/auth/login_or_register.dart';
import 'package:minimallogin/components/my_button.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Función para mostrar la confirmación de cierre de sesión
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancelar
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              // Cerrar sesión en Firebase
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                // Navegar a la pantalla de Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginOrRegister()),
                  (route) => false, // Elimina todas las pantallas previas
                );
              }
            },
            child: const Text("Sí, salir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Modo oscuro con el Switch
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Modo Oscuro",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    CupertinoSwitch(
                      onChanged: (value) =>
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                      value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botón de Cerrar sesión con confirmación
              MyButton(
                onTap: () => _confirmSignOut(context),
                text: "Cerrar Sesión",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

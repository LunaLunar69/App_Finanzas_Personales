import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            "Esta es la página de inicio de la aplicación una vez que el usuario inicia sesión",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  } 
}

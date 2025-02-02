  import 'package:minimallogin/auth/login_or_register.dart';
  import 'package:minimallogin/components/my_button.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../theme/theme_provider.dart';

  class SettingsPage extends StatelessWidget {
    const SettingsPage({super.key});

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
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Modo Ocuro",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                      CupertinoSwitch(
                        onChanged: (value) =>
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme(),
                        value: Provider.of<ThemeProvider>(context, listen: false)
                            .isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                //botón de Cerrar sesión
                MyButton(
                    onTap: () {
                      () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginOrRegister(),
                        ),
                      );
                    },
                    text: "Cerrar Sesión",
                  )
              ],
            ),
          ),
        ),
      );
    }
  } 

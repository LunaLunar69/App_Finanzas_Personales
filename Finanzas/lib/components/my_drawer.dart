import 'package:flutter/material.dart';
import '../auth/login_or_register.dart';
import '../pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // app logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: DrawerHeader(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Image.asset(
                        'lib/images/unlock.png',
                        color: Theme.of(context).colorScheme.primary,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ),

              // mosaico de lista de inicio
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10),
                child: ListTile(
                  title: const Text("I N G R E S O S"),
                  leading: const Icon(Icons.home),
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // mosaico de lista de configuraciones
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10),
                child: ListTile(
                  title: const Text("A J U S T E S"),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // ir a la página de configuración
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // mosaico de lista de cierre de sesión
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("L O G O U T"),
              leading: const Icon(Icons.logout),
              onTap: () {
                // ir a la página de inicio de sesion
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginOrRegister(),
                    ),
                    (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

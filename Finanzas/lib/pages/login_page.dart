import 'package:minimallogin/pages/hidden_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/my_square_tile.dart';
import '../theme/theme_provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controladores de texto
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Aqui vamos a poner el metodo de logeo por firebase
  void login() {
    // primero se realiza el proceso de autenticacion

    // una vez autenticado el usario lo redirigimos a la pagina de inicio
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HiddenDrawer(),
      ),
    );
  }

  // aqui vamos a poner el metodo de recuperacion de contraseña
  void forgotPw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Aun no implementado :(."),
      ),
    );
  }

  // google sign in
  void googleSignIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Iniciar con Google?"),
        actions: [
          // cancel
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),

          // yes
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HiddenDrawer(),
              ),
            ),
            child: const Text("Si"),
          ),
        ],
      ),
    );
  }

  // apple sign in
  void appleSignIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Iniciar con Apple ID?"),
        actions: [
          // cancel
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),

          // yes
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HiddenDrawer(),
              ),
            ),
            child: const Text("Si"),
          ),
        ],
      ),
    );
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

                // logo cachondo
                Image.asset(
                  'lib/images/unlock.png',
                  height: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 50),

                // Mensaje de bienvenida todo uwu
                Text(
                  '¡Bienvenido de nuevo, te hemos extrañado!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
 
                const SizedBox(height: 25),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // link para recuperar contraseña
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: forgotPw,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Boton de inicio
                MyButton(
                  onTap: login,
                  text: "Iniciar Sesion",
                ),

                const SizedBox(height: 25),

                // Otros metodos de inicio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'O continuar con',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // google + apple botones de inicio de sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(
                      onTap: googleSignIn,
                      child: Image.asset(
                        'lib/images/google.png',
                        height: 25,
                      ),
                    ),

                    const SizedBox(width: 25),

                    // apple button
                    SquareTile(
                      onTap: appleSignIn,
                      child: Image.asset(
                        'lib/images/apple.png',
                        height: 25,
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.grey.shade400
                            : Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Link para registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No eres miembro?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Regístrate ahora',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
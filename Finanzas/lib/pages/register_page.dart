import 'package:minimallogin/helper/helper_functions.dart';
import 'package:minimallogin/pages/hidden_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

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

  // metodo de registro todo cachondo con firebase
  void register() async{
    // Aqui se va a crear la cuenta y el documeto con los datos del usuario

    // show dialog circle
    showDialog(
      context: context,
       builder: (context) => const Center(
        child: CircularProgressIndicator(),
       ),
    );

    //match de las contraseñas
    if(passwordController.text != confirmPasswordController.text){
      //pop loading circle
      Navigator.pop(context);

      //show error message to user
      displayMesaageToUser("¡las contraseñas no coiciden!", context);
    }else{
      try{
      // crear usuario
      UserCredential? userCredential =
       await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
         password: passwordController.text,
      );

      //pop loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e){
      //pop loading circle
      Navigator.pop(context);

      //display error mesage to user
      displayMesaageToUser(e.code, context);
    }

    // Una vez creado se le va a mandar un codigo de verificacion y se le redirigira a el inicio de sesion
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HiddenDrawer(),
        ),
      );
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

                // logo
                Image.asset(
                  'lib/images/unlock.png',
                  height: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 50),

                // create una cuenta cachonda!
                Text(
                  'Creemos una cuenta para ti',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // nombre textfield
                MyTextField(
                  controller: nombreController,
                  hintText: 'Nombre(s)',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // apellidos textfield
                MyTextField(
                  controller: apellidosController,
                  hintText: 'Apellido(s)',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

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

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirmar Contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // boton de registro
                MyButton(
                  onTap: register,
                  text: "Registrarse",
                ),

                const SizedBox(height: 50),

                // por si ya tiene cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya esta registrado?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Inicia sesión ahora',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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

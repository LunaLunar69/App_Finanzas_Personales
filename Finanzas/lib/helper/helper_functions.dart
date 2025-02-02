import 'package:flutter/material.dart';

//mostrar el mensaje de error al usuario
void displayMesaageToUser(String message, BuildContext context){
  showDialog(
    context: context,
     builder: (context) => AlertDialog(
      title:  Text(message),
     ),
  );
}
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que las operaciones de Flutter están preparadas.
  await Firebase.initializeApp(); // Inicializa Firebase.
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

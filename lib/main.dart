import 'package:chatempresa/AuthChecker.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Inicializa los bindings de Flutter.
  await Firebase.initializeApp(); // Inicializa Firebase.

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthChecker(),
    routes: {
      '/login': (context) => LoginScreen(),
    },
  ));
}

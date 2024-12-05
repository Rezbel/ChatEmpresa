import 'package:chatempresa/modelo/PAChatsList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Pantallachat extends StatefulWidget {
  const Pantallachat({super.key});

  @override
  State<Pantallachat> createState() => _PantallachatState();
}

class _PantallachatState extends State<Pantallachat> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      // Manejar el caso en que no haya un usuario autenticado
      return const Center(
        child: Text(
          'No se encontró un usuario autenticado.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: PAChatsList(currentUser: currentUser),
    );
  }
}

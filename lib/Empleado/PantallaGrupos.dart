import 'package:chatempresa/modelo/PAGruposList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PantallaGrupos extends StatelessWidget {
  const PantallaGrupos({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          'Usuario no autenticado',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black87, // Fondo oscuro para la pantalla.
      body: PAGruposList(
        currentUserId: currentUser.uid, // Pasar el userId actual.
      ),
    );
  }
}

import 'package:chatempresa/Administrador/PABottomNavigation.dart';
import 'package:chatempresa/Empleado/BottomNavigation.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Si no hay usuario autenticado, redirige a LoginScreen
      return LoginScreen();
    } else {
      // Si hay un usuario autenticado, verifica su rol
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los datos del usuario"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Usuario no encontrado"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String role = userData['role'] ?? 'empleado';

          // Redirige según el rol
          if (role == 'administrador') {
            return PABottomnavigation(); // Pantalla para administrador
          } else if (role == 'empleado') {
            return Bottomnavigation(); // Pantalla para empleado
          } else {
            return LoginScreen(); 
          }
        },
      );
    }
  }
}

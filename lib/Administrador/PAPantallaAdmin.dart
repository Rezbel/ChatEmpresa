import 'package:chatempresa/Administrador/PANuevoUsuario.dart';
import 'package:chatempresa/Administrador/Proyectos/PAPantallaCrearProyecto.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PAPantallaAdmin extends StatelessWidget {
  const PAPantallaAdmin({super.key});

  void _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}


  void _openMeetingLink() async {
    const url = 'https://meet.google.com/landing';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Cerrar sesión') {
                _signOut(context);
              } else if (value == 'Agendar reunión') {
                _openMeetingLink();
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Cerrar sesión',
                child: Text('Cerrar sesión'),
              ),
              const PopupMenuItem<String>(
                value: 'Agendar reunión',
                child: Text('Agendar reunión'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Funciones de administrador',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            AdminButton(
              icon: Icons.people,
              label: 'Ver empleados',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(context, MaterialPageRoute(builder: (context) => PANuevoUsuario()));
              },
            ),
            SizedBox(height: 20),
            AdminButton(
              icon: Icons.person_add,
              label: 'Nuevo empleado',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder()));
              },
            ),
            SizedBox(height: 20),
            AdminButton(
              icon: Icons.work,
              label: 'Crear proyecto',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(context, MaterialPageRoute(builder: (context) => PAPantallaCrearProyecto()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AdminButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Ocupa todo el ancho disponible
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 20), // Ajuste para mayor altura
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[800]),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
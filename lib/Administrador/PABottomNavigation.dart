import 'package:chatempresa/Administrador/PAPantallaAdmin.dart';
import 'package:chatempresa/Administrador/PAPantallaChat.dart';
import 'package:chatempresa/Administrador/PAPantallaProyectos.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PABottomnavigation extends StatefulWidget {
  const PABottomnavigation({super.key});

  @override
  State<PABottomnavigation> createState() => _PABottomnavigationState();
}

class _PABottomnavigationState extends State<PABottomnavigation> {
  int _selectedIndex = 0; // Índice de la pantalla actual.

  // Lista de pantallas para la navegación.
  final List<Widget> _screens = [
    const PAPantallaproyectos(),
    const PAPantallachat(),
    const PAPantallaAdmin()
  ];
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _openMeetingLink() async {
    const url = 'https://meet.google.com/landing';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('No se puede abrir la URL xd $url');
    }
  }

  // Cambia el índice de la pantalla seleccionada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _screens[_selectedIndex], // Muestra la pantalla actual.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Colors.grey[850], // Fondo oscuro para la barra de navegación.
        selectedItemColor: Colors.white, // Color del ítem seleccionado.
        unselectedItemColor:
            Colors.grey, // Color de los ítems no seleccionados.
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // Icono para "Proyectos".
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), // Icono para "Chats".
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings), // Icono para "Grupos".
            label: 'Administrador',
          ),
        ],
      ),
    );
  }
}

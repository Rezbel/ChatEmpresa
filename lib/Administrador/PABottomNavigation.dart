import 'package:chatempresa/Administrador/PAPantallaAdmin.dart';
import 'package:chatempresa/Administrador/PAPantallaChat.dart';
import 'package:chatempresa/Administrador/PAPantallaProyectos.dart';

import 'package:flutter/material.dart';

class PABottomnavigation extends StatefulWidget {
  const PABottomnavigation({super.key});

  @override
  State<PABottomnavigation> createState() => _PABottomnavigationState();
}

class _PABottomnavigationState extends State<PABottomnavigation> {
  int _selectedIndex = 0; // Índice de la pantalla actual.

  // Lista de pantallas para la navegación.
  final List<Widget> _screens = [
    PAPantallaproyectos(),
    PAPantallachat(),
    PAPantallaAdmin()
  ];

  // Cambia el índice de la pantalla seleccionada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Muestra la pantalla actual.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850], // Fondo oscuro para la barra de navegación.
        selectedItemColor: Colors.white, // Color del ítem seleccionado.
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados.
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const[
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

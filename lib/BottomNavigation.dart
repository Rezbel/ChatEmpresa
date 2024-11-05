import 'package:chatempresa/PantallaChat.dart';
import 'package:chatempresa/PantallaGrupos.dart';
import 'package:chatempresa/PantallaProyectos.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0; // Índice de la pantalla actual.

  // Lista de pantallas para la navegación.
  final List<Widget> _screens = [
    Pantallachat(),       // Pantalla de Chats.
    PantallaGrupos(),   // Pantalla de Grupos.
    Pantallaproyectos() // Pantalla de Proyectos.
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), // Icono para "Chats".
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group), // Icono para "Grupos".
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // Icono para "Proyectos".
            label: 'Proyectos',
          ),
        ],
      ),
    );
  }
}

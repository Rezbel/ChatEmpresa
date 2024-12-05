import 'package:chatempresa/Empleado/PantallaChat.dart';
import 'package:chatempresa/Empleado/PantallaGrupos.dart';
import 'package:chatempresa/Empleado/PantallaProyectos.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0; // Índice de la pantalla actual.
  late final User? currentUser; // Usuario autenticado.

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser; // Obtener usuario actual.
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Lista de pantallas para la navegación.
  List<Widget> get _screens => [
        const Pantallachat(),
        const PantallaGrupos(), // Pantalla de Grupos.
        const Pantallaproyectos(), // Pantalla de Proyectos.
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
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
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

import 'package:flutter/material.dart';

class PAPantallaAdmin extends StatelessWidget {
  const PAPantallaAdmin({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {},
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder()));
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder()));
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
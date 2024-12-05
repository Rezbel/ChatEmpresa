import 'package:chatempresa/Administrador/PANuevoUsuario.dart';
import 'package:chatempresa/Administrador/Proyectos/PAPantallaCrearProyecto.dart';
import 'package:flutter/material.dart';

class PAPantallaAdmin extends StatelessWidget {
  const PAPantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Funciones de administrador',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            AdminButton(
              icon: Icons.people,
              label: 'Ver empleados',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PANuevoUsuario()));
              },
            ),
            const SizedBox(height: 20),
            AdminButton(
              icon: Icons.person_add,
              label: 'Nuevo empleado',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Placeholder()));
              },
            ),
            const SizedBox(height: 20),
            AdminButton(
              icon: Icons.work,
              label: 'Crear proyecto',
              onTap: () {
                // Navegación sin destino especificado
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PAPantallaCrearProyecto()));
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
    super.key,
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
        padding: const EdgeInsets.symmetric(
            vertical: 20), // Ajuste para mayor altura
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[800]),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

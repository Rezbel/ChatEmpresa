import 'package:chatempresa/Administrador/Proyectos/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/SubtareaScreen.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Proyecto project;

  const ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la nueva pantalla de subtareas
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubtareasScreen(
              projectId: project.id,
              usuariosDelProyecto: project.usuarios, // Pasamos la lista de usuarios del proyecto
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flutter_dash,
                  size: 30,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Usuarios: ${project.usuarios.length}'),
            const SizedBox(height: 8),
            Text('Fecha límite: ${project.fechaLimite.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
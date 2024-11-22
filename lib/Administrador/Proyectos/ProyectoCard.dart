import 'package:chatempresa/Administrador/Proyectos/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/SubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Proyecto project;

  const ProjectCard({required this.project});

  Future<double> _calcularProgreso(String projectId) async {
    try {
      final subtareasSnapshot = await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(projectId)
          .collection('subtareas')
          .get();

      if (subtareasSnapshot.docs.isEmpty) return 0.0;

      final totalSubtareas = subtareasSnapshot.docs.length;
      final completadas = subtareasSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['estado'] == 'completada';
      }).length;

      return completadas / totalSubtareas;
    } catch (e) {
      print('Error al calcular progreso: $e');
      return 0.0;
    }
  }

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
            const SizedBox(height: 8),
            FutureBuilder<double>(
              future: _calcularProgreso(project.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(
                    value: null, // Indeterminate progress
                  );
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error al cargar progreso',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  final progreso = snapshot.data ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: progreso,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progreso: ${(progreso * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

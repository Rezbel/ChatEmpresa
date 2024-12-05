import 'package:chatempresa/modelo/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/SubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Proyecto project;

  const ProjectCard({super.key, required this.project});

  Stream<double> _obtenerProgreso(String projectId) {
    return FirebaseFirestore.instance
        .collection('proyectos')
        .doc(projectId)
        .collection('subtareas')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;

      final totalSubtareas = snapshot.docs.length;
      final completadas = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['estado'] == 'entregada';
      }).length;

      return completadas / totalSubtareas;
    });
  }

  Future<void> _actualizarEstadoProyecto(
      String projectId, String estado) async {
    try {
      await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(projectId)
          .update({'estado': estado});
    } catch (e) {
      print('Error al actualizar el estado del proyecto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubtareasScreen(
              projectId: project.id,
              usuariosDelProyecto: project.usuarios,
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
                Icon(
                  project.estado == 'finalizado'
                      ? Icons.check_circle
                      : Icons.flutter_dash,
                  size: 30,
                  color: project.estado == 'finalizado'
                      ? Colors.green
                      : Colors.black,
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
            Text(
              'Usuarios: ${project.usuarios.length}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha límite: ${project.fechaLimite.toLocal()}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            StreamBuilder<double>(
              stream: _obtenerProgreso(project.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(
                    value: null,
                  );
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error al cargar progreso',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  final progreso = snapshot.data ?? 0.0;
                  final esFinalizado = progreso == 1.0;
                  _actualizarEstadoProyecto(
                      project.id, esFinalizado ? 'finalizado' : 'pendiente');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: progreso,
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progreso: ${(progreso * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
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

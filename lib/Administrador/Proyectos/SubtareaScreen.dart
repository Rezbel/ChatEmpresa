import 'package:chatempresa/Administrador/Proyectos/CrearSubtareaScreen.dart';
import 'package:chatempresa/Administrador/Proyectos/DetallesSubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubtareasScreen extends StatelessWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

  const SubtareasScreen({
    required this.projectId,
    required this.usuariosDelProyecto,
  });

  Future<Map<String, String>> _cargarUsuarios() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where(FieldPath.documentId, whereIn: usuariosDelProyecto)
          .get();

      final mapaUsuarios = <String, String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        mapaUsuarios[doc.id] =
            data['username']?.toString() ?? 'Usuario desconocido';
      }
      return mapaUsuarios;
    } catch (e) {
      print('Error al cargar usuarios: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaciones'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _cargarUsuarios(), // Cargar nombres de usuarios
        builder: (context, snapshotUsuarios) {
          if (snapshotUsuarios.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotUsuarios.hasError || !snapshotUsuarios.hasData) {
            return const Center(
              child: Text('Error al cargar usuarios'),
            );
          }

          final mapaUsuarios = snapshotUsuarios.data!;

          return Column(
            children: [
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('proyectos')
                      .doc(projectId)
                      .collection('subtareas')
                      .get(),
                  builder: (context, snapshotSubtareas) {
                    if (snapshotSubtareas.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshotSubtareas.hasError) {
                      return const Center(
                        child: Text('Error al cargar subtareas'),
                      );
                    } else if (snapshotSubtareas.data == null ||
                        snapshotSubtareas.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No hay subtareas asignadas'),
                      );
                    }

                    final subtareas = snapshotSubtareas.data!.docs;

                    return ListView.builder(
                      itemCount: subtareas.length,
                      itemBuilder: (context, index) {
                        final subtarea =
                            subtareas[index].data() as Map<String, dynamic>;
                        final subtareaId = subtareas[index].id;
                        final usuarioAsignadoId =
                            subtarea['usuarioAsignado'] ?? '';
                        final usuarioAsignado =
                            mapaUsuarios[usuarioAsignadoId] ??
                                'Usuario desconocido';

                        return ListTile(
                          title: Text(subtarea['nombre']),
                          subtitle: Text('Asignado a: $usuarioAsignado'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetallesSubtareaScreen(
                                  subtarea: subtarea,
                                  usuarioAsignado: usuarioAsignado,
                                  projectId: projectId,
                                  subtareaId: subtareaId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrearSubtareaScreen(
                          projectId: projectId,
                          usuariosDelProyecto: usuariosDelProyecto,
                        ),
                      ),
                    );
                  },
                  child: const Text('Crear Subtarea'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

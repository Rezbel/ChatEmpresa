
import 'package:chatempresa/Administrador/Proyectos/SubtareaCard.dart';
import 'package:chatempresa/Empleado/PEDetallesSubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PESubtareasScreen extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

  const PESubtareasScreen({
    required this.projectId,
    required this.usuariosDelProyecto,
  });

  @override
  _PESubtareasScreenState createState() => _PESubtareasScreenState();
}

class _PESubtareasScreenState extends State<PESubtareasScreen> {
  int _itemsMostrarPendientes = 3;
  int _itemsMostrarEntregadas = 3;

  Future<Map<String, String>> _cargarUsuarios() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where(FieldPath.documentId, whereIn: widget.usuariosDelProyecto)
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

  Future<Map<String, dynamic>> _cargarProyecto() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .get();
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error al cargar el proyecto: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Asignaciones', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _cargarProyecto(),
        builder: (context, snapshotProyecto) {
          if (snapshotProyecto.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotProyecto.hasError || !snapshotProyecto.hasData) {
            return const Center(
              child: Text('Error al cargar el proyecto',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final proyecto = snapshotProyecto.data!;
          final descripcion = proyecto['descripcion'] ?? 'Sin descripción';

          return FutureBuilder<Map<String, String>>(
            future: _cargarUsuarios(),
            builder: (context, snapshotUsuarios) {
              if (snapshotUsuarios.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshotUsuarios.hasError ||
                  !snapshotUsuarios.hasData) {
                return const Center(
                  child: Text('Error al cargar usuarios',
                      style: TextStyle(color: Colors.white)),
                );
              }

              final mapaUsuarios = snapshotUsuarios.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proyecto['nombre'],
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descripción:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fecha Límite: ${DateFormat('dd/MM/yy').format(DateTime.parse(proyecto['fechaLimite']))}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('proyectos')
                          .doc(widget.projectId)
                          .collection('subtareas')
                          .snapshots(),
                      builder: (context, snapshotSubtareas) {
                        if (snapshotSubtareas.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshotSubtareas.hasError) {
                          return const Center(
                            child: Text('Error al cargar subtareas',
                                style: TextStyle(color: Colors.white)),
                          );
                        } else if (snapshotSubtareas.data == null ||
                            snapshotSubtareas.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No hay subtareas asignadas',
                                style: TextStyle(color: Colors.white)),
                          );
                        }

                        final subtareas = snapshotSubtareas.data!.docs;

                        // Dividir subtareas en entregadas y no entregadas
                        final subtareasEntregadas = subtareas
                            .where((doc) =>
                                (doc.data() as Map<String, dynamic>)['estado'] ==
                                'entregada')
                            .toList();
                        final subtareasNoEntregadas = subtareas
                            .where((doc) =>
                                (doc.data() as Map<String, dynamic>)['estado'] !=
                                'entregada')
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Subtareas Pendientes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ...subtareasNoEntregadas
                                .take(_itemsMostrarPendientes)
                                .map((subtareaDoc) {
                              final subtarea =
                                  subtareaDoc.data() as Map<String, dynamic>;
                              final subtareaId = subtareaDoc.id;
                              final usuarioAsignadoId =
                                  subtarea['usuarioAsignado'] ?? '';
                              final usuarioAsignado =
                                  mapaUsuarios[usuarioAsignadoId] ??
                                      'Usuario desconocido';

                              return SubtareaCard(
                                nombre: subtarea['nombre'],
                                usuarioAsignado: usuarioAsignado,
                                estado: subtarea['estado'] ?? '',
                                entregada: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PEDetallesSubtareaScreen(
                                        subtarea: subtarea,
                                        usuarioAsignado: usuarioAsignado,
                                        projectId: widget.projectId,
                                        subtareaId: subtareaId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            if (_itemsMostrarPendientes <
                                subtareasNoEntregadas.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _itemsMostrarPendientes += 3;
                                  });
                                },
                                child: const Text('Ver más',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Subtareas Entregadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              ),
                            ),
                            ...subtareasEntregadas
                                .take(_itemsMostrarEntregadas)
                                .map((subtareaDoc) {
                              final subtarea =
                                  subtareaDoc.data() as Map<String, dynamic>;
                              final subtareaId = subtareaDoc.id;
                              final usuarioAsignadoId =
                                  subtarea['usuarioAsignado'] ?? '';
                              final usuarioAsignado =
                                  mapaUsuarios[usuarioAsignadoId] ??
                                      'Usuario desconocido';

                              return SubtareaCard(
                                nombre: subtarea['nombre'],
                                usuarioAsignado: usuarioAsignado,
                                estado: subtarea['estado'] ?? '',
                                entregada: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PEDetallesSubtareaScreen(
                                        subtarea: subtarea,
                                        usuarioAsignado: usuarioAsignado,
                                        projectId: widget.projectId,
                                        subtareaId: subtareaId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            if (_itemsMostrarEntregadas <
                                subtareasEntregadas.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _itemsMostrarEntregadas += 3;
                                  });
                                },
                                child: const Text('Ver más',
                                    style: TextStyle(color: Colors.white)),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

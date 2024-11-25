import 'package:chatempresa/Administrador/Proyectos/CrearSubtareaScreen.dart';
import 'package:chatempresa/Administrador/Proyectos/DetallesSubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubtareasScreen extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

  const SubtareasScreen({
    required this.projectId,
    required this.usuariosDelProyecto,
  });

  @override
  _SubtareasScreenState createState() => _SubtareasScreenState();
}

class _SubtareasScreenState extends State<SubtareasScreen> {
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

  void _mostrarDialogoEditar(BuildContext context, Map<String, dynamic> proyecto) {
  final _nombreController = TextEditingController(text: proyecto['nombre']);
  final _descripcionController = TextEditingController(text: proyecto['descripcion']);
  DateTime? _fechaLimite = proyecto['fechaLimite'] != null
      ? DateTime.parse(proyecto['fechaLimite'])
      : null;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color(0xFF282828), // Fondo oscuro
            title: Text('Editar Proyecto', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nombreController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descripcionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      DateTime? fechaSeleccionada = await showDatePicker(
                        context: context,
                        initialDate: _fechaLimite ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                surface: Colors.black,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: Colors.black,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (fechaSeleccionada != null) {
                        setState(() {
                          _fechaLimite = fechaSeleccionada;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        'Fecha Límite: ${DateFormat('dd/MM/yy').format(_fechaLimite!)}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('proyectos')
                      .doc(widget.projectId)
                      .update({
                    'nombre': _nombreController.text,
                    'descripcion': _descripcionController.text,
                    'fechaLimite': _fechaLimite?.toIso8601String(),
                  });
                  Navigator.pop(context);
                },
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Asignaciones', style: TextStyle(color: Colors.white)),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _cargarProyecto(),
            builder: (context, snapshotProyecto) {
              if (snapshotProyecto.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshotProyecto.hasError || !snapshotProyecto.hasData) {
                return Container();
              }

              final proyecto = snapshotProyecto.data!;
              return IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () => _mostrarDialogoEditar(context, proyecto),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _cargarProyecto(),
        builder: (context, snapshotProyecto) {
          if (snapshotProyecto.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotProyecto.hasError || !snapshotProyecto.hasData) {
            return const Center(
              child: Text('Error al cargar el proyecto', style: TextStyle(color: Colors.white)),
            );
          }

          final proyecto = snapshotProyecto.data!;
          final descripcion = proyecto['descripcion'] ?? 'Sin descripción';

          return FutureBuilder<Map<String, String>>(
            future: _cargarUsuarios(),
            builder: (context, snapshotUsuarios) {
              if (snapshotUsuarios.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshotUsuarios.hasError || !snapshotUsuarios.hasData) {
                return const Center(
                  child: Text('Error al cargar usuarios', style: TextStyle(color: Colors.white)),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Descripción:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fecha Límite: ${DateFormat('dd/MM/yy').format(DateTime.parse(proyecto['fechaLimite']))}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
      .collection('proyectos')
      .doc(widget.projectId)
      .collection('subtareas')
      .snapshots(), // Escucha en tiempo real
                      builder: (context, snapshotSubtareas) {
                        if (snapshotSubtareas.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshotSubtareas.hasError) {
                          return const Center(
                            child: Text('Error al cargar subtareas', style: TextStyle(color: Colors.white)),
                          );
                        } else if (snapshotSubtareas.data == null || snapshotSubtareas.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No hay subtareas asignadas', style: TextStyle(color: Colors.white)),
                          );
                        }

                        final subtareas = snapshotSubtareas.data!.docs;

                        // Dividir las subtareas en entregadas y no entregadas
                        final subtareasEntregadas = subtareas
                            .where((doc) => (doc.data() as Map<String, dynamic>)['estado'] == 'entregada')
                            .toList();
                        final subtareasNoEntregadas = subtareas
                            .where((doc) => (doc.data() as Map<String, dynamic>)['estado'] != 'entregada')
                            .toList();

                        // Ordenar subtareas por fecha límite
                        subtareasNoEntregadas.sort((a, b) {
                          DateTime fechaA = (a.data() as Map<String, dynamic>)['fechaLimite'] != null 
                              ? DateTime.parse((a.data() as Map<String, dynamic>)['fechaLimite']) 
                              : DateTime(2100); // Fecha muy lejana en el futuro si no hay fecha límite
                          DateTime fechaB = (b.data() as Map<String, dynamic>)['fechaLimite'] != null 
                              ? DateTime.parse((b.data() as Map<String, dynamic>)['fechaLimite']) 
                              : DateTime(2100); // Fecha muy lejana en el futuro si no hay fecha límite
                          return fechaA.compareTo(fechaB);
                        });

                        subtareasEntregadas.sort((a, b) {
                                                    DateTime fechaA = (a.data() as Map<String, dynamic>)['fechaLimite'] != null 
                              ? DateTime.parse((a.data() as Map<String, dynamic>)['fechaLimite']) 
                              : DateTime(2100); // Fecha muy lejana en el futuro si no hay fecha límite
                          DateTime fechaB = (b.data() as Map<String, dynamic>)['fechaLimite'] != null 
                              ? DateTime.parse((b.data() as Map<String, dynamic>)['fechaLimite']) 
                              : DateTime(2100); // Fecha muy lejana en el futuro si no hay fecha límite
                          return fechaB.compareTo(fechaA); // Ordenar al revés
                        });

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
                              final subtarea = subtareaDoc.data() as Map<String, dynamic>;
                              final subtareaId = subtareaDoc.id;
                              final usuarioAsignadoId = subtarea['usuarioAsignado'] ?? '';
                              final usuarioAsignado = mapaUsuarios[usuarioAsignadoId] ?? 'Usuario desconocido';

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(subtarea['nombre'], style: TextStyle(color: Colors.black)),
                                  subtitle: Text('Asignado a: $usuarioAsignado', style: TextStyle(color: Colors.black)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetallesSubtareaScreen(
                                          subtarea: subtarea,
                                          usuarioAsignado: usuarioAsignado,
                                          projectId: widget.projectId,
                                          subtareaId: subtareaId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                            if (_itemsMostrarPendientes < subtareasNoEntregadas.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _itemsMostrarPendientes += 3;
                                  });
                                },
                                child: Text('Ver más', style: TextStyle(color: Colors.white)),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Subtareas Entregadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ...subtareasEntregadas
                                .take(_itemsMostrarEntregadas)
                                .map((subtareaDoc) {
                              final subtarea = subtareaDoc.data() as Map<String, dynamic>;
                              final subtareaId = subtareaDoc.id;
                              final usuarioAsignadoId = subtarea['usuarioAsignado'] ?? '';
                              final usuarioAsignado = mapaUsuarios[usuarioAsignadoId] ?? 'Usuario desconocido';

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(subtarea['nombre'], style: TextStyle(color: Colors.black)),
                                  subtitle: Text('Asignado a: $usuarioAsignado', style: TextStyle(color: Colors.black)),
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetallesSubtareaScreen(
                                          subtarea: subtarea,
                                          usuarioAsignado: usuarioAsignado,
                                          projectId: widget.projectId,
                                          subtareaId: subtareaId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                            if (_itemsMostrarEntregadas < subtareasEntregadas.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _itemsMostrarEntregadas += 3;
                                  });
                                },
                                child: Text('Ver más', style: TextStyle(color: Colors.white)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearSubtareaScreen(
                projectId: widget.projectId,
                usuariosDelProyecto: widget.usuariosDelProyecto,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

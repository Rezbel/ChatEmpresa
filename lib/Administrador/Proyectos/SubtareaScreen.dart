import 'package:chatempresa/Administrador/Proyectos/CrearSubtareaScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubtareasScreen extends StatelessWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

  const SubtareasScreen({required this.projectId, required this.usuariosDelProyecto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaciones'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('proyectos')
                  .doc(projectId)
                  .collection('subtareas')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar subtareas'),
                  );
                } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No hay subtareas asignadas'),
                  );
                } else {
                  final subtareas = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: subtareas.length,
                    itemBuilder: (context, index) {
                      final subtarea = subtareas[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(subtarea['nombre']),
                        subtitle: Text('Asignado a: ${subtarea['usuarioAsignado']}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Lógica para agregar una nueva subtarea
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
      ),
    );
  }
}
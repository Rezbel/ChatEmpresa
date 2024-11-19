import 'package:chatempresa/Proyectos/Proyecto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PAPantallaproyectos extends StatelessWidget {
  const PAPantallaproyectos({super.key});

  Future<List<Proyecto>> fetchProjects() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('proyectos').get();
    return querySnapshot.docs
        .map((doc) => Proyecto.fromMap(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'Bater Papo',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF282828),
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
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Activos',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Proyecto>>(
              future: fetchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar proyectos',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay proyectos activos',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final projects = snapshot.data!;
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: projects.map((project) {
                      return ProjectCard(project: project);
                    }).toList(),
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

class ProjectCard extends StatelessWidget {
  final Proyecto project;

  const ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubtareaDialog(
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

class SubtareaDialog extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto; // Lista de usuarios del proyecto

  SubtareaDialog({required this.projectId, required this.usuariosDelProyecto});

  @override
  _SubtareaDialogState createState() => _SubtareaDialogState();
}

class _SubtareaDialogState extends State<SubtareaDialog> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _usuarioAsignado; // Usuario seleccionado para la subtarea

  Future<void> addSubtarea() async {
    final nombre = _nombreController.text;
    final descripcion = _descripcionController.text;

    if (nombre.isNotEmpty && descripcion.isNotEmpty && _usuarioAsignado != null) {
      await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .collection('subtareas')
          .add({
        'nombre': nombre,
        'descripcion': descripcion,
        'usuarioAsignado': _usuarioAsignado,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Subtarea'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre de la subtarea'),
          ),
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          DropdownButton<String>(
            value: _usuarioAsignado,
            hint: const Text('Seleccionar Usuario'),
            onChanged: (String? newValue) {
              setState(() {
                _usuarioAsignado = newValue;
              });
            },
            items: widget.usuariosDelProyecto.map<DropdownMenuItem<String>>((String usuario) {
              return DropdownMenuItem<String>(
                value: usuario,
                child: Text(usuario),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            addSubtarea();
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

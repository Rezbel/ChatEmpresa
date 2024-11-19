import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  final List<Tarea> tareas = [
    Tarea(id: '1', nombre: 'Tarea 1', usuarioAsignado: 'Usuario 1', subtareas: []),
    Tarea(id: '2', nombre: 'Tarea 2', usuarioAsignado: 'Usuario 2', subtareas: []),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tareas')),
      body: ListView.builder(
        itemCount: tareas.length,
        itemBuilder: (context, index) {
          final tarea = tareas[index];
          return ListTile(
            title: Text(tarea.nombre),
            onTap: () {
              // Navegar a la pantalla de detalles de la tarea
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(tarea: tarea),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final Tarea tarea;

  TaskDetailScreen({required this.tarea});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _descripcionController = TextEditingController();

  void _agregarSubtarea() {
    setState(() {
      widget.tarea.subtareas.add(_descripcionController.text);
      _descripcionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuario Asignado: ${widget.tarea.usuarioAsignado}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Subtareas:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.tarea.subtareas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.tarea.subtareas[index]),
                  );
                },
              ),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción de la subtarea',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _agregarSubtarea,
              child: Text('Agregar Subtarea'),
            ),
          ],
        ),
      ),
    );
  }
}

class Tarea {
  String id;
  String nombre;
  String usuarioAsignado;
  List<String> subtareas;

  Tarea({
    required this.id,
    required this.nombre,
    required this.usuarioAsignado,
    required this.subtareas,
  });
}

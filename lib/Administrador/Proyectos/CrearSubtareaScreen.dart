import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrearSubtareaScreen extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

  const CrearSubtareaScreen({required this.projectId, required this.usuariosDelProyecto});

  @override
  _CrearSubtareaScreenState createState() => _CrearSubtareaScreenState();
}

class _CrearSubtareaScreenState extends State<CrearSubtareaScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _usuarioAsignado;

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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Subtarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              items: widget.usuariosDelProyecto
                  .map<DropdownMenuItem<String>>((String usuario) {
                return DropdownMenuItem<String>(
                  value: usuario,
                  child: Text(usuario),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addSubtarea,
              child: const Text('Agregar asignacion'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class CrearSubtareaScreen extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto; // IDs de los usuarios seleccionados

  const CrearSubtareaScreen({
    required this.projectId,
    required this.usuariosDelProyecto,
  });

  @override
  _CrearSubtareaScreenState createState() => _CrearSubtareaScreenState();
}

class _CrearSubtareaScreenState extends State<CrearSubtareaScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _usuarioAsignado;
  Map<String, String> _mapaUsuarios = {}; // UID -> Username
  bool _isLoadingUsuarios = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where(FieldPath.documentId, whereIn: widget.usuariosDelProyecto)
        .get();

    final mapa = <String, String>{}; // Mapa vacío de String a String
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final username = data['username']?.toString() ?? 'Usuario desconocido'; // Aseguramos que sea String
      mapa[doc.id] = username;
    }

    setState(() {
      _mapaUsuarios = mapa;
      _isLoadingUsuarios = false;
    });
  } catch (e) {
    print('Error al cargar usuarios: $e');
    setState(() {
      _isLoadingUsuarios = false;
    });
  }
}


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
        'usuarioAsignado': _usuarioAsignado, // Guardamos el UID
      });
      Navigator.pop(context);
    }
  }

  DateTime? _fechaLimite;

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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (fecha != null) {
                setState(() {
                  _fechaLimite = fecha;
                });
              }
            },
            child: Text(
              _fechaLimite == null
                  ? 'Seleccionar Fecha Límite'
                  : 'Fecha límite: ${_fechaLimite!.toLocal()}'.split(' ')[0],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_nombreController.text.isNotEmpty &&
                  _descripcionController.text.isNotEmpty &&
                  _usuarioAsignado != null &&
                  _fechaLimite != null) {
                await FirebaseFirestore.instance
                    .collection('proyectos')
                    .doc(widget.projectId)
                    .collection('subtareas')
                    .add({
                  'nombre': _nombreController.text,
                  'descripcion': _descripcionController.text,
                  'usuarioAsignado': _usuarioAsignado,
                  'fechaLimite': _fechaLimite!.toIso8601String(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar asignación'),
          ),
        ],
      ),
    ),
  );
}

}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetallesSubtareaScreen extends StatefulWidget {
  final Map<String, dynamic> subtarea;
  final String usuarioAsignado;
  final String projectId;
  final String subtareaId;

  const DetallesSubtareaScreen({
    required this.subtarea,
    required this.usuarioAsignado,
    required this.projectId,
    required this.subtareaId,
  });

  @override
  _DetallesSubtareaScreenState createState() => _DetallesSubtareaScreenState();
}

class _DetallesSubtareaScreenState extends State<DetallesSubtareaScreen> {
  String? _archivoSeleccionado;
  bool _cargandoArchivo = false;

  Future<void> _adjuntarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _archivoSeleccionado = result.files.single.path;
        _cargandoArchivo = true;
      });

      try {
        File file = File(_archivoSeleccionado!);
        String fileName = 'subtareas/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(file);
        String downloadUrl = await storageRef.getDownloadURL();

        // Actualizar Firestore con la URL del archivo
        await FirebaseFirestore.instance
            .collection('proyectos')
            .doc(widget.projectId)
            .collection('subtareas')
            .doc(widget.subtareaId)
            .update({
          'archivoUrl': FieldValue.arrayUnion([downloadUrl])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo subido correctamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el archivo: $e')),
        );
      } finally {
        setState(() {
          _cargandoArchivo = false;
        });
      }
    }
  }

  Future<void> _marcarComoEntregada() async {
    try {
      await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .collection('subtareas')
          .doc(widget.subtareaId)
          .update({'estado': 'entregada'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtarea marcada como entregada.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como entregada: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Asignación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${widget.subtarea['nombre']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Descripción:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.subtarea['descripcion'] ?? 'Sin descripción',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Asignado a:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.usuarioAsignado,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            if (widget.subtarea['archivoUrl'] != null &&
                (widget.subtarea['archivoUrl'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Archivos adjuntos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...((widget.subtarea['archivoUrl'] as List).map((url) => InkWell(
                        onTap: () {
                          // Puedes usar cualquier biblioteca para abrir enlaces
                        },
                        child: Text(
                          url,
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ))),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _adjuntarArchivo,
              icon: Icon(Icons.attach_file),
              label: Text(_cargandoArchivo ? 'Subiendo...' : 'Adjuntar archivo'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _marcarComoEntregada,
              icon: Icon(Icons.check),
              label: Text('Marcar como entregada'),
            ),
          ],
        ),
      ),
    );
  }
}

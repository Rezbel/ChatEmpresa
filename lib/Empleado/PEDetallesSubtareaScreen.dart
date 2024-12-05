import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PEDetallesSubtareaScreen extends StatefulWidget {
  final Map<String, dynamic> subtarea;
  final String usuarioAsignado;
  final String projectId;
  final String subtareaId;

  const PEDetallesSubtareaScreen({
    super.key,
    required this.subtarea,
    required this.usuarioAsignado,
    required this.projectId,
    required this.subtareaId,
  });

  @override
  _PEDetallesSubtareaScreenState createState() => _PEDetallesSubtareaScreenState();
}

class _PEDetallesSubtareaScreenState extends State<PEDetallesSubtareaScreen> {
  String? _archivoSeleccionado;
  bool _cargandoArchivo = false;
  bool _esEntregada = false;

  @override
  void initState() {
    super.initState();
    _esEntregada = widget.subtarea['estado'] == 'entregada';
  }

  Future<void> _adjuntarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _archivoSeleccionado = result.files.single.path;
        _cargandoArchivo = true;
      });

      try {
        File file = File(_archivoSeleccionado!);
        String fileName =
            'subtareas/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
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
          const SnackBar(content: Text('Archivo subido correctamente.')),
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

  // Función para abrir la URL
  Future<void> _abrirArchivo(String url) async {
    // String urlAux = url.replaceFirst('https://', '');
    String urlAux = url;
    if (await canLaunchUrl(Uri.parse(urlAux))) {
      await launchUrl(Uri.parse(urlAux));
    } else {
      print('No se puede abrir la URL xd');
    }
  }

  Future<void> _cambiarEstadoSubtarea() async {
    String nuevoEstado = _esEntregada ? 'pendiente' : 'entregada';
    try {
      await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .collection('subtareas')
          .doc(widget.subtareaId)
          .update({'estado': nuevoEstado});

      setState(() {
        _esEntregada = !_esEntregada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtarea marcada como $nuevoEstado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalles de la Asignación',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${widget.subtarea['nombre']}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              widget.subtarea['descripcion'] ?? 'Sin descripción',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fecha Límite:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              widget.subtarea['fechaLimite'] != null
                  ? DateFormat('dd/MM/yy')
                      .format(DateTime.parse(widget.subtarea['fechaLimite']))
                  : 'Sin fecha límite',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Asignado a:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              widget.usuarioAsignado,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (widget.subtarea['archivoUrl'] != null &&
                (widget.subtarea['archivoUrl'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Archivos adjuntos:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  ...((widget.subtarea['archivoUrl'] as List)
                      .map((url) => InkWell(
                            onTap: () => _abrirArchivo(url),
                            child: Text(
                              url,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ))),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _adjuntarArchivo,
              icon: const Icon(Icons.attach_file, color: Colors.black),
              label: Text(_cargandoArchivo ? 'Subiendo...' : 'Adjuntar archivo',
                  style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cambiarEstadoSubtarea,
              icon: Icon(_esEntregada ? Icons.undo : Icons.check,
                  color: Colors.black),
              label: Text(
                  _esEntregada
                      ? 'Desmarcar como entregada'
                      : 'Marcar como entregada',
                  style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

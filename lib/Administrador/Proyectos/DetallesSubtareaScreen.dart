import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesSubtareaScreen extends StatefulWidget {
  final Map<String, dynamic> subtarea;
  final String usuarioAsignado;
  final String projectId;
  final String subtareaId;

  const DetallesSubtareaScreen({
    super.key,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _mostrarDialogoEditar(context),
          ),
        ],
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

  void _mostrarDialogoEditar(BuildContext context) {
    final nombreController =
        TextEditingController(text: widget.subtarea['nombre']);
    final descripcionController =
        TextEditingController(text: widget.subtarea['descripcion']);
    DateTime? fechaLimite = widget.subtarea['fechaLimite'] != null
        ? DateTime.parse(widget.subtarea['fechaLimite'])
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF282828), // Fondo oscuro
              title: const Text('Editar Subtarea',
                  style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: descripcionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        DateTime? fechaSeleccionada = await showDatePicker(
                          context: context,
                          initialDate: fechaLimite ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
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
                            fechaLimite = fechaSeleccionada;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          fechaLimite != null
                              ? 'Fecha Límite: ${DateFormat('dd/MM/yy').format(fechaLimite!)}'
                              : 'Seleccionar Fecha Límite',
                          style: const TextStyle(color: Colors.white),
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
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('proyectos')
                        .doc(widget.projectId)
                        .collection('subtareas')
                        .doc(widget.subtareaId)
                        .update({
                      'nombre': nombreController.text,
                      'descripcion': descripcionController.text,
                      'fechaLimite': fechaLimite?.toIso8601String(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

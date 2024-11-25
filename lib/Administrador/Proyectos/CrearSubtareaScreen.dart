import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para el formateo de la fecha

class CrearSubtareaScreen extends StatefulWidget {
  final String projectId;
  final List<String> usuariosDelProyecto;

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
  Map<String, String> _mapaUsuarios = {};
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

      final mapa = <String, String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final username = data['username']?.toString() ?? 'Usuario desconocido';
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
        'usuarioAsignado': _usuarioAsignado,
      });
      Navigator.pop(context);
    }
  }

  DateTime? _fechaLimite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0),
            Text(
              'Crear Subtarea',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la subtarea',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _usuarioAsignado,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Usuario',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _usuarioAsignado = newValue;
                      });
                    },
                    items: _mapaUsuarios.entries
                        .map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value, style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
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
                      if (fecha != null) {
                        setState(() {
                          _fechaLimite = fecha;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          _fechaLimite == null
                              ? 'Seleccionar Fecha Límite'
                              : 'Fecha límite: ${DateFormat('dd/MM/yy').format(_fechaLimite!)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                      child: Text('Agregar asignación', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

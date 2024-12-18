import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para el formateo de la fecha

class PAPantallaCrearProyecto extends StatefulWidget {
  @override
  _PAPantallaCrearProyectoState createState() => _PAPantallaCrearProyectoState();
}

class _PAPantallaCrearProyectoState extends State<PAPantallaCrearProyecto> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaLimite;
  List<String> _usuariosSeleccionados = [];
  bool _isLoading = false;

  Future<void> _crearProyecto() async {
    if (_nombreController.text.isEmpty || _fechaLimite == null || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final proyectosRef = FirebaseFirestore.instance.collection('proyectos');
      final nuevoProyectoId = proyectosRef.doc().id;

      await proyectosRef.doc(nuevoProyectoId).set({
        'id': nuevoProyectoId,
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'usuarios': _usuariosSeleccionados,
        'fechaLimite': _fechaLimite!.toIso8601String(),
      });

      await FirebaseFirestore.instance.collection('grupos').doc(nuevoProyectoId).set({
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'usuarios': _usuariosSeleccionados,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'mensajes': [],
      });

      for (String usuarioId in _usuariosSeleccionados) {
        await FirebaseFirestore.instance.collection('usuarios').doc(usuarioId).update({
          'grupos': FieldValue.arrayUnion([nuevoProyectoId]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proyecto creado exitosamente.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al crear proyecto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear proyecto.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
              'Crear Proyecto',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    cursorColor: Colors.black,
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Proyecto',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Borde de las cajas de texto
          ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    cursorColor: Colors.black,
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción del Proyecto',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Borde de las cajas de texto
          ),
                    ),
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
                                primary: Colors.white, // Color del ícono
                                onPrimary: Colors.black, // Color del texto del ícono
                                surface: Colors.black, // Fondo del selector
                                onSurface: Colors.white, // Color del texto
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
                              : 'Modificar Fecha Límite',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_fechaLimite != null)
                    Text(
                      'Fecha Límite: ${DateFormat('dd/MM/yy').format(_fechaLimite!)}',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Seleccionar Usuarios',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('usuarios').get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final usuarios = snapshot.data!.docs;

                      return Column(
                        children: usuarios.map((usuario) {
                          final data = usuario.data() as Map<String, dynamic>;
                          return CheckboxListTile(
                            title: Text(data['username'] ?? 'Usuario desconocido',
                                style: TextStyle(color: Colors.black)),
                            value: _usuariosSeleccionados.contains(usuario.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _usuariosSeleccionados.add(usuario.id);
                                } else {
                                  _usuariosSeleccionados.remove(usuario.id);
                                }
                              });
                            },
                            activeColor: Colors.black, // Fondo negro al seleccionar
                            checkColor: Colors.white, // Palomita blanca
                            tileColor: _usuariosSeleccionados.contains(usuario.id)
                                ? Colors.black.withOpacity(0.1) // Fondo oscuro al seleccionar
                                : Colors.transparent, // Fondo transparente si no está seleccionado
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Esquinas redondeadas
                              side: BorderSide(color: Colors.black), // Borde negro
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _crearProyecto,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Crear Proyecto', style: TextStyle(color: Colors.white)),
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

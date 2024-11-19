import 'package:chatempresa/Proyectos/Proyecto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PAPantallaCrearProyecto extends StatefulWidget {
  @override
  _PAPantallaCrearProyectoState createState() => _PAPantallaCrearProyectoState();
}

class _PAPantallaCrearProyectoState extends State<PAPantallaCrearProyecto> {
  final _nombreController = TextEditingController();
  DateTime? _fechaLimite;
  List<String> _usuariosSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Proyecto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre del Proyecto'),
            ),
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
              child: Text(_fechaLimite == null
                  ? 'Seleccionar Fecha Límite'
                  : 'Fecha Límite: ${_fechaLimite!.toLocal()}'),
            ),
            // Lista para seleccionar usuarios
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('usuarios').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final usuarios = snapshot.data!.docs;

                  return ListView(
                    children: usuarios.map((usuario) {
                      final data = usuario.data() as Map<String, dynamic>;
                      return CheckboxListTile(
                        title: Text(data['username']),
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
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nombreController.text.isNotEmpty && _fechaLimite != null) {
                  crearProyecto(
                    _nombreController.text,
                    _usuariosSeleccionados,
                    _fechaLimite!,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Crear Proyecto'),
            ),
          ],
        ),
      ),
    );
  }




  Future<void> crearProyecto(String nombre, List<String> usuarios, DateTime fechaLimite) async {
  final proyectosRef = FirebaseFirestore.instance.collection('proyectos');
  final nuevoProyecto = Proyecto(
    id: proyectosRef.doc().id,
    nombre: nombre,
    usuarios: usuarios,
    fechaLimite: fechaLimite,
  );

  await proyectosRef.doc(nuevoProyecto.id).set(nuevoProyecto.toMap());

  // Crear grupo de chat automáticamente
  await FirebaseFirestore.instance.collection('grupos').doc(nuevoProyecto.id).set({
    'nombre': nuevoProyecto.nombre,
    'usuarios': usuarios,
    'fechaCreacion': DateTime.now().toIso8601String(),
  });
}
}
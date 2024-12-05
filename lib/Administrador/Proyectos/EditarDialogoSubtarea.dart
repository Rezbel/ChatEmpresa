import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditarDialogoSubtarea extends StatelessWidget {
  final String projectId;
  final String subtareaId;
  final String nombreActual;
  final String descripcionActual;
  final DateTime? fechaLimiteActual;

  const EditarDialogoSubtarea({
    super.key,
    required this.projectId,
    required this.subtareaId,
    required this.nombreActual,
    required this.descripcionActual,
    this.fechaLimiteActual,
  });

  @override
  Widget build(BuildContext context) {
    final nombreController = TextEditingController(text: nombreActual);
    final descripcionController = TextEditingController(text: descripcionActual);
    DateTime? fechaLimite = fechaLimiteActual;

    return AlertDialog(
      backgroundColor: const Color(0xFF282828),
      title: const Text('Editar Subtarea', style: TextStyle(color: Colors.white)),
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
                  fechaLimite = fechaSeleccionada;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('proyectos')
                .doc(projectId)
                .collection('subtareas')
                .doc(subtareaId)
                .update({
              'nombre': nombreController.text,
              'descripcion': descripcionController.text,
              'fechaLimite': fechaLimite?.toIso8601String(),
            });
            Navigator.pop(context);
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

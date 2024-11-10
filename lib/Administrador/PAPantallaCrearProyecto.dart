import 'package:flutter/material.dart';

class PAPantallaCrearProyecto extends StatelessWidget {
  PAPantallaCrearProyecto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'Bater Papo',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Aquí puedes agregar las acciones para el icono
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Proyecto',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            // Aquí puedes agregar más contenido, como formularios, botones, etc.
          ],
        ),
      ),
    );
  }
}
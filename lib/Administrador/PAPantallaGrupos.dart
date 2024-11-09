import 'package:flutter/material.dart';

class PAPantallaGrupos extends StatelessWidget {
  const PAPantallaGrupos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Fondo oscuro para la pantalla de chat.
      appBar: AppBar(
        title: Text('Bater Papo', style: TextStyle(fontSize: 20,
        color: Colors.white),),
        backgroundColor: Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...', // Texto de sugerencia en el campo de búsqueda.
                filled: true, // Llena el fondo del campo de texto.
                fillColor: Colors.grey[800], // Color de fondo del campo de búsqueda.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados.
                  borderSide: BorderSide.none, // Sin borde visible.
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey), // Icono de búsqueda.
              ),
            ),
          ),
         
        ],
      ),
    );
  }
}



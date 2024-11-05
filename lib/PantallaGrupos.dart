import 'package:chatempresa/ChatItem.dart';
import 'package:flutter/material.dart';

class PantallaGrupos extends StatelessWidget {
  const PantallaGrupos({super.key});

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
          Expanded(
            child: ListView(
              children: [
                // Elementos de chat con nombre, mensaje, hora, y número de notificaciones.
                ChatItem(name: 'Rodrigo Gestor', message: '💬 Sí, gracias', time: '11:59'),
                ChatItem(name: 'Natalia C', message: '📆 Para el jueves', time: '11:48', notificationCount: 1),
                ChatItem(name: 'Inge Nata', message: '💬 ¿Pudiste arreglarlo?', time: '11:36'),
                ChatItem(name: 'Lic Peso Pluma', message: 'Vamos a chambear', time: '11:32'),
                ChatItem(name: 'Sofia F', message: 'Mañana con más calma', time: '10:57'),
                ChatItem(name: 'Eduardo J', message: '📆 Ahorita no, joven', time: '08:48'),
                ChatItem(name: 'JH', message: '💬 Está bien', time: 'Ayer'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



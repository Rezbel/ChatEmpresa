import 'package:flutter/material.dart';

// Función principal que ejecuta la aplicación.
void main() {
  runApp(MyApp());
}

// Widget principal de la aplicación.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de debug en la esquina superior.
      home: ChatScreen(), // Define la pantalla principal.
    );
  }
}

// Pantalla principal del chat.
class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Fondo oscuro para la pantalla de chat.
      appBar: AppBar(
        title: Text('Bater Papo', style: TextStyle(fontSize: 20)), // Título de la AppBar.
        backgroundColor: Colors.black87, // Color de fondo de la AppBar.
        elevation: 0, // Elimina la sombra de la AppBar.
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert), // Icono de opciones en la AppBar.
            onPressed: () {}, // Acción vacía para el botón.
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850], // Fondo oscuro para la barra de navegación inferior.
        selectedItemColor: Colors.white, // Color del ítem seleccionado.
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados.
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), // Icono para "Chats".
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group), // Icono para "Grupos".
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // Icono para "Proyectos".
            label: 'Proyectos',
          ),
        ],
      ),
    );
  }
}

// Widget para cada elemento individual de chat en la lista.
class ChatItem extends StatelessWidget {
  final String name; // Nombre del contacto o grupo.
  final String message; // Último mensaje.
  final String time; // Hora del último mensaje.
  final int notificationCount; // Número de notificaciones no leídas.

  const ChatItem({
    Key? key,
    required this.name,
    required this.message,
    required this.time,
    this.notificationCount = 0, // Valor predeterminado de notificaciones.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Espacio alrededor del ítem.
      padding: EdgeInsets.all(10), // Espacio interno del ítem.
      decoration: BoxDecoration(
        color: Colors.blueGrey[100], // Fondo de cada chat.
        borderRadius: BorderRadius.circular(10), // Bordes redondeados.
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey, // Fondo del avatar.
            child: Text(name[0], style: TextStyle(color: Colors.white)), // Inicial del nombre.
          ),
          SizedBox(width: 10), // Espacio entre el avatar y el contenido del chat.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda.
              children: [
                Text(
                  name, // Nombre del contacto o grupo.
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  message, // Último mensaje enviado o recibido.
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(time, style: TextStyle(color: Colors.black54)), // Hora del mensaje.
              if (notificationCount > 0) // Muestra el contador solo si hay notificaciones.
                Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Fondo de la burbuja de notificación.
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$notificationCount', // Número de notificaciones no leídas.
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

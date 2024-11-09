import 'package:flutter/material.dart';

class PAPantallaAdmin extends StatelessWidget {
  const PAPantallaAdmin({super.key});

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
          Text("putas")
         
        ],
      ),
    );
  }
}



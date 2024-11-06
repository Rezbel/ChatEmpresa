import 'package:chatempresa/ChatItem.dart';
import 'package:flutter/material.dart';

class Pantallachat extends StatefulWidget {
  const Pantallachat({super.key});

  @override
  State<Pantallachat> createState() => _PantallachatState();
}

class _PantallachatState extends State<Pantallachat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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
                hintText: 'Buscar...',
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
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
import 'package:chatempresa/Administrador/ChatsList.dart';
import 'package:chatempresa/Administrador/Grupolist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PAPantallachat extends StatefulWidget {
  const PAPantallachat({super.key});

  @override
  State<PAPantallachat> createState() => _PAPantallachatState();
}

class _PAPantallachatState extends State<PAPantallachat> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool showChats = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'Bater Papo',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showChats = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showChats ? Colors.white : Colors.grey,
                  ),
                  child: Text(
                    'Chats',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showChats = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showChats ? Colors.grey : Colors.white,
                  ),
                  child: Text(
                    'Grupos',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                filled: true,
                fillColor: Color(0xFFE6EFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Expanded(
  child: showChats 
      ? ChatsList(currentUser: currentUser) 
      : GruposList(currentUserId: currentUser?.uid ?? ''),
),

        ],
      ),
    );
  }
}

import 'package:chatempresa/Administrador/PAChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            child: showChats ? ChatsList(currentUser: currentUser) : GruposList(),
          ),
        ],
      ),
    );
  }
}

class ChatsList extends StatelessWidget {
  final User? currentUser;

  ChatsList({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs
            .where((user) => user.id != currentUser!.uid)
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Añadir márgenes para separación
              decoration: BoxDecoration(
                color: Color(0xFFE6EFFF), // Color de fondo de la cajita de mensaje
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user['name'],
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Último mensaje...',
                  style: TextStyle(color: Colors.black54),
                ),
                trailing: Text(
                  'Hora',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PAChatScreen(
                        currentUserId: currentUser!.uid,
                        otherUserId: user.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class GruposList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí agregas el contenido de la pantalla de grupos
    return ListView.builder(
      itemCount: 10, // Reemplazar con la cantidad real de grupos
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Añadir márgenes para separación
          decoration: BoxDecoration(
            color: Color(0xFFE6EFFF), // Color de fondo de la cajita de mensaje
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.group, color: Colors.white),
            ),
            title: Text(
              'Grupo ${index + 1}', // Reemplazar con el nombre del grupo real
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Último mensaje del grupo...',
              style: TextStyle(color: Colors.black54),
            ),
            trailing: Text(
              'Hora',
              style: TextStyle(color: Colors.black54),
            ),
            onTap: () {
              // Agregar lógica de navegación al chat del grupo
            },
          ),
        );
      },
    );
  }
}

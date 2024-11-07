
import 'package:chatempresa/Empleado/ChatService%20.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Pantallachat extends StatefulWidget {
  const Pantallachat({super.key});

  @override
  State<Pantallachat> createState() => _PantallachatState();
}

class _PantallachatState extends State<Pantallachat> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        backgroundColor: Color(0xFF282828),
      ),
      body: StreamBuilder<QuerySnapshot>(   
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs.where((user) => user.id != currentUser!.uid).toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUserId: currentUser!.uid,
                        otherUserId: user.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

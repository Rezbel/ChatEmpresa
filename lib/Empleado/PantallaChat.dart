import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:chatempresa/modelo/PAChatScreen.dart';
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
  String searchQuery = "";

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Cerrar sesión') {
                _signOut(context);
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Cerrar sesión',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                filled: true,
                fillColor: const Color(0xFFE6EFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                hintStyle: const TextStyle(color: Colors.black),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtrar usuarios según la búsqueda
                var users = snapshot.data!.docs.where((user) {
                  var username =
                      (user['username'] ?? '').toString().toLowerCase();
                  return user.id != currentUser!.uid &&
                      username.contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron usuarios.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['username'] ?? 'Sin nombre',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Último mensaje aquí',
                          style: TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black54),
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
            ),
          ),
        ],
      ),
    );
  }
}

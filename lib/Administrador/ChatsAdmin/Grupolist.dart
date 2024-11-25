import 'package:chatempresa/Administrador/ChatsAdmin/GrupoChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GruposList extends StatefulWidget {
  final String currentUserId;

  GruposList({required this.currentUserId});

  @override
  _GruposListState createState() => _GruposListState();
}

class _GruposListState extends State<GruposList> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            cursorColor: Colors.black,
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
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        // Group List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('grupos')
                .where('usuarios', arrayContains: widget.currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              final grupos = snapshot.data!.docs.where((doc) {
                final groupName =
                    (doc['nombre'] ?? '').toString().toLowerCase();
                return groupName.contains(searchQuery);
              }).toList();

              if (grupos.isEmpty) {
                return Center(child: Text('No se encontraron resultados.'));
              }

              return ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupoData =
                      grupos[index].data() as Map<String, dynamic>;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6EFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.group, color: Colors.white),
                      ),
                      title: Text(
                        grupoData['nombre'] ?? 'Grupo',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Último mensaje...',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GrupoChatScreen(
                              groupId: grupos[index].id,
                              groupName: grupoData['nombre'] ?? 'Grupo',
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
    );
  }
}

import 'package:chatempresa/Administrador/GrupoChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GruposList extends StatelessWidget {
  final String currentUserId;

  GruposList({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grupos').where(
        'usuarios', arrayContains: currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final grupos = snapshot.data!.docs;
        return ListView.builder(
          itemCount: grupos.length,
          itemBuilder: (context, index) {
            final grupoData = grupos[index].data() as Map<String, dynamic>;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFFE6EFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.group, color: Colors.white),
                ),
                title: Text(
                  grupoData['nombre'] ?? 'Grupo',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
    );
  }
}

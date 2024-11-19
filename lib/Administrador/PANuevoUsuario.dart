import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PANuevoUsuario extends StatefulWidget {
  const PANuevoUsuario({super.key});

  @override
  _PANuevoUsuarioState createState() => _PANuevoUsuarioState();
}

class _PANuevoUsuarioState extends State<PANuevoUsuario> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para actualizar el rol del usuario
  Future<void> _updateUserRole(String userId, String role) async {
    await _firestore.collection('usuarios').doc(userId).update({'role': role});
  }

  // Construye un ListTile para cada usuario
  Widget _buildListTile(DocumentSnapshot user) {
    var userId = user.id;
    var nombreapellido = '${user['name']} ${user['surname']}';
    var usuario = user['username'];
    var rolusuario = user['role']; // Cambiado 'role' a 'rol' para que coincida con Firestore

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreapellido,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              usuario,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Rol actual: $rolusuario',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateUserRole(userId, 'administrador');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor: Colors.blueAccent,
                    elevation: 10,
                  ),
                  child: Text('Administrador'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateUserRole(userId, 'empleado');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor: Colors.greenAccent,
                    elevation: 10,
                  ),
                  child: Text('Empleado'),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        iconTheme: IconThemeData( color: Colors.white),
        title: Text('Empleados',
        style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
      body: StreamBuilder(
        // Cambiado el nombre de la colección a 'usuarios' para coincidir con Firestore
        stream: _firestore.collection('usuarios').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildListTile(users[index]);
            },
          );
        },
      ),
    );
  }
}

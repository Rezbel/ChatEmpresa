import 'package:chatempresa/Administrador/Proyectos/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/ProyectoCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PAPantallaproyectos extends StatelessWidget {
  const PAPantallaproyectos({super.key});

  Future<List<Proyecto>> fetchProjects() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('proyectos').get();
    return querySnapshot.docs
        .map((doc) => Proyecto.fromMap(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Activos',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Proyecto>>(
              future: fetchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar proyectos',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay proyectos activos',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final projects = snapshot.data!;
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: projects.map((project) {
                      return ProjectCard(project: project);
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
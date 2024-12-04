import 'package:chatempresa/Administrador/Proyectos/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/ProyectoCard.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PAPantallaproyectos extends StatefulWidget {
  const PAPantallaproyectos({super.key});

  @override
  _PAPantallaproyectosState createState() => _PAPantallaproyectosState();
}

class _PAPantallaproyectosState extends State<PAPantallaproyectos> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _filterProjects(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Stream<List<Proyecto>> _getProyectosStream() {
    return FirebaseFirestore.instance.collection('proyectos').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return Proyecto.fromMap(doc.data());
        }).toList();
      },
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _openMeetingLink() async {
    const url = 'https://meet.google.com/landing';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('No se puede abrir la URL xd $url');
    }
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
              } else if (value == 'Agendar reunión') {
                _openMeetingLink();
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Cerrar sesión',
                child: Text('Cerrar sesión'),
              ),
              const PopupMenuItem<String>(
                value: 'Agendar reunión',
                child: Text('Agendar reunión'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              cursorColor: Colors.black,
              controller: _searchController,
              onChanged: _filterProjects,
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
            Expanded(
              child: StreamBuilder<List<Proyecto>>(
                stream: _getProyectosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error al cargar proyectos',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay proyectos disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final allProjects = snapshot.data!;
                  final activeProjects = allProjects
                      .where((p) => p.estado != 'finalizado')
                      .where((p) => p.nombre
                          .toLowerCase()
                          .contains(_searchQuery)) // Filtro por búsqueda
                      .toList();
                  final finalizedProjects = allProjects
                      .where((p) => p.estado == 'finalizado')
                      .where((p) => p.nombre
                          .toLowerCase()
                          .contains(_searchQuery)) // Filtro por búsqueda
                      .toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activos',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        activeProjects.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay proyectos activos',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: activeProjects
                                    .map((project) =>
                                        ProjectCard(project: project))
                                    .toList(),
                              ),
                        const SizedBox(height: 16),
                        const Text(
                          'Finalizados',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        finalizedProjects.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay proyectos finalizados',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: finalizedProjects
                                    .map((project) =>
                                        ProjectCard(project: project))
                                    .toList(),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

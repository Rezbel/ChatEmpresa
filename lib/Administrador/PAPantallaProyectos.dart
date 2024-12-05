import 'package:chatempresa/modelo/Proyecto.dart';
import 'package:chatempresa/Administrador/Proyectos/ProyectoCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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

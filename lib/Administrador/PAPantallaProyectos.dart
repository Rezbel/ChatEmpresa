import 'package:chatempresa/Administrador/Proyectos/Proyecto.dart';
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
  List<Proyecto> _allProjects = [];
  List<Proyecto> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('proyectos').get();
    List<Proyecto> projects = querySnapshot.docs
        .map((doc) => Proyecto.fromMap(doc.data()))
        .toList();
    setState(() {
      _allProjects = projects;
      _filteredProjects = projects;
    });
  }

  // Función para filtrar los proyectos por el inicio del nombre
  void _filterProjects(String query) {
    final filtered = _allProjects.where((project) {
      // Filtrar solo si el nombre comienza con el texto ingresado
      return project.nombre.toLowerCase().startsWith(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredProjects = filtered;
    });
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
      body: SingleChildScrollView( // Aquí se envuelve el cuerpo para hacerlo desplazable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _filterProjects, // Filtrar proyectos mientras se escribe
              decoration: InputDecoration(
                hintText: 'Buscar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
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
            // Muestra los proyectos filtrados
            _filteredProjects.isEmpty
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
                    children: _filteredProjects.map((project) {
                      return ProjectCard(project: project);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
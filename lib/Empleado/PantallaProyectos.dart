import 'package:flutter/material.dart';


class Pantallaproyectos extends StatelessWidget {
  const Pantallaproyectos({super.key});
  @override


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Bater Papo', style: TextStyle(fontSize: 20,
        color: Colors.white),),
        backgroundColor: Color(0xFF282828),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proyectos',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 16),
            Text(
              'Activos',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ProjectCard(
                    projectName: 'Proyecto #1',
                    tasks: 14,
                    progress: 0.7,
                    deliveryDate: '15/01/2025',
                  ),
                  ProjectCard(
                    projectName: 'Proyecto #2',
                    tasks: 5,
                    progress: 0.3,
                    deliveryDate: '06/12/2024',
                  ),
                  ProjectCard(
                    projectName: 'Proyecto #4',
                    tasks: 1,
                    progress: 0.1,
                    deliveryDate: '07/10/2025',
                  ),
                  ProjectCard(
                    projectName: 'Proyecto #5',
                    tasks: 22,
                    progress: 0.5,
                    deliveryDate: '24/03/2025',
                  ),
                ],
              ),
            ),
            Text(
              'Inactivos (0)',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String projectName;
  final int tasks;
  final double progress;
  final String deliveryDate;

  const ProjectCard({
    required this.projectName,
    required this.tasks,
    required this.progress,
    required this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flutter_dash,
                size: 30,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                projectName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Tareas pendientes: $tasks'),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Progreso:'),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Fecha de entrega: $deliveryDate'),
        ],
      ),
    );
  }
}

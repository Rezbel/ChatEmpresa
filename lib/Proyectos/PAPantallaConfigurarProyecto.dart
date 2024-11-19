import 'package:chatempresa/Proyectos/Proyecto.dart';
import 'package:flutter/material.dart';

class PAPantallaConfigurarProyecto extends StatelessWidget {
  final Proyecto proyecto;

  PAPantallaConfigurarProyecto({required this.proyecto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar ${proyecto.nombre}'),
      ),
      body: Column(
        children: [
          // Mostrar detalles del proyecto
          Text('Fecha Límite: ${proyecto.fechaLimite}'),
          // Agregar actividades
          ElevatedButton(
            onPressed: () {
              // Navegar a una pantalla para agregar actividades
            },
            child: Text('Agregar Actividad'),
          ),
        ],
      ),
    );
  }
}

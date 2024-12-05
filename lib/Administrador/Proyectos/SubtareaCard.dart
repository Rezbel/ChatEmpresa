import 'package:flutter/material.dart';

class SubtareaCard extends StatelessWidget {
  final String nombre;
  final String usuarioAsignado;
  final String estado;
  final VoidCallback onTap;
  final bool entregada;

  const SubtareaCard({
    required this.nombre,
    required this.usuarioAsignado,
    required this.estado,
    required this.onTap,
    this.entregada = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(nombre, style: const TextStyle(color: Colors.black)),
        subtitle: Text('Asignado a: $usuarioAsignado',
            style: const TextStyle(color: Colors.black)),
        trailing: entregada
            ? const Icon(Icons.check_circle, color: Colors.black)
            : null,
        onTap: onTap,
      ),
    );
  }
}

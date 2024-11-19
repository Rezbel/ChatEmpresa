class Actividad {
  String id;
  String nombre;
  String usuarioAsignado; // ID del usuario asignado
  DateTime fechaEntrega;

  Actividad({
    required this.id,
    required this.nombre,
    required this.usuarioAsignado,
    required this.fechaEntrega,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuarioAsignado': usuarioAsignado,
      'fechaEntrega': fechaEntrega.toIso8601String(),
    };
  }

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id: map['id'],
      nombre: map['nombre'],
      usuarioAsignado: map['usuarioAsignado'],
      fechaEntrega: DateTime.parse(map['fechaEntrega']),
    );
  }
}

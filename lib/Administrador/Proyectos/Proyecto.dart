class Proyecto {
  String id;
  String nombre;
  List<String> usuarios; // IDs de los usuarios
  DateTime fechaLimite;
  String descripcion;
  String estado; // Nuevo atributo para el estado del proyecto

  Proyecto({
    required this.id,
    required this.nombre,
    required this.usuarios,
    required this.fechaLimite,
    required this.descripcion,
    this.estado = 'activo', // Estado predeterminado como 'activo'
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuarios': usuarios,
      'fechaLimite': fechaLimite.toIso8601String(),
      'descripcion': descripcion,
      'estado': estado, // Agregar estado al mapa
    };
  }

  factory Proyecto.fromMap(Map<String, dynamic> map) {
    return Proyecto(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      usuarios: List<String>.from(map['usuarios'] ?? []),
      fechaLimite: map['fechaLimite'] != null ? DateTime.parse(map['fechaLimite']) : DateTime.now(),
      descripcion: map['descripcion'] ?? '', // Proveer valor predeterminado si es null
      estado: map['estado'] ?? 'activo', // Proveer valor predeterminado para el estado
    );
  }
}

class Proyecto {
  String id;
  String nombre;
  List<String> usuarios; // IDs de los usuarios
  DateTime fechaLimite;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.usuarios,
    required this.fechaLimite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuarios': usuarios,
      'fechaLimite': fechaLimite.toIso8601String(),
    };
  }

  factory Proyecto.fromMap(Map<String, dynamic> map) {
    return Proyecto(
      id: map['id'],
      nombre: map['nombre'],
      usuarios: List<String>.from(map['usuarios']),
      fechaLimite: DateTime.parse(map['fechaLimite']),
    );
  }
}



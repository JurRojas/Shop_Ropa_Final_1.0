class Usuario {
  final int id;
  final String nombre;
  final String tipo;

  Usuario({required this.id, required this.nombre, required this.tipo});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}

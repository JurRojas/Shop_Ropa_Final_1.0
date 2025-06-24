class Usuario {
  final int id;
  final String nombre;
  final String tipo;
  final String? email;

  Usuario({required this.id, required this.nombre, required this.tipo, this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      email: json['email'],
    );
  }
}

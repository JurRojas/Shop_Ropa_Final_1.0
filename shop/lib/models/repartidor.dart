class Repartidor {
  final int id;
  final String nombre;
  final String telefono;
  final String email;

  Repartidor(
      {required this.id,
      required this.nombre,
      required this.telefono,
      required this.email});

  factory Repartidor.fromJson(Map<String, dynamic> json) {
    return Repartidor(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }
}

class Tarjeta {
  final int id;
  final String numero;
  final String nombre;
  final String vencimiento;

  Tarjeta({required this.id, required this.numero, required this.nombre, required this.vencimiento});

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'],
      numero: json['numero'],
      nombre: json['nombre'],
      vencimiento: json['vencimiento'],
    );
  }
}

class Pago {
  final int id;
  final int pedidoId;

  Pago({required this.id, required this.pedidoId});

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      pedidoId: json['pedido_id'],
    );
  }
}

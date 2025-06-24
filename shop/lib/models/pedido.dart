class Pedido {
  final int id;
  final int clienteId;
  final String estado;
  final double total;
  final DateTime fecha;
  final List<DetallePedido> detalles;
  final int? repartidorId;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.estado,
    required this.total,
    required this.fecha,
    required this.detalles,
    this.repartidorId,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      clienteId: json['cliente_id'],
      estado: json['estado'],
      total: (json['total'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
      detalles: (json['detalles'] as List<dynamic>).map((d) => DetallePedido.fromJson(d)).toList(),
      repartidorId: json['repartidor_id'],
    );
  }
}

class DetallePedido {
  final int productoId;
  final int cantidad;

  DetallePedido({required this.productoId, required this.cantidad});

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      productoId: json['producto_id'],
      cantidad: json['cantidad'],
    );
  }
}

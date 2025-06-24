import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

const String ESTADO_EN_REPARTO = 'en reparto';
const String ESTADO_ENTREGADO = 'entregado';
const String ESTADO_RECIBIDO = 'recibido';

class RepartidorPedidosScreen extends StatefulWidget {
  final int repartidorId;
  const RepartidorPedidosScreen({super.key, required this.repartidorId});

  @override
  State<RepartidorPedidosScreen> createState() => _RepartidorPedidosScreenState();
}

class _RepartidorPedidosScreenState extends State<RepartidorPedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = PedidoService().fetchPedidosRepartidor(context, widget.repartidorId);
  }

  void _refrescar() {
    setState(() {
      _pedidosFuture = PedidoService().fetchPedidosRepartidor(context, widget.repartidorId);
    });
  }

  Future<void> _cambiarEstado(Pedido pedido, String nuevoEstado) async {
    final exito = await PedidoService().cambiarEstadoPedido(context, pedido.id, nuevoEstado);
    if (exito) {
      _refrescar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a $nuevoEstado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar estado'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos Asignados')),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar pedidos'));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return const Center(child: Text('No tienes pedidos asignados.'));
          }
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Pedido #${pedido.id}'),
                  subtitle: Text('Estado: ${pedido.estado}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (estado) => _cambiarEstado(pedido, estado),
                    itemBuilder: (context) => [
                      if (pedido.estado != ESTADO_EN_REPARTO)
                        const PopupMenuItem(value: ESTADO_EN_REPARTO, child: Text('Marcar en reparto')),
                      if (pedido.estado != ESTADO_ENTREGADO)
                        const PopupMenuItem(value: ESTADO_ENTREGADO, child: Text('Marcar entregado')),
                      if (pedido.estado != ESTADO_RECIBIDO)
                        const PopupMenuItem(value: ESTADO_RECIBIDO, child: Text('Marcar recibido')),
                    ],
                    icon: const Icon(Icons.edit, color: Colors.indigo),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refrescar,
        child: const Icon(Icons.refresh),
        tooltip: 'Refrescar',
      ),
    );
  }
}

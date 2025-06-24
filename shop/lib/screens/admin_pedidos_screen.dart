import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import 'asignar_repartidor_screen.dart';

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = PedidoService().fetchTodosPedidos(context);
  }

  void _refrescar() {
    setState(() {
      _pedidosFuture = PedidoService().fetchTodosPedidos(context);
    });
  }

  Future<void> _asignarRepartidor(Pedido pedido) async {
    final asignado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AsignarRepartidorScreen(pedido: pedido)),
    );
    if (asignado == true) _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Pedidos')),
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
            return const Center(child: Text('No hay pedidos registrados.'));
          }
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Pedido #${pedido.id} - Cliente: ${pedido.clienteId}'),
                  subtitle: Text('Total: ${pedido.total.toStringAsFixed(2)}\nEstado: ${pedido.estado}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delivery_dining, color: Colors.indigo),
                    onPressed: () => _asignarRepartidor(pedido),
                  ),
                  onTap: () {
                    // TODO: Mostrar detalles del pedido
                  },
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

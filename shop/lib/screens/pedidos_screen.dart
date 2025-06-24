import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final PedidoService _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  void _cargarPedidos() async {
    try {
      // TODO: Reemplazar por el id real del cliente autenticado
      final pedidos = await _pedidoService.fetchPedidosCliente(1);
      setState(() {
        _pedidos = pedidos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los pedidos';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : _pedidos.isEmpty
                  ? Center(child: Text('No tienes pedidos'))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = _pedidos[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text('Pedido #${pedido.id}'),
                            subtitle: Text('Estado: ${pedido.estado}\nTotal: \$${pedido.total.toStringAsFixed(2)}'),
                            trailing: Text('${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}'),
                          ),
                        );
                      },
                    ),
    );
  }
}

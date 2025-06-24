import 'package:flutter/material.dart';
import '../models/pago.dart';
import '../services/pago_service.dart';

class AdminPagosScreen extends StatefulWidget {
  const AdminPagosScreen({super.key});

  @override
  State<AdminPagosScreen> createState() => _AdminPagosScreenState();
}

class _AdminPagosScreenState extends State<AdminPagosScreen> {
  List<Pago> _pagos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    setState(() { _loading = true; });
    try {
      final lista = await PagoService().listarPagos(context);
      setState(() {
        _pagos = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar pagos';
        _loading = false;
      });
    }
  }

  void _eliminarPago(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: const Text('¿Seguro que deseas eliminar este pago?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado == true) {
      await PagoService().eliminarPago(context, id);
      _cargarPagos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Pagos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _pagos.length,
                  itemBuilder: (ctx, i) {
                    final p = _pagos[i];
                    return ListTile(
                      title: Text('Pago #${p.id}'),
                      subtitle: Text('Pedido: ${p.pedidoId}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminarPago(p.id),
                      ),
                    );
                  },
                ),
    );
  }
}

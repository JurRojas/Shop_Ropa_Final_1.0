import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/repartidor.dart';
import '../services/pedido_service.dart';
import '../services/repartidor_service.dart';

class AsignarRepartidorScreen extends StatefulWidget {
  final Pedido pedido;
  const AsignarRepartidorScreen({super.key, required this.pedido});

  @override
  State<AsignarRepartidorScreen> createState() => _AsignarRepartidorScreenState();
}

class _AsignarRepartidorScreenState extends State<AsignarRepartidorScreen> {
  late Future<List<Repartidor>> _repartidoresFuture;
  int? _repartidorSeleccionado;
  bool _loading = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _repartidoresFuture = RepartidorService().fetchRepartidores(context);
    _repartidorSeleccionado = widget.pedido.repartidorId;
  }

  Future<void> _asignar() async {
    if (_repartidorSeleccionado == null) return;
    setState(() => _loading = true);
    final exito = await PedidoService().asignarRepartidor(context, widget.pedido.id, _repartidorSeleccionado!);
    setState(() => _loading = false);
    if (exito) {
      Navigator.pop(context, true);
    } else {
      setState(() => _mensaje = 'Error al asignar repartidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Repartidor')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FutureBuilder<List<Repartidor>>(
              future: _repartidoresFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Error al cargar repartidores');
                }
                final repartidores = snapshot.data ?? [];
                if (repartidores.isEmpty) {
                  return const Text('No hay repartidores registrados.');
                }
                return DropdownButtonFormField<int>(
                  value: _repartidorSeleccionado,
                  items: repartidores.map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(r.nombre),
                  )).toList(),
                  onChanged: (v) => setState(() => _repartidorSeleccionado = v),
                  decoration: const InputDecoration(labelText: 'Repartidor'),
                );
              },
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _asignar,
                    child: const Text('Asignar'),
                  ),
            if (_mensaje != null) ...[
              const SizedBox(height: 16),
              Text(_mensaje!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

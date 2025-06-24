import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../providers/auth_provider.dart';
import 'pago_screen.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

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
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final clienteId = auth.usuario.id;
      final pedidos = await _pedidoService.fetchPedidosCliente(context, clienteId);
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
                        Color estadoColor;
                        switch (pedido.estado) {
                          case 'pendiente':
                            estadoColor = Colors.orange;
                            break;
                          case 'pagado':
                            estadoColor = Colors.green;
                            break;
                          case 'enviado':
                            estadoColor = Colors.blue;
                            break;
                          case 'recibido':
                            estadoColor = Colors.purple;
                            break;
                          default:
                            estadoColor = Colors.grey;
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.indigo.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 22),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.indigo.shade100,
                                          child: const Icon(Icons.receipt_long, color: Colors.indigo, size: 26),
                                          radius: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Pedido #${pedido.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                      ],
                                    ),
                                    Chip(
                                      label: Text(pedido.estado.toUpperCase()),
                                      backgroundColor: estadoColor.withOpacity(0.18),
                                      labelStyle: TextStyle(color: estadoColor, fontWeight: FontWeight.bold, fontSize: 14),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      avatar: Icon(
                                        pedido.estado == 'pendiente'
                                            ? Icons.hourglass_empty
                                            : pedido.estado == 'pagado'
                                                ? Icons.check_circle
                                                : pedido.estado == 'enviado'
                                                    ? Icons.local_shipping
                                                    : pedido.estado == 'recibido'
                                                        ? Icons.home
                                                        : Icons.info,
                                        color: estadoColor,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money, color: Colors.green, size: 22),
                                    const SizedBox(width: 4),
                                    Text('Total: ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                    Text('${pedido.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.indigo, size: 18),
                                    const SizedBox(width: 4),
                                    Text('Fecha: ${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}', style: const TextStyle(color: Colors.black54, fontSize: 15)),
                                  ],
                                ),
                                if (pedido.detalles.isNotEmpty) ...[
                                  const Divider(height: 24, thickness: 1.1),
                                  Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo.shade700)),
                                  const SizedBox(height: 4),
                                  ...pedido.detalles.map<Widget>((d) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 18),
                                              const SizedBox(width: 4),
                                              Text('Producto #${d.productoId}', style: const TextStyle(fontSize: 15)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          child: Text('x${d.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                                if (pedido.estado == 'pendiente')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final resultado = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PagoScreen(
                                                pedidoId: pedido.id,
                                                total: pedido.total,
                                                onPagoExitoso: () {
                                                  Navigator.pop(context, true);
                                                },
                                              ),
                                            ),
                                          );
                                          if (resultado == true) {
                                            _cargarPedidos();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('¡Pago realizado exitosamente!'),
                                                backgroundColor: Colors.green[700],
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.payment, color: Colors.white),
                                        label: const Text('Proceder al pago', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 17, 11, 70),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          elevation: 3,
                                          textStyle: const TextStyle(letterSpacing: 1.1),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

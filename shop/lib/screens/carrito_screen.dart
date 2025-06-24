import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../providers/auth_provider.dart';
import '../services/pedido_service.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Carrito'),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: carrito.items.isEmpty
          ? Center(child: Text('El carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: carrito.items.length,
                    itemBuilder: (context, index) {
                      final item = carrito.items[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: item.producto.imagenUrl != null && item.producto.imagenUrl!.isNotEmpty
                              ? Image.network(item.producto.imagenUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.image, size: 50, color: Colors.indigo),
                          title: Text(item.producto.nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio: \$${item.producto.precio.toStringAsFixed(2)}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => carrito.quitar(item.producto),
                                  ),
                                  Text('${item.cantidad}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: Colors.green[700]),
                                    onPressed: () => carrito.agregar(item.producto),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text('\$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${carrito.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: carrito.items.isEmpty
                          ? null
                          : () async {
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final exito = await PedidoService().crearPedido(
                                context: context,
                                clienteId: auth.usuario.id,
                                detalles: carrito.items.map((item) => {
                                  "producto_id": item.producto.id,
                                  "cantidad": item.cantidad,
                                }).toList(),
                                total: carrito.total,
                              );

                              if (exito) {
                                carrito.limpiar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text('¡Pedido realizado exitosamente!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al registrar el pedido'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Hacer pedido', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

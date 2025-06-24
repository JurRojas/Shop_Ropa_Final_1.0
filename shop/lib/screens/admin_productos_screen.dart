import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import 'crear_editar_producto_screen.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = ProductoService().fetchProductos(context);
  }

  void _refrescar() {
    setState(() {
      _productosFuture = ProductoService().fetchProductos(context);
    });
  }

  Future<void> _navegarCrearProducto() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CrearEditarProductoScreen()),
    );
    if (creado == true) _refrescar();
  }

  Future<void> _navegarEditarProducto(Producto producto) async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CrearEditarProductoScreen(producto: producto)),
    );
    if (editado == true) _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body: FutureBuilder<List<Producto>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar productos'));
          }
          final productos = snapshot.data ?? [];
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                      ? Image.network(producto.imagenUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50, color: Colors.indigo),
                  title: Text(producto.nombre),
                  subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _navegarEditarProducto(producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmado = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar producto'),
                              content: const Text('¿Estás seguro de eliminar este producto?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                              ],
                            ),
                          );
                          if (confirmado == true) {
                            final exito = await ProductoService().eliminarProducto(context, producto.id);
                            if (exito) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Producto eliminado')),
                              );
                              _refrescar();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error al eliminar producto'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarCrearProducto,
        child: const Icon(Icons.add),
        tooltip: 'Agregar producto',
      ),
    );
  }
}

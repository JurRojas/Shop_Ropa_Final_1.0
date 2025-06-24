import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../widgets/producto_card.dart';
import 'detalle_producto_screen.dart';
import 'carrito_screen.dart';
import 'pedidos_screen.dart';

class ClienteHome extends StatefulWidget {
  const ClienteHome({super.key});

  @override
  State<ClienteHome> createState() => _ClienteHomeState();
}

class _ClienteHomeState extends State<ClienteHome> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  bool _cargando = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() async {
    try {
      final productos = await _productoService.fetchProductos(context);
      setState(() {
        _productos = productos;
        _productosFiltrados = productos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void _buscar(String texto) {
    setState(() {
      _busqueda = texto;
      _productosFiltrados = _productos.where((p) =>
        p.nombre.toLowerCase().contains(texto.toLowerCase()) ||
        p.descripcion.toLowerCase().contains(texto.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text('Catálogo de Productos', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Bienvenido', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Cliente', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.indigo),
              title: Text('Catálogo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.indigo),
              title: Text('Mis pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PedidosScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.indigo),
              title: Text('Carrito'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CarritoScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pop(); // Volver al login
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F3FF), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 28,
                        child: Icon(Icons.account_circle, size: 44, color: Colors.indigo.shade400),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¡Bienvenido a LuxB!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Explora y encuentra tu estilo', style: TextStyle(fontSize: 15, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar producto',
                        prefixIcon: Icon(Icons.search, color: Colors.indigo.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: _buscar,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 28, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.grid_view_rounded, color: Colors.indigo.shade400, size: 22),
                    const SizedBox(width: 8),
                    Text('Catálogo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _productosFiltrados.isEmpty
                  ? Center(child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Text('No hay productos', style: TextStyle(color: Colors.indigo, fontSize: 18)),
                    ))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _productosFiltrados.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final producto = _productosFiltrados[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ProductoCard(
                            producto: producto,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleProductoScreen(producto: producto),
                                ),
                              );
                            },
                          )); // <- Cierre correcto del Container
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

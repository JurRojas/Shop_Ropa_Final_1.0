import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  const DetalleProductoScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.indigo.shade100, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                        ? Image.network(producto.imagenUrl!, fit: BoxFit.cover, width: 260, height: 260)
                        : Container(
                            color: Colors.indigo[50],
                            child: Icon(Icons.image, size: 100, color: Colors.indigo),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.label_important, color: Colors.indigo.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(producto.nombre, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.description, color: Colors.indigo.shade300),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(producto.descripcion, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[700], size: 26),
                  const SizedBox(width: 8),
                  Text('Precio:', style: TextStyle(fontSize: 16, color: Colors.indigo)),
                  const SizedBox(width: 8),
                  Text('\$${producto.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CarritoProvider>(context, listen: false).agregar(producto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Producto agregado al carrito'),
                        ],
                      ),
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                label: Text('Agregar al carrito', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

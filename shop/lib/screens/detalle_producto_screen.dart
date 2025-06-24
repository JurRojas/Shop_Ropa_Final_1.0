import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  const DetalleProductoScreen({Key? key, required this.producto}) : super(key: key);

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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? Image.network(producto.imagenUrl!, height: 220, fit: BoxFit.cover)
                    : Container(
                        height: 220,
                        color: Colors.indigo[50],
                        child: Icon(Icons.image, size: 80, color: Colors.indigo),
                      ),
              ),
              SizedBox(height: 24),
              Text(producto.nombre, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              SizedBox(height: 12),
              Text(producto.descripcion, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
              SizedBox(height: 24),
              Text('Precio', style: TextStyle(fontSize: 16, color: Colors.indigo)),
              Text('\$${producto.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              SizedBox(height: 32),
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

import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class CrearEditarProductoScreen extends StatefulWidget {
  final Producto? producto;
  const CrearEditarProductoScreen({super.key, this.producto});

  @override
  State<CrearEditarProductoScreen> createState() => _CrearEditarProductoScreenState();
}

class _CrearEditarProductoScreenState extends State<CrearEditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  bool _loading = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _nombreController.text = widget.producto!.nombre;
      _descripcionController.text = widget.producto!.descripcion;
      _precioController.text = widget.producto!.precio.toString();
      _imagenUrlController.text = widget.producto!.imagenUrl ?? '';
    }
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final producto = Producto(
      id: widget.producto?.id ?? 0,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      precio: double.tryParse(_precioController.text) ?? 0,
      imagenUrl: _imagenUrlController.text.isNotEmpty ? _imagenUrlController.text : null,
    );
    bool exito;
    if (widget.producto == null) {
      exito = await ProductoService().crearProducto(context, producto);
    } else {
      exito = await ProductoService().editarProducto(context, producto);
    }
    setState(() => _loading = false);
    if (exito) {
      Navigator.pop(context, true);
    } else {
      setState(() => _mensaje = 'Error al guardar el producto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto == null ? 'Crear Producto' : 'Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Precio inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagenUrlController,
                decoration: const InputDecoration(labelText: 'URL de imagen (opcional)'),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardarProducto,
                      child: Text(widget.producto == null ? 'Crear' : 'Guardar cambios'),
                    ),
              if (_mensaje != null) ...[
                const SizedBox(height: 16),
                Text(_mensaje!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

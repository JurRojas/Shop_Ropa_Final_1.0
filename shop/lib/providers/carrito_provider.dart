import 'package:flutter/material.dart';
import '../models/carrito.dart';
import '../models/producto.dart';

class CarritoProvider extends ChangeNotifier {
  final Carrito _carrito = Carrito();

  List<ItemCarrito> get items => _carrito.items;
  double get total => _carrito.total;

  void agregar(Producto producto) {
    _carrito.agregarProducto(producto);
    notifyListeners();
  }

  void quitar(Producto producto) {
    _carrito.quitarProducto(producto);
    notifyListeners();
  }

  void limpiar() {
    _carrito.limpiar();
    notifyListeners();
  }
}

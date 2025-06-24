import 'producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});
}

class Carrito {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  void agregarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(ItemCarrito(producto: producto));
    }
  }

  void quitarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
    }
  }

  void limpiar() {
    _items.clear();
  }

  double get total => _items.fold(0, (sum, item) => sum + item.producto.precio * item.cantidad);
}

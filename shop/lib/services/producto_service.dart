import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/auth_provider.dart';

class ProductoService {
  static const String apiUrl = 'http://192.168.1.76:8000/productos/';

  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Producto>> fetchProductos(BuildContext context) async {
    final headers = await _getHeaders(context);
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<bool> crearProducto(BuildContext context, Producto producto) async {
    final headers = await _getHeaders(context);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode({
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'imagen_url': producto.imagenUrl,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> editarProducto(BuildContext context, Producto producto) async {
    final headers = await _getHeaders(context);
    final response = await http.put(
      Uri.parse('$apiUrl${producto.id}'),
      headers: headers,
      body: jsonEncode({
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'imagen_url': producto.imagenUrl,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarProducto(BuildContext context, int id) async {
    final headers = await _getHeaders(context);
    final response = await http.delete(Uri.parse('$apiUrl$id'), headers: headers);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}

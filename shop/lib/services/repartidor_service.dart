import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/repartidor.dart';
import '../providers/auth_provider.dart';

class RepartidorService {
  static const String apiUrl = 'http://192.168.1.76:8000/repartidores/';

  // Obtiene el token JWT desde el AuthProvider
  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Alias para compatibilidad con código antiguo
  Future<List<Repartidor>> fetchRepartidores(BuildContext context) async {
    return listarRepartidores(context);
  }

  Future<List<Repartidor>> listarRepartidores(BuildContext context) async {
    final headers = await _getHeaders(context);
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Repartidor.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar repartidores');
    }
  }

  Future<void> eliminarRepartidor(BuildContext context, int id) async {
    final headers = await _getHeaders(context);
    final response = await http.delete(Uri.parse('$apiUrl$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar repartidor');
    }
  }

  Future<void> crearRepartidor(BuildContext context, String nombre, String telefono, String email, String contrasena) async {
    final headers = await _getHeaders(context);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'contrasena': contrasena,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear repartidor');
    }
  }

  Future<void> actualizarRepartidor(BuildContext context, int id, String nombre, String telefono, String email, String contrasena) async {
    final headers = await _getHeaders(context);
    final response = await http.put(
      Uri.parse('$apiUrl$id'),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'contrasena': contrasena,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar repartidor');
    }
  }
}

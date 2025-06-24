import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';

class ClienteService {
  static const String apiUrl = 'http://192.168.1.76:8000/clientes/';

  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Usuario>> listarClientes(BuildContext context) async {
    final headers = await _getHeaders(context);
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar clientes');
    }
  }

  Future<void> eliminarCliente(BuildContext context, int id) async {
    final headers = await _getHeaders(context);
    final response = await http.delete(Uri.parse('$apiUrl$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar cliente');
    }
  }
}

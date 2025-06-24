import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/pago.dart';
import '../providers/auth_provider.dart';

class PagoService {
  static const String apiUrl = 'http://192.168.1.76:8000/pagos/';

  Future<Map<String, String>> _getAuthHeader(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getJsonHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Pago>> listarPagos(BuildContext context) async {
    final headers = await _getJsonHeaders(context);
    final response = await http.post(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pago.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pagos');
    }
  }

  Future<void> eliminarPago(BuildContext context, int id) async {
    final headers = await _getJsonHeaders(context);
    final response = await http.delete(Uri.parse('$apiUrl$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar pago');
    }
  }

  Future<bool> simularPago({required BuildContext context, required int pedidoId}) async {
    final headers = await _getJsonHeaders(context);
    final response = await http.post(
      Uri.parse('http://192.168.1.76:8000/pagos/$pedidoId'),
      headers: headers,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> pagarConTarjeta({
    required BuildContext context,
    required int pedidoId,
    required int tarjetaId,
  }) async {
    final headers = await _getAuthHeader(context); // Solo Authorization
    final response = await http.post(
      Uri.parse('http://192.168.1.76:8000/pagos/$pedidoId'),
      headers: headers,
      body: {
        'tarjeta_id': tarjetaId.toString(),
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/tarjeta.dart';
import '../providers/auth_provider.dart';

class TarjetaService {
  static const String apiUrl = 'http://192.168.1.76:8000/pagos/tarjetas/';

  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      // No poner 'Content-Type' aquí para formularios
    };
  }

  Future<List<Tarjeta>> listarTarjetas(BuildContext context, int clienteId) async {
    final headers = await _getHeaders(context);
    final response = await http.get(Uri.parse(apiUrl + clienteId.toString()), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Tarjeta.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar tarjetas');
    }
  }

  Future<bool> registrarTarjeta(BuildContext context, int clienteId, String numero, String nombre, String vencimiento, String cvv) async {
    final headers = await _getHeaders(context);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: {
        'cliente_id': clienteId.toString(),
        'numero': numero ?? '',
        'nombre': nombre ?? '',
        'vencimiento': vencimiento ?? '',
        'cvv': cvv ?? '',
      },
    );
    debugPrint('REGISTRAR TARJETA status: [32m[1m[4m[0m${response.statusCode}');
    debugPrint('REGISTRAR TARJETA body: ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }
}

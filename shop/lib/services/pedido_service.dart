import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../providers/auth_provider.dart';

class PedidoService {
  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> crearPedido({
    required BuildContext context,
    required int clienteId,
    required List<Map<String, dynamic>> detalles,
    required double total,
  }) async {
    final headers = await _getHeaders(context);
    final response = await http.post(
      Uri.parse('http://192.168.1.76:8000/pedidos/'),
      headers: headers,
      body: jsonEncode({
        "cliente_id": clienteId,
        "detalles": detalles,
        "total": total,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Pedido>> fetchPedidosCliente(BuildContext context, int clienteId) async {
    final headers = await _getHeaders(context);
    final response = await http.get(
      Uri.parse('http://192.168.1.76:8000/pedidos/cliente/$clienteId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los pedidos');
    }
  }

  Future<List<Pedido>> fetchTodosPedidos(BuildContext context) async {
    final headers = await _getHeaders(context);
    final response = await http.get(Uri.parse('http://192.168.1.76:8000/pedidos/'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pedidos');
    }
  }

  Future<bool> asignarRepartidor(BuildContext context, int pedidoId, int repartidorId) async {
    final headers = await _getHeaders(context);
    final response = await http.put(
      Uri.parse('http://192.168.1.76:8000/pedidos/$pedidoId/asignar?repartidor_id=$repartidorId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  Future<List<Pedido>> fetchPedidosRepartidor(BuildContext context, int repartidorId) async {
    final headers = await _getHeaders(context);
    final response = await http.get(
      Uri.parse('http://192.168.1.76:8000/pedidos/repartidor/$repartidorId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pedidos del repartidor');
    }
  }

  Future<bool> cambiarEstadoPedido(BuildContext context, int pedidoId, String nuevoEstado) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.76:8000/pedidos/$pedidoId/estado?estado=${Uri.encodeComponent(nuevoEstado)}'),
    );
    return response.statusCode == 200;
  }
}
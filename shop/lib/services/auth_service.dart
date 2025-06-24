import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class AuthService {
  static const String apiUrl = 'http://192.168.1.76:8000/login/';

  Future<Usuario?> login(String email, String contrasena) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'contrasena': contrasena}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginConToken(String email, String contrasena) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'contrasena': contrasena}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    }
    return null;
  }

  Future<bool> registrarCliente(String nombre, String direccion, String email, String contrasena) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/clientes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'direccion': direccion,
        'email': email,
        'contrasena': contrasena,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> registrarRepartidor(String nombre, String telefono, String email, String contrasena) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/repartidores/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'contrasena': contrasena,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> registrarAdmin(String nombre, String email, String contrasena) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/administradores/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'contrasena': contrasena,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}

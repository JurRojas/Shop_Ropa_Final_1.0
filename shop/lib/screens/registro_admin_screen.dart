import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroAdminScreen extends StatefulWidget {
  const RegistroAdminScreen({super.key});

  @override
  _RegistroAdminScreenState createState() => _RegistroAdminScreenState();
}

class _RegistroAdminScreenState extends State<RegistroAdminScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _mensaje;
  bool _loading = false;

  void _registrar() async {
    // Validación básica de email
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+ $');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _mensaje = 'Email inválido');
      return;
    }
    setState(() => _loading = true);
    final exito = await _authService.registrarAdmin(
      _nombreController.text,
      email,
      _contrasenaController.text,
    );
    setState(() => _loading = false);
    if (exito) {
      setState(() => _mensaje = '¡Registro exitoso! Ahora puedes iniciar sesión.');
    } else {
      setState(() => _mensaje = 'Error al registrar. Intenta con otro email o nombre.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Administrador')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                _loading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registrar,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text('Registrarse', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                if (_mensaje != null) ...[
                  SizedBox(height: 16),
                  Text(_mensaje!, style: TextStyle(color: Colors.green, fontSize: 16)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

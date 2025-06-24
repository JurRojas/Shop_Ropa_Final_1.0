import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _mensaje;
  bool _loading = false;

  void _registrar() async {
    setState(() => _loading = true);
    final exito = await _authService.registrarCliente(
      _nombreController.text,
      _direccionController.text,
      _emailController.text.trim(),
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
      appBar: AppBar(title: Text('Registro de Cliente')),
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
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.home),
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

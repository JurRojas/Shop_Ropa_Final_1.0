import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../models/usuario.dart';
import 'cliente_home.dart';
import 'repartidor_home.dart';
import 'admin_home.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _error;
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final data = await _authService.loginConToken(
      _emailController.text,
      _contrasenaController.text,
    );
    print('Respuesta login: ' + data.toString()); // DEBUG
    setState(() => _loading = false);
    if (data != null && data['token'] != null) {
      setState(() => _error = null);
      final usuario = Usuario.fromJson(data);
      print('Tipo usuario: ' + usuario.tipo.toString()); // DEBUG
      final token = data['token'];
      Provider.of<AuthProvider>(context, listen: false).setUsuarioYToken(usuario, token);
      if (usuario.tipo == 'cliente') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClienteHome()));
      } else if (usuario.tipo == 'repartidor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RepartidorHome(repartidorId: usuario.id)));
      } else if (usuario.tipo == 'administrador') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHome()));
      }
    } else {
      setState(() => _error = 'Credenciales incorrectas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 32),
                Text('LuxB', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 8),
                Text('Bienvenido, inicia sesión para continuar', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                SizedBox(height: 32),
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
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.indigo,
                          ),
                          child: Text('Entrar', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                if (_error != null) ...[
                  SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegistroScreen()),
                        );
                      },
                      child: Text('Regístrate', style: TextStyle(color: Colors.indigo)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

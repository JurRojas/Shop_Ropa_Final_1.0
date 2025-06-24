import 'package:flutter/material.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  late Usuario _usuario;
  String _token = '';

  AuthProvider()
      : _usuario = Usuario(id: 0, nombre: '', tipo: ''),
        _token = '';

  Usuario get usuario => _usuario;
  String get token => _token;

  void setUsuarioYToken(Usuario usuario, String token) {
    _usuario = usuario;
    _token = token;
    notifyListeners();
  }

  void limpiar() {
    _usuario = Usuario(id: 0, nombre: '', tipo: '');
    _token = '';
    notifyListeners();
  }
}
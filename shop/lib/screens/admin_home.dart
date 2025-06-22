import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio Administrador')),
      body: Center(child: Text('Bienvenido, Administrador', style: TextStyle(fontSize: 22))),
    );
  }
}

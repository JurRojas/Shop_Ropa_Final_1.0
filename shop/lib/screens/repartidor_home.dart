import 'package:flutter/material.dart';

class RepartidorHome extends StatelessWidget {
  const RepartidorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio Repartidor')),
      body: Center(child: Text('Bienvenido, Repartidor', style: TextStyle(fontSize: 22))),
    );
  }
}

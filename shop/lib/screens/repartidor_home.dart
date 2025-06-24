import 'package:flutter/material.dart';
import 'repartidor_pedidos_screen.dart';

class RepartidorHome extends StatelessWidget {
  final int repartidorId;
  const RepartidorHome({super.key, required this.repartidorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio Repartidor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido, Repartidor', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Ver mis pedidos asignados'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RepartidorPedidosScreen(repartidorId: repartidorId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

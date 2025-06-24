import 'package:flutter/material.dart';
import 'registro_admin_screen.dart';
import 'registro_repartidor_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text('Panel de Administración', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 8),
                const Text('Gestiona productos, pedidos, clientes, pagos y repartidores', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Gestionar Productos'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_productos');
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('Gestionar Repartidores'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_repartidores');
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Gestionar Pagos'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_pagos');
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Ver Pedidos'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_pedidos');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

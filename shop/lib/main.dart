import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/auth_provider.dart'; // <--- Importado
import 'screens/login_screen.dart';
import 'screens/admin_home.dart';
import 'screens/admin_productos_screen.dart';
import 'screens/admin_pedidos_screen.dart';
import 'screens/repartidor_pedidos_screen.dart';
import 'screens/admin_repartidores_screen.dart'; // Importar la nueva pantalla
import 'screens/admin_clientes_screen.dart';
import 'screens/admin_pagos_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // <--- Agregado
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/admin': (context) => AdminHome(),
        '/admin_productos': (context) => AdminProductosScreen(),
        '/admin_pedidos': (context) => AdminPedidosScreen(),
        '/admin_repartidores': (context) => AdminRepartidoresScreen(),
        '/admin_clientes': (context) => AdminClientesScreen(),
        '/admin_pagos': (context) => AdminPagosScreen(),
        '/repartidor_pedidos': (context) => RepartidorPedidosScreen(repartidorId: 0), // El id real se pasa con Navigator
        // Puedes agregar más rutas aquí para gestión de productos, usuarios, etc.
      },
    );
  }
}

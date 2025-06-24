import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/cliente_service.dart';

class AdminClientesScreen extends StatefulWidget {
  const AdminClientesScreen({super.key});

  @override
  State<AdminClientesScreen> createState() => _AdminClientesScreenState();
}

class _AdminClientesScreenState extends State<AdminClientesScreen> {
  List<Usuario> _clientes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() { _loading = true; });
    try {
      final lista = await ClienteService().listarClientes(context);
      setState(() {
        _clientes = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar clientes';
        _loading = false;
      });
    }
  }

  void _abrirDialogoEliminar(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: const Text('¿Seguro que deseas eliminar este cliente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado == true) {
      await ClienteService().eliminarCliente(context, id);
      _cargarClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text('Gestión de Clientes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 8),
                const Text('Administra los clientes registrados', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : _error != null
                        ? Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16))
                        : _clientes.isEmpty
                            ? const Text('No hay clientes registrados')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _clientes.length,
                                itemBuilder: (ctx, i) {
                                  final c = _clientes[i];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text(c.nombre),
                                      subtitle: Text(c.email ?? 'sin email'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _abrirDialogoEliminar(c.id),
                                      ),
                                    ),
                                  );
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

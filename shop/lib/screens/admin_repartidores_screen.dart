import 'package:flutter/material.dart';
import '../models/repartidor.dart';
import '../services/repartidor_service.dart';

class AdminRepartidoresScreen extends StatefulWidget {
  const AdminRepartidoresScreen({super.key});

  @override
  State<AdminRepartidoresScreen> createState() => _AdminRepartidoresScreenState();
}

class _AdminRepartidoresScreenState extends State<AdminRepartidoresScreen> {
  List<Repartidor> _repartidores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarRepartidores();
  }

  Future<void> _cargarRepartidores() async {
    setState(() { _loading = true; });
    try {
      final lista = await RepartidorService().listarRepartidores(context);
      setState(() {
        _repartidores = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar repartidores';
        _loading = false;
      });
    }
  }

  void _eliminarRepartidor(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar repartidor'),
        content: const Text('¿Seguro que deseas eliminar este repartidor?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado == true) {
      await RepartidorService().eliminarRepartidor(context, id);
      _cargarRepartidores();
    }
  }

  void _abrirFormulario({Repartidor? repartidor}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioRepartidorScreen(repartidor: repartidor),
      ),
    );
    if (resultado == true) {
      _cargarRepartidores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Repartidores')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _repartidores.length,
                  itemBuilder: (ctx, i) {
                    final r = _repartidores[i];
                    return ListTile(
                      title: Text(r.nombre),
                      subtitle: Text(r.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _abrirFormulario(repartidor: r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarRepartidor(r.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar repartidor',
      ),
    );
  }
}

class FormularioRepartidorScreen extends StatefulWidget {
  final Repartidor? repartidor;
  const FormularioRepartidorScreen({super.key, this.repartidor});

  @override
  State<FormularioRepartidorScreen> createState() => _FormularioRepartidorScreenState();
}

class _FormularioRepartidorScreenState extends State<FormularioRepartidorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _contrasenaController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.repartidor?.nombre ?? '');
    _telefonoController = TextEditingController(text: widget.repartidor?.telefono ?? '');
    _emailController = TextEditingController(text: widget.repartidor?.email ?? '');
    _contrasenaController = TextEditingController();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.repartidor == null) {
        await RepartidorService().crearRepartidor(
          context,
          _nombreController.text,
          _telefonoController.text,
          _emailController.text,
          _contrasenaController.text,
        );
      } else {
        await RepartidorService().actualizarRepartidor(
          context,
          widget.repartidor!.id,
          _nombreController.text,
          _telefonoController.text,
          _emailController.text,
          _contrasenaController.text,
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = 'Error al guardar repartidor'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.repartidor == null ? 'Nuevo Repartidor' : 'Editar Repartidor')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (v) => v == null || v.length != 10 ? 'Teléfono de 10 dígitos' : null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Email inválido' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) => widget.repartidor == null && (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: Text(widget.repartidor == null ? 'Crear' : 'Guardar'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

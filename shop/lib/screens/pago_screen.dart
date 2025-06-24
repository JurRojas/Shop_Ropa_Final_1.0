import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pago_service.dart';
import '../services/tarjeta_service.dart';
import '../models/tarjeta.dart';
import '../providers/auth_provider.dart';
import 'registrar_tarjeta_screen.dart';

class PagoScreen extends StatefulWidget {
  final int pedidoId;
  final double total;
  final Function() onPagoExitoso;

  const PagoScreen({super.key, required this.pedidoId, required this.total, required this.onPagoExitoso});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final PagoService _pagoService = PagoService();
  final TarjetaService _tarjetaService = TarjetaService();
  String? _error;
  bool _cargando = false;
  List<Tarjeta> _tarjetas = [];
  Tarjeta? _tarjetaSeleccionada;
  bool _cargandoTarjetas = true;

  @override
  void initState() {
    super.initState();
    _cargarTarjetas();
  }

  Future<void> _cargarTarjetas() async {
    setState(() { _cargandoTarjetas = true; });
    try {
      final clienteId = Provider.of<AuthProvider>(context, listen: false).usuario.id;
      final tarjetas = await _tarjetaService.listarTarjetas(context, clienteId);
      setState(() {
        _tarjetas = tarjetas;
        if (_tarjetas.isNotEmpty) {
          _tarjetaSeleccionada = _tarjetas.first;
        }
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar tarjetas'; });
    } finally {
      setState(() { _cargandoTarjetas = false; });
    }
  }

  void _pagar() async {
    if (_tarjetaSeleccionada == null) {
      setState(() => _error = 'Selecciona una tarjeta para pagar');
      return;
    }
    setState(() { _cargando = true; _error = null; });
    try {
      final exito = await _pagoService.pagarConTarjeta(
        context: context,
        pedidoId: widget.pedidoId,
        tarjetaId: _tarjetaSeleccionada!.id,
      );
      setState(() { _cargando = false; });
      if (exito) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 0),
            title: Stack(
              children: [
                Center(child: const Icon(Icons.check_circle, color: Colors.green, size: 48)),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ),
              ],
            ),
            content: const Text('¡Pago realizado exitosamente!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ),
        );
        widget.onPagoExitoso();
        if (mounted) Navigator.of(context).pop();
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 0),
            title: Stack(
              children: [
                Center(child: const Icon(Icons.error, color: Colors.red, size: 48)),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ),
              ],
            ),
            content: const Text('Error al procesar el pago. Intenta de nuevo.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ),
        );
        setState(() => _error = 'Error al procesar el pago');
      }
    } catch (e) {
      setState(() { _cargando = false; _error = 'Error inesperado: \n' + e.toString(); });
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 0),
          title: Stack(
            children: [
              Center(child: const Icon(Icons.error, color: Colors.red, size: 48)),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ),
            ],
          ),
          content: Text('Error inesperado: \n' + e.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ),
      );
    }
  }

  void _irARegistrarTarjeta() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrarTarjetaScreen()),
    );
    if (resultado == true) {
      _cargarTarjetas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceder al Pago'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _cargandoTarjetas
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          child: Column(
                            children: [
                              const Text('Resumen de pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.attach_money, color: Colors.green, size: 28),
                                  Text(
                                    widget.total.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_tarjetas.isEmpty)
                        Column(
                          children: [
                            const Text('No tienes tarjetas registradas.', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_card),
                              onPressed: _irARegistrarTarjeta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              label: const Text('Registrar nueva tarjeta'),
                            ),
                          ],
                        )
                      else ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.indigo.shade100),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Tarjeta>(
                              value: _tarjetaSeleccionada,
                              isExpanded: true,
                              items: _tarjetas.map((t) => DropdownMenuItem(
                                value: t,
                                child: Row(
                                  children: [
                                    const Icon(Icons.credit_card, color: Colors.indigo),
                                    const SizedBox(width: 8),
                                    Text('**** **** **** ${t.numero.substring(t.numero.length - 4)}  (${t.nombre})'),
                                  ],
                                ),
                              )).toList(),
                              onChanged: (t) => setState(() => _tarjetaSeleccionada = t),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_card),
                          onPressed: _irARegistrarTarjeta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          label: const Text('Registrar nueva tarjeta'),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _cargando ? null : _pagar,
                          child: _cargando
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Pagar', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
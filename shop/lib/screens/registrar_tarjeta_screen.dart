import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tarjeta_service.dart';
import '../providers/auth_provider.dart';

class RegistrarTarjetaScreen extends StatefulWidget {
  const RegistrarTarjetaScreen({super.key});

  @override
  State<RegistrarTarjetaScreen> createState() => _RegistrarTarjetaScreenState();
}

class _RegistrarTarjetaScreenState extends State<RegistrarTarjetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _loading = false;
  String? _tipoTarjeta;
  int? _mesSeleccionado;
  int? _anioSeleccionado;
  bool _mostrarReverso = false;

  List<int> _aniosDisponibles() {
    final ahora = DateTime.now();
    return List.generate(15, (i) => ahora.year + i);
  }

  void _mostrarExitoYVolver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: const Text('¡Tarjeta registrada exitosamente!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop(); // Cierra el dialog
    Navigator.of(context).pop(true); // Retorna a la pantalla de pago
  }

  void _registrarTarjeta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final clienteId = Provider.of<AuthProvider>(context, listen: false).usuario.id;
    final vencimiento = _mesSeleccionado != null && _anioSeleccionado != null
        ? _mesSeleccionado.toString().padLeft(2, '0') + '/' + _anioSeleccionado.toString()
        : '';
    final exito = await TarjetaService().registrarTarjeta(
      context,
      clienteId,
      _numeroController.text,
      _nombreController.text,
      vencimiento,
      _cvvController.text,
    );
    setState(() => _loading = false);
    if (exito) {
      _mostrarExitoYVolver();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrar tarjeta'), backgroundColor: Colors.red));
    }
  }

  String? _detectarTipoTarjeta(String numero) {
    if (numero.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5])').hasMatch(numero)) return 'Mastercard';
    if (RegExp(r'^(3[47])').hasMatch(numero)) return 'Amex';
    return null;
  }

  Widget _iconoTipoTarjeta(String? tipo) {
    switch (tipo) {
      case 'Visa':
        return Image.asset('assets/visa.png', width: 40, height: 24);
      case 'Mastercard':
        return Image.asset('assets/mastercard.png', width: 40, height: 24);
      case 'Amex':
        return Image.asset('assets/amex.png', width: 40, height: 24);
      default:
        return const SizedBox(width: 40, height: 24);
    }
  }

  void _focusSiguienteCampo() {
    setState(() => _mostrarReverso = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      FocusScope.of(context).nextFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Tarjeta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tarjeta gráfica animada con giro
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) {
                  final rotate = Tween(begin: _mostrarReverso ? 1.0 : 0.0, end: _mostrarReverso ? 0.0 : 1.0).animate(anim);
                  return AnimatedBuilder(
                    animation: rotate,
                    child: child,
                    builder: (context, child) {
                      final isReversed = rotate.value < 0.5;
                      final angle = isReversed ? rotate.value * 3.1416 : (1 - rotate.value) * 3.1416;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(angle),
                        child: child,
                      );
                    },
                  );
                },
                child: !_mostrarReverso
                    ? Container(
                        key: const ValueKey('front'),
                        width: double.infinity,
                        height: 220,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              _tipoTarjeta == 'Visa'
                                  ? const Color(0xFF1A2980)
                                  : _tipoTarjeta == 'Mastercard'
                                      ? const Color(0xFFFC4A1A)
                                      : _tipoTarjeta == 'Amex'
                                          ? const Color(0xFF43CEA2)
                                          : Colors.indigo,
                              Colors.deepPurple.shade200,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 18,
                              right: 18,
                              child: _iconoTipoTarjeta(_tipoTarjeta),
                            ),
                            Positioned(
                              left: 24,
                              top: 60,
                              right: 24,
                              child: TextFormField(
                                controller: _nombreController,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 1.2),
                                decoration: const InputDecoration(
                                  labelText: 'Nombre en la tarjeta',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => _focusSiguienteCampo(),
                                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('back'),
                        width: double.infinity,
                        height: 220,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              _tipoTarjeta == 'Visa'
                                  ? const Color(0xFF1A2980)
                                  : _tipoTarjeta == 'Mastercard'
                                      ? const Color(0xFFFC4A1A)
                                      : _tipoTarjeta == 'Amex'
                                          ? const Color(0xFF43CEA2)
                                          : Colors.indigo,
                              Colors.deepPurple.shade200,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 18,
                              right: 18,
                              child: _iconoTipoTarjeta(_tipoTarjeta),
                            ),
                            Positioned(
                              left: 24,
                              top: 40,
                              right: 24,
                              child: TextFormField(
                                controller: _numeroController,
                                style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontFamily: 'monospace'),
                                decoration: const InputDecoration(
                                  labelText: 'Número de tarjeta',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 19,
                                onChanged: (v) {
                                  setState(() {
                                    _tipoTarjeta = _detectarTipoTarjeta(v.replaceAll(' ', ''));
                                  });
                                },
                                validator: (v) {
                                  if (v == null || v.length < 15) return 'Número inválido';
                                  final tipo = _detectarTipoTarjeta(v.replaceAll(' ', ''));
                                  if (tipo == null) return 'Tarjeta no soportada';
                                  if (tipo == 'Amex' && v.length != 15) return 'Amex debe tener 15 dígitos';
                                  if ((tipo == 'Visa' || tipo == 'Mastercard') && v.length != 16) return 'Debe tener 16 dígitos';
                                  return null;
                                },
                              ),
                            ),
                            Positioned(
                              left: 24,
                              bottom: 60,
                              right: 120,
                              child: DropdownButtonFormField<int>(
                                value: _mesSeleccionado,
                                dropdownColor: Colors.deepPurple.shade50,
                                decoration: const InputDecoration(
                                  labelText: 'Mes',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                items: List.generate(12, (i) => i + 1)
                                    .map((mes) => DropdownMenuItem(
                                          value: mes,
                                          child: Text(mes.toString().padLeft(2, '0')),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _mesSeleccionado = v),
                                validator: (v) => v == null ? 'Selecciona mes' : null,
                              ),
                            ),
                            Positioned(
                              left: 160,
                              bottom: 60,
                              right: 24,
                              child: DropdownButtonFormField<int>(
                                value: _anioSeleccionado,
                                dropdownColor: Colors.deepPurple.shade50,
                                decoration: const InputDecoration(
                                  labelText: 'Año',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                items: _aniosDisponibles()
                                    .map((anio) => DropdownMenuItem(
                                          value: anio,
                                          child: Text(anio.toString()),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _anioSeleccionado = v),
                                validator: (v) => v == null ? 'Selecciona año' : null,
                              ),
                            ),
                            Positioned(
                              right: 24,
                              bottom: 24,
                              width: 80,
                              child: TextFormField(
                                controller: _cvvController,
                                style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                maxLength: 3,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.length < 3 ? 'CVV inválido' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registrarTarjeta,
                      child: const Text('Guardar tarjeta'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

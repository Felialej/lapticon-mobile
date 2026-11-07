import 'package:flutter/material.dart';

import '../controllers/registrar_encomienda_controller.dart';
import '../theme/app_theme.dart';

class RegistrarEncomiendaView extends StatefulWidget {
  const RegistrarEncomiendaView({
    super.key,
    required this.idToken,
  });

  final String idToken;

  @override
  State<RegistrarEncomiendaView> createState() =>
      _RegistrarEncomiendaViewState();
}

class _RegistrarEncomiendaViewState
    extends State<RegistrarEncomiendaView> {
  final _formKey = GlobalKey<FormState>();

  final _observacionesController = TextEditingController();
  final _valorController = TextEditingController();

  final RegistrarEncomiendaController _controller =
      RegistrarEncomiendaController();

  @override
  void dispose() {
    _observacionesController.dispose();
    _valorController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publicarEncomienda() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final problema = _controller.validarSeleccion();

    if (problema != null) {
      _mostrarAviso(problema);
      return;
    }

    final encomienda = await _controller.registrarEncomienda(
      observaciones: _observacionesController.text,
      valor: _valorController.text,
      idToken: widget.idToken,
    );

    if (!mounted) {
      return;
    }

    if (encomienda == null) {
      _mostrarAviso(
        _controller.error ??
            'No fue posible registrar la encomienda.',
      );
      return;
    }

    Navigator.pop(
      context,
      encomienda,
    );
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicar encomienda',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completa la información de tu envío.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const _Etiqueta(
                        texto: 'Ciudad de origen',
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: _controller.origen,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona el origen',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                          ),
                        ),
                        items: _opcionesDeCiudad(),
                        onChanged:
                            _controller.seleccionarOrigen,
                        validator:
                            _controller.validarCiudad,
                      ),

                      const SizedBox(height: 20),

                      const _Etiqueta(
                        texto: 'Ciudad de destino',
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: _controller.destino,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona el destino',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                          ),
                        ),
                        items: _opcionesDeCiudad(),
                        onChanged:
                            _controller.seleccionarDestino,
                        validator:
                            _controller.validarCiudad,
                      ),

                      const SizedBox(height: 20),

                      const _Etiqueta(
                        texto: 'Observaciones',
                      ),

                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          hintText: 'Ejemplo: Paquete pequeño',
                          prefixIcon: Icon(
                            Icons.description_outlined,
                          ),
                        ),
                        validator:
                            _controller.validarObservaciones,
                      ),

                      const SizedBox(height: 20),

                      const _Etiqueta(texto: 'Moneda'),

                      DropdownButtonFormField<String>(
                        initialValue: _controller.moneda,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona la moneda',
                          prefixIcon: Icon(
                            Icons.language_outlined,
                          ),
                        ),
                        items: _opcionesDeMoneda(),
                        onChanged:
                            _controller.seleccionarMoneda,
                        validator:
                            _controller.validarMoneda,
                      ),

                      const SizedBox(height: 20),

                      const _Etiqueta(texto: 'Valor'),

                      TextFormField(
                        controller: _valorController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ejemplo: 10',
                          prefixIcon: Icon(
                            Icons.attach_money,
                          ),
                        ),
                        validator: _controller.validarValor,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'La disponibilidad depende del backend.',
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _controller.cargando
                          ? null
                          : _publicarEncomienda,
                      child: _controller.cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Publicar encomienda',
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _opcionesDeCiudad() {
    return RegistrarEncomiendaController.ciudadesDisponibles
        .map(
          (ciudad) => DropdownMenuItem<String>(
            value: ciudad,
            child: Text(ciudad),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<String>> _opcionesDeMoneda() {
    return RegistrarEncomiendaController.monedasDisponibles
        .map(
          (moneda) => DropdownMenuItem<String>(
            value: moneda,
            child: Text(moneda),
          ),
        )
        .toList();
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

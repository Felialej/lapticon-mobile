import 'package:flutter/material.dart';

import '../controllers/encomiendas_tomadas_controller.dart';
import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import 'contacto_remitente_view.dart';
import 'widgets/busqueda_por_ruta.dart';
import 'widgets/etiqueta_estado.dart';

/// HU-20: consulta por ruta de las encomiendas tomadas del viajero.
class EncomiendasTomadasView extends StatefulWidget {
  const EncomiendasTomadasView({super.key, required this.idToken});
  final String idToken;

  @override
  State<EncomiendasTomadasView> createState() => _EncomiendasTomadasViewState();
}

class _EncomiendasTomadasViewState extends State<EncomiendasTomadasView> {
  final _formKey = GlobalKey<FormState>();
  late final EncomiendasTomadasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EncomiendasTomadasController(idToken: widget.idToken);
    _controller.cargarCiudades();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buscar() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _controller.buscar();
    }
  }

  Future<void> _abrirContacto(Encomienda encomienda) async {
    final entregada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ContactoRemitenteView(
          encomienda: encomienda,
          controlador: _controller,
        ),
      ),
    );
    if (!mounted || entregada != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Entrega confirmada. Estado: recibida.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encomiendas tomadas')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.cargandoCiudades) {
              return const Center(child: CircularProgressIndicator());
            }
            final errorCiudades = _controller.errorCiudades;
            if (errorCiudades != null) {
              return ErrorCatalogoCiudades(
                mensaje: errorCiudades,
                onReintentar: _controller.cargarCiudades,
              );
            }

            final ciudades = _controller.ciudades;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consulta tus encomiendas tomadas',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Selecciona la ruta de las encomiendas '
                    'que aceptaste transportar.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectorCiudad(
                          ciudades: ciudades,
                          etiqueta: 'Ciudad de origen',
                          icono: Icons.flight_takeoff,
                          seleccionar: _controller.seleccionarOrigen,
                          validar: _controller.validarOrigen,
                        ),
                        const SizedBox(height: 16),
                        SelectorCiudad(
                          ciudades: ciudades,
                          etiqueta: 'Ciudad de destino',
                          icono: Icons.flight_land,
                          seleccionar: _controller.seleccionarDestino,
                          validar: _controller.validarDestino,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _controller.buscando ? null : _buscar,
                          icon: const Icon(Icons.search),
                          label: Text(
                            _controller.buscando
                                ? 'Buscando...'
                                : 'Buscar encomiendas tomadas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_controller.buscando)
                    const Center(child: CircularProgressIndicator()),
                  if (_controller.errorBusqueda != null)
                    MensajeBusquedaRuta(
                      icono: Icons.error_outline,
                      mensaje: _controller.errorBusqueda!,
                    ),
                  if (!_controller.buscando &&
                      _controller.errorBusqueda == null &&
                      _controller.busquedaRealizada) ...[
                    if (_controller.resultados.isEmpty)
                      const MensajeBusquedaRuta(
                        icono: Icons.search_off,
                        mensaje:
                            'No tienes encomiendas tomadas '
                            'para esta ruta.',
                      )
                    else ...[
                      Text(
                        'Encomiendas encontradas: ${_controller.resultados.length}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final resultado in _controller.resultados)
                        _tarjetaEncomienda(resultado),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaEncomienda(Encomienda encomienda) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            encomienda.ruta,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Valor: ${encomienda.valorConMoneda}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Observaciones',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            encomienda.observaciones.isEmpty
                ? 'Sin observaciones'
                : encomienda.observaciones,
          ),
          const SizedBox(height: 12),
          EtiquetaEstado(estado: encomienda.estado),
          if (encomienda.estado == EstadoEncomienda.tomada) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _controller.confirmandoEntrega
                    ? null
                    : () => _abrirContacto(encomienda),
                icon: const Icon(Icons.person_outline),
                label: const Text('Contactar al remitente'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

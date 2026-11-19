import 'package:flutter/material.dart';

import '../controllers/buscar_encomiendas_controller.dart';
import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import 'detalle_encomienda_view.dart';
import 'widgets/busqueda_por_ruta.dart';
import 'widgets/etiqueta_estado.dart';

/// HU-12: búsqueda de encomiendas disponibles para un viajero.
class BuscarEncomiendasView extends StatefulWidget {
  const BuscarEncomiendasView({super.key, required this.idToken});

  final String idToken;

  @override
  State<BuscarEncomiendasView> createState() => _BuscarEncomiendasViewState();
}

class _BuscarEncomiendasViewState extends State<BuscarEncomiendasView> {
  final _formKey = GlobalKey<FormState>();
  late final BuscarEncomiendasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BuscarEncomiendasController(idToken: widget.idToken);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar encomiendas')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.cargandoCiudades) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller.errorCiudades != null) {
              return ErrorCatalogoCiudades(
                mensaje: _controller.errorCiudades!,
                onReintentar: _controller.cargarCiudades,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encuentra encomiendas disponibles',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Busca encomiendas que coincidan con tu ruta de viaje.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectorCiudad(
                          etiqueta: 'Ciudad de origen',
                          icono: Icons.flight_takeoff,
                          ciudades: _controller.ciudades,
                          seleccionar: _controller.seleccionarOrigen,
                          validar: _controller.validarOrigen,
                        ),
                        const SizedBox(height: 16),
                        SelectorCiudad(
                          etiqueta: 'Ciudad de destino',
                          icono: Icons.flight_land,
                          ciudades: _controller.ciudades,
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
                                : 'Buscar encomiendas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_controller.buscando)
                    const Center(child: CircularProgressIndicator()),
                  if (_controller.errorBusqueda != null)
                    _mensaje(Icons.error_outline, _controller.errorBusqueda!),
                  if (!_controller.buscando &&
                      _controller.errorBusqueda == null &&
                      _controller.busquedaRealizada) ...[
                    if (_controller.resultados.isEmpty)
                      _mensaje(
                        Icons.search_off,
                        'No se encontraron encomiendas disponibles para esta ruta.',
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

  Future<void> _abrirDetalle(Encomienda encomienda) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetalleEncomiendaView(
          encomienda: encomienda,
          idToken: widget.idToken,
        ),
      ),
    );
    if (!mounted) return;
    // Tras volver del detalle, consulta de nuevo para evitar estados obsoletos.
    // Solo refresca si el usuario había realizado una búsqueda.
    if (_controller.busquedaRealizada && !_controller.buscando) {
      await _controller.buscar();
    }
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
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: encomienda.id == null || encomienda.id!.isEmpty
                ? null
                : () => _abrirDetalle(encomienda),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Ver detalle'),
          ),
        ],
      ),
    );
  }

  Widget _mensaje(IconData icono, String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppTheme.textSecondary, size: 30),
          const SizedBox(height: 8),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

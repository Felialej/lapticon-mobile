import 'package:flutter/material.dart';

import '../controllers/buscar_viajeros_controller.dart';
import '../models/viaje_disponible.dart';
import '../theme/app_theme.dart';
import '../utils/formato_fecha.dart';

/// HU-15: el remitente puede consultar viajes disponibles por ruta.
class BuscarViajerosView extends StatefulWidget {
  const BuscarViajerosView({super.key});

  @override
  State<BuscarViajerosView> createState() => _BuscarViajerosViewState();
}

class _BuscarViajerosViewState extends State<BuscarViajerosView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = BuscarViajerosController();

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text('Buscar viajeros')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.cargandoCiudades) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller.errorCiudades != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _controller.errorCiudades!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: _controller.cargarCiudades,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encuentra viajeros disponibles',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Busca viajes según la ciudad de origen y destino '
                    'de tu encomienda.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _selectorCiudad(
                          etiqueta: 'Ciudad de origen',
                          icono: Icons.flight_takeoff,
                          seleccionar: _controller.seleccionarOrigen,
                          validar: _controller.validarOrigen,
                        ),
                        const SizedBox(height: 16),
                        _selectorCiudad(
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
                                : 'Buscar viajeros disponibles',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_controller.buscando)
                    const Center(child: CircularProgressIndicator()),
                  if (_controller.errorBusqueda != null)
                    _mensaje(
                      Icons.error_outline,
                      _controller.errorBusqueda!,
                    ),
                  if (!_controller.buscando &&
                      _controller.errorBusqueda == null &&
                      _controller.busquedaRealizada) ...[
                    if (_controller.resultados.isEmpty)
                      _mensaje(
                        Icons.search_off,
                        'No se encontraron viajeros disponibles '
                        'para esta ruta.',
                      )
                    else ...[
                      Text(
                        'Viajeros encontrados: ${_controller.resultados.length}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final resultado in _controller.resultados)
                        _tarjetaViajero(resultado),
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

  Widget _selectorCiudad({
    required String etiqueta,
    required IconData icono,
    required ValueChanged<String?> seleccionar,
    required String? Function() validar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (valor) {
            final consulta = valor.text.trim().toLowerCase();
            if (consulta.length < 2) {
              return const Iterable<String>.empty();
            }
            return _controller.ciudades
                .where((ciudad) => ciudad.toLowerCase().contains(consulta))
                .take(12);
          },
          onSelected: seleccionar,
          fieldViewBuilder: (context, texto, foco, _) {
            return TextFormField(
              controller: texto,
              focusNode: foco,
              onChanged: (_) => seleccionar(null),
              validator: (_) => validar(),
              decoration: InputDecoration(
                hintText: 'Escribe al menos 2 letras',
                prefixIcon: Icon(icono),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _tarjetaViajero(ViajeDisponible resultado) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppTheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  resultado.nombreUsuario ??
                      'Nombre no informado por la API',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${resultado.viaje.ciudadOrigen} → ${resultado.viaje.ciudadDestino}',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          if (resultado.fechaInformada != null) ...[
            const SizedBox(height: 6),
            Text(
              'Fecha: ${formatearFechaVisible(resultado.fechaInformada!)}',
            ),
          ],
          if (resultado.numeroVuelo != null) ...[
            const SizedBox(height: 6),
            Text('Vuelo: ${resultado.numeroVuelo}'),
          ],
          if (resultado.estado != null) ...[
            const SizedBox(height: 6),
            Text('Estado: ${resultado.estado}'),
          ],
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

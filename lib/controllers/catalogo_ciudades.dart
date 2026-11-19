import 'package:flutter/foundation.dart';

import '../services/ciudades_service.dart';

/// Comparte solo la carga del catálogo. Cada controlador gestiona su formulario.
mixin CatalogoCiudades on ChangeNotifier {
  @protected
  late final CiudadesService servicioCiudades;

  List<String> _ciudades = const [];
  String? _errorCiudades;
  bool _cargandoCiudades = false;
  bool _catalogoDescartado = false;

  List<String> get ciudades => _ciudades;
  String? get errorCiudades => _errorCiudades;
  bool get cargandoCiudades => _cargandoCiudades;

  Future<void> cargarCiudades() async {
    if (_catalogoDescartado || _cargandoCiudades) return;
    _cargandoCiudades = true;
    _errorCiudades = null;
    notifyListeners();

    try {
      _ciudades = List.unmodifiable(await servicioCiudades.obtenerCiudades());
      if (_ciudades.isEmpty) {
        _errorCiudades = 'El catálogo de ciudades está vacío.';
      }
    } catch (_) {
      _errorCiudades =
          'No fue posible cargar las ciudades. Revisa tu conexión.';
    } finally {
      _cargandoCiudades = false;
      if (!_catalogoDescartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _catalogoDescartado = true;
    super.dispose();
  }
}

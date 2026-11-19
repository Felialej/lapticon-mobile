import 'package:flutter/foundation.dart';

import '../services/ciudades_service.dart';

class CatalogoPaisesController extends ChangeNotifier {
  CatalogoPaisesController({CiudadesService? servicio})
    : _servicio = servicio ?? CiudadesService();

  final CiudadesService _servicio;
  List<String> _paises = const [];
  String? _error;
  bool _cargando = false;
  bool _descartado = false;

  List<String> get paises => _paises;
  String? get error => _error;
  bool get cargando => _cargando;

  bool contiene(String? pais) => _paises.contains(pais);

  String? validarPais(String? pais) =>
      contiene(pais) ? null : 'Selecciona tu país de nacimiento';

  Future<void> cargar({bool actualizar = false}) async {
    if (_descartado || _cargando || (!actualizar && _paises.isNotEmpty)) return;
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _paises = List.unmodifiable(
        await _servicio.obtenerPaises().timeout(const Duration(seconds: 30)),
      );
      if (_paises.isEmpty) _error = 'No hay países disponibles.';
    } catch (_) {
      _error = 'No pudimos cargar los países.';
    } finally {
      _cargando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}

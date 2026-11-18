import 'package:flutter/foundation.dart';

import '../models/encomienda.dart';
import '../services/ciudades_service.dart';
import '../services/encomiendas_service.dart';

/// HU-12: filtros, resultados, errores y carga de encomiendas disponibles.
class BuscarEncomiendasController extends ChangeNotifier {
  BuscarEncomiendasController({
    required this.idToken,
    CiudadesService? ciudadesService,
    EncomiendasService? encomiendasService,
  }) : _ciudadesService = ciudadesService ?? CiudadesService(),
       _encomiendasService = encomiendasService ?? EncomiendasService();

  final String idToken;
  final CiudadesService _ciudadesService;
  final EncomiendasService _encomiendasService;

  List<String> _ciudades = [];
  List<Encomienda> _resultados = [];
  String? _origen;
  String? _destino;
  String? _errorCiudades;
  String? _errorBusqueda;
  bool _cargandoCiudades = false;
  bool _buscando = false;
  bool _busquedaRealizada = false;
  int _versionBusqueda = 0;
  bool _disposed = false;

  List<String> get ciudades => List.unmodifiable(_ciudades);
  List<Encomienda> get resultados => List.unmodifiable(_resultados);
  String? get origen => _origen;
  String? get destino => _destino;
  String? get errorCiudades => _errorCiudades;
  String? get errorBusqueda => _errorBusqueda;
  bool get cargandoCiudades => _cargandoCiudades;
  bool get buscando => _buscando;
  bool get busquedaRealizada => _busquedaRealizada;

  Future<void> cargarCiudades() async {
    if (_disposed) return;
    _cargandoCiudades = true;
    _errorCiudades = null;
    notifyListeners();
    try {
      final recibidas = await _ciudadesService.obtenerCiudades();
      if (_disposed) return;
      _ciudades =
          recibidas
              .map((ciudad) => ciudad.trim())
              .where((ciudad) => ciudad.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (_ciudades.isEmpty) {
        _errorCiudades = 'El catálogo de ciudades está vacío.';
      }
    } catch (_) {
      if (_disposed) return;
      _errorCiudades =
          'No fue posible cargar las ciudades. Revisa tu conexión.';
    } finally {
      if (!_disposed) {
        _cargandoCiudades = false;
        notifyListeners();
      }
    }
  }

  void seleccionarOrigen(String? ciudad) {
    if (_disposed) return;
    _origen = _ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  void seleccionarDestino(String? ciudad) {
    if (_disposed) return;
    _destino = _ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  void _limpiarBusqueda() {
    _versionBusqueda++;
    _buscando = false;
    _busquedaRealizada = false;
    _resultados = [];
    _errorBusqueda = null;
    notifyListeners();
  }

  String? validarOrigen() =>
      _origen == null ? 'Selecciona una ciudad del catálogo.' : null;

  String? validarDestino() =>
      _destino == null ? 'Selecciona una ciudad del catálogo.' : null;

  Future<void> buscar() async {
    if (_disposed) return;
    if (_origen == null || _destino == null) {
      _errorBusqueda = 'Selecciona las ciudades de origen y destino.';
      notifyListeners();
      return;
    }
    if (_origen == _destino) {
      _errorBusqueda = 'Origen y destino deben ser diferentes.';
      notifyListeners();
      return;
    }
    if (idToken.trim().isEmpty) {
      _errorBusqueda = 'Tu sesión expiró. Vuelve a iniciar sesión.';
      notifyListeners();
      return;
    }

    final version = ++_versionBusqueda;
    _buscando = true;
    _busquedaRealizada = true;
    _resultados = [];
    _errorBusqueda = null;
    notifyListeners();

    try {
      final encontrados = await _encomiendasService
          .buscarEncomiendasDisponibles(
            origen: _origen!,
            destino: _destino!,
            idToken: idToken,
          );
      if (!_disposed && version == _versionBusqueda) {
        _resultados = encontrados;
      }
    } on EncomiendasException catch (e) {
      if (!_disposed && version == _versionBusqueda) {
        _errorBusqueda = switch (e.codigo) {
          'UNAUTHORIZED' =>
            'Tu sesión expiró o no tienes permiso. Inicia sesión otra vez.',
          'NETWORK_ERROR' => 'No fue posible conectar con el servidor.',
          'BAD_REQUEST' => 'Los filtros de búsqueda no son válidos.',
          'SERVER_ERROR' => 'El servidor presentó un problema.',
          'RESPUESTA_INVALIDA' =>
            'El servidor devolvió una respuesta no reconocida.',
          _ => 'No fue posible buscar encomiendas disponibles.',
        };
      }
    } catch (_) {
      if (!_disposed && version == _versionBusqueda) {
        _errorBusqueda = 'No fue posible completar la búsqueda.';
      }
    } finally {
      if (!_disposed && version == _versionBusqueda) {
        _buscando = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _versionBusqueda++;
    super.dispose();
  }
}

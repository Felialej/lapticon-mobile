import 'package:flutter/foundation.dart';

import '../models/viaje_disponible.dart';
import '../services/ciudades_service.dart';
import '../services/viajes_service.dart';

/// Estado y validaciones de la búsqueda de viajes como remitente.
class BuscarViajerosController extends ChangeNotifier {
  BuscarViajerosController({
    CiudadesService? ciudadesService,
    ViajesService? viajesService,
  })  : _ciudadesService = ciudadesService ?? CiudadesService(),
        _viajesService = viajesService ?? ViajesService();

  final CiudadesService _ciudadesService;
  final ViajesService _viajesService;

  List<String> _ciudades = [];
  List<ViajeDisponible> _resultados = [];
  String? _origen;
  String? _destino;
  String? _errorCiudades;
  String? _errorBusqueda;
  bool _cargandoCiudades = false;
  bool _buscando = false;
  bool _busquedaRealizada = false;
  int _versionBusqueda = 0;

  List<String> get ciudades => List.unmodifiable(_ciudades);
  List<ViajeDisponible> get resultados => List.unmodifiable(_resultados);
  String? get origen => _origen;
  String? get destino => _destino;
  String? get errorCiudades => _errorCiudades;
  String? get errorBusqueda => _errorBusqueda;
  bool get cargandoCiudades => _cargandoCiudades;
  bool get buscando => _buscando;
  bool get busquedaRealizada => _busquedaRealizada;

  Future<void> cargarCiudades() async {
    _cargandoCiudades = true;
    _errorCiudades = null;
    notifyListeners();

    try {
      final recibidas = await _ciudadesService.obtenerCiudades();
      final unicas = recibidas
          .map((ciudad) => ciudad.trim())
          .where((ciudad) => ciudad.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      _ciudades = unicas;
      if (_ciudades.isEmpty) {
        _errorCiudades = 'El catálogo de ciudades está vacío.';
      }
    } catch (_) {
      _errorCiudades =
          'No fue posible cargar las ciudades. Revisa tu conexión.';
    } finally {
      _cargandoCiudades = false;
      notifyListeners();
    }
  }

  void seleccionarOrigen(String? ciudad) {
    _origen = _ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  void seleccionarDestino(String? ciudad) {
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

    final version = ++_versionBusqueda;
    _buscando = true;
    _busquedaRealizada = true;
    _resultados = [];
    _errorBusqueda = null;
    notifyListeners();

    try {
      final encontrados = await _viajesService.buscarViajesDisponibles(
        ciudadOrigen: _origen!,
        ciudadDestino: _destino!,
      );
      if (version == _versionBusqueda) {
        _resultados = encontrados;
      }
    } on ViajesException catch (excepcion) {
      if (version == _versionBusqueda) {
        switch (excepcion.codigo) {
          case 'NETWORK_ERROR':
            _errorBusqueda = 'No fue posible conectar con el servidor.';
          case 'BAD_REQUEST':
            _errorBusqueda = excepcion.detalle ??
                'Los filtros de búsqueda no son válidos.';
          case 'SERVER_ERROR':
            _errorBusqueda = 'El servidor presentó un problema.';
          case 'RESPUESTA_INVALIDA':
            _errorBusqueda = 'El servidor devolvió una respuesta no válida.';
          default:
            _errorBusqueda =
                excepcion.detalle ?? 'No fue posible buscar viajeros.';
        }
      }
    } catch (_) {
      if (version == _versionBusqueda) {
        _errorBusqueda = 'No fue posible completar la búsqueda.';
      }
    } finally {
      if (version == _versionBusqueda) {
        _buscando = false;
        notifyListeners();
      }
    }
  }
}

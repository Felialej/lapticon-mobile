import 'package:flutter/foundation.dart';

import '../models/viaje_disponible.dart';
import '../services/ciudades_service.dart';
import '../services/viajes_service.dart';

import 'catalogo_ciudades.dart';

/// Estado y validaciones de la búsqueda de viajes como remitente.
class BuscarViajerosController extends ChangeNotifier with CatalogoCiudades {
  BuscarViajerosController({
    CiudadesService? ciudadesService,
    ViajesService? viajesService,
  }) : _viajesService = viajesService ?? ViajesService() {
    servicioCiudades = ciudadesService ?? CiudadesService();
  }

  final ViajesService _viajesService;

  List<ViajeDisponible> _resultados = [];
  String? _origen;
  String? _destino;
  String? _errorBusqueda;
  bool _buscando = false;
  bool _busquedaRealizada = false;
  int _versionBusqueda = 0;

  List<ViajeDisponible> get resultados => List.unmodifiable(_resultados);
  String? get origen => _origen;
  String? get destino => _destino;
  String? get errorBusqueda => _errorBusqueda;
  bool get buscando => _buscando;
  bool get busquedaRealizada => _busquedaRealizada;

  void seleccionarOrigen(String? ciudad) {
    _origen = ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  void seleccionarDestino(String? ciudad) {
    _destino = ciudades.contains(ciudad) ? ciudad : null;
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

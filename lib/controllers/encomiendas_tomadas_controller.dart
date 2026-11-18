import 'package:flutter/foundation.dart';

import '../models/encomienda.dart';
import '../services/ciudades_service.dart';
import '../services/encomiendas_service.dart';

/// Filtros y resultados de las encomiendas tomadas del viajero autenticado.
class EncomiendasTomadasController extends ChangeNotifier {
  EncomiendasTomadasController({
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
  String? _entregandoId;
  String? _errorEntrega;
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
  String? get entregandoId => _entregandoId;
  bool get confirmandoEntrega => _entregandoId != null;
  String? get errorEntrega => _errorEntrega;

  Future<void> cargarCiudades() async {
    _cargandoCiudades = true;
    _errorCiudades = null;
    notifyListeners();
    try {
      final recibidas = [
        ...await _ciudadesService.obtenerCiudades(),
        'Bogota',
        'Medellin',
        'Cali',
        'Madrid',
        'Paris',
        'Miami',
      ];
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
    _origen = _ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  void seleccionarDestino(String? ciudad) {
    _destino = _ciudades.contains(ciudad) ? ciudad : null;
    _limpiarBusqueda();
  }

  /// HU-14: confirma la entrega y actualiza la tarjeta solo si el backend
  /// completó la operación. No inventa un historial de entregas.
  Future<bool> confirmarEntrega(Encomienda encomienda) async {
    if (_disposed || _entregandoId != null) {
      return false;
    }

    final id = encomienda.id?.trim();
    if (encomienda.estado != EstadoEncomienda.tomada) {
      _errorEntrega = 'Solo se pueden entregar encomiendas tomadas.';
      notifyListeners();
      return false;
    }
    if (id == null || id.isEmpty) {
      _errorEntrega = 'La encomienda no tiene un identificador válido.';
      notifyListeners();
      return false;
    }
    if (idToken.trim().isEmpty) {
      _errorEntrega = 'Tu sesión no es válida. Vuelve a iniciar sesión.';
      notifyListeners();
      return false;
    }

    final version = _versionBusqueda;
    _entregandoId = id;
    _errorEntrega = null;
    notifyListeners();
    try {
      await _encomiendasService.confirmarEntrega(id: id, idToken: idToken);
      if (_disposed) {
        return false;
      }

      if (version == _versionBusqueda) {
        final indice = _resultados.indexWhere((elemento) => elemento.id == id);
        if (indice != -1) {
          final original = _resultados[indice];
          _resultados = List<Encomienda>.of(_resultados);
          _resultados[indice] = Encomienda(
            id: original.id,
            ciudadOrigen: original.ciudadOrigen,
            ciudadDestino: original.ciudadDestino,
            observaciones: original.observaciones,
            moneda: original.moneda,
            valor: original.valor,
            estado: EstadoEncomienda.recibida,
          );
        }
      }
      return true;
    } on EncomiendasException catch (excepcion) {
      if (_disposed) {
        return false;
      }
      _errorEntrega = switch (excepcion.codigo) {
        'UNAUTHORIZED' =>
          'Tu sesión expiró o no tienes permiso para confirmar esta entrega.',
        'NETWORK_ERROR' => 'No fue posible conectar con el servidor.',
        'INVALID_STATE' =>
          'La encomienda ya no está en estado tomada o no puede entregarse.',
        'NOT_FOUND' => 'La encomienda ya no existe.',
        'BAD_REQUEST' => 'La solicitud de entrega no es válida.',
        'SERVER_ERROR' => 'El servidor presentó un problema.',
        'RESPUESTA_INVALIDA' => 'El servidor no confirmó el estado recibida.',
        _ => 'No fue posible confirmar la entrega.',
      };
      return false;
    } catch (_) {
      if (_disposed) {
        return false;
      }
      _errorEntrega = 'No fue posible confirmar la entrega.';
      return false;
    } finally {
      if (!_disposed) {
        _entregandoId = null;
        notifyListeners();
      }
    }
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
      final encontrados = await _encomiendasService.buscarEncomiendasTomadas(
        origen: _origen!,
        destino: _destino!,
        idToken: idToken,
      );
      if (version == _versionBusqueda) {
        _resultados = encontrados;
      }
    } on EncomiendasException catch (excepcion) {
      if (version == _versionBusqueda) {
        _errorBusqueda = switch (excepcion.codigo) {
          'UNAUTHORIZED' =>
            'Tu sesión expiró o no tiene permiso para esta '
                'consulta. Vuelve a iniciar sesión.',
          'NETWORK_ERROR' => 'No fue posible conectar con el servidor.',
          'BAD_REQUEST' => 'Los filtros de búsqueda no son válidos.',
          'SERVER_ERROR' => 'El servidor presentó un problema.',
          'RESPUESTA_INVALIDA' =>
            'El servidor devolvió una respuesta no válida.',
          _ => 'No fue posible consultar las encomiendas tomadas.',
        };
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

  @override
  void dispose() {
    _disposed = true;
    _versionBusqueda++;
    super.dispose();
  }
}

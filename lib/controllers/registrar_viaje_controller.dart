import 'package:flutter/foundation.dart';

import '../models/viaje.dart';
import '../services/ciudades_service.dart';
import '../services/viajes_service.dart';

import 'catalogo_ciudades.dart';

/// Controlador del formulario de registro de viaje.
///
/// Administra los valores seleccionados, las validaciones y el registro
/// del viaje mediante el servicio correspondiente.
class RegistrarViajeController extends ChangeNotifier with CatalogoCiudades {
  RegistrarViajeController({
    ViajesService? viajesService,
    CiudadesService? ciudadesService,
  }) : _viajesService = viajesService ?? ViajesService() {
    servicioCiudades = ciudadesService ?? CiudadesService();
  }

  final ViajesService _viajesService;

  String? _origen;
  String? _destino;
  DateTime? _fecha;

  bool _cargando = false;
  String? _error;

  String? get origen => _origen;

  String? get destino => _destino;

  DateTime? get fecha => _fecha;

  bool get cargando => _cargando;

  String? get error => _error;

  DateTime get fechaMinima {
    final ahora = DateTime.now();

    return DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    );
  }

  DateTime get fechaMaxima {
    return DateTime(
      DateTime.now().year + 2,
    );
  }

  void seleccionarOrigen(String? ciudad) {
    _origen = ciudad;
    notifyListeners();
  }

  void seleccionarDestino(String? ciudad) {
    _destino = ciudad;
    notifyListeners();
  }

  void seleccionarFecha(DateTime fechaElegida) {
    _fecha = fechaElegida;
    notifyListeners();
  }

  String? validarNumeroVuelo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el número de vuelo';
    }

    return null;
  }

  String? validarOrigen() => _validarCiudad(_origen);

  String? validarDestino() => _validarCiudad(_destino);

  String? _validarCiudad(String? valor) =>
      valor == null ? 'Selecciona una ciudad del catálogo.' : null;

  String? validarSeleccion() {
    if (_origen == null || _destino == null) {
      return 'Selecciona las ciudades de origen y destino';
    }

    if (_fecha == null) {
      return 'Selecciona la fecha del viaje';
    }

    if (_origen == _destino) {
      return 'Origen y destino deben ser diferentes';
    }

    return null;
  }

  Viaje construirViaje(String numeroVuelo) {
    return Viaje(
      numeroVuelo: numeroVuelo.trim().toUpperCase(),
      ciudadOrigen: _origen!,
      ciudadDestino: _destino!,
      fechaViaje: _fecha!,
    );
  }

  /// Valida los datos ya seleccionados y registra el viaje en el backend.
  ///
  /// Devuelve el viaje que respondió el servidor cuando el registro fue
  /// exitoso. Devuelve nulo si ocurrió un error.
  Future<Viaje?> registrarViaje({
    required String numeroVuelo,
    required String idToken,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final viaje = construirViaje(
        numeroVuelo,
      );

      return await _viajesService.registrarViaje(
        viaje: viaje,
        idToken: idToken,
      );
    } on ViajesException catch (excepcion) {
      _error = _mensajeDeError(excepcion);
      return null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _mensajeDeError(
    ViajesException excepcion,
  ) {
    switch (excepcion.codigo) {
      case 'BAD_REQUEST':
        return excepcion.detalle ??
            'Ya existe un viaje disponible o los datos enviados no son válidos.';

      case 'UNAUTHORIZED':
        return 'Tu sesión no es válida o expiró. Inicia sesión nuevamente.';

      case 'NETWORK_ERROR':
        return 'No fue posible conectar con el servidor. Revisa tu conexión a Internet.';

      case 'SERVER_ERROR':
        return 'El servidor presentó un problema. Intenta nuevamente más tarde.';

      case 'RESPUESTA_INVALIDA':
        return 'El servidor devolvió una respuesta no válida.';
    }

    return excepcion.detalle ??
        'No fue posible registrar el viaje.';
  }
}
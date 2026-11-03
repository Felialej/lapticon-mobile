import 'package:flutter/foundation.dart';

import '../models/viaje.dart';
import '../services/viajes_service.dart';

/// Controlador de los viajes registrados por el usuario.
class ViajesController extends ChangeNotifier {
  ViajesController({
    ViajesService? viajesService,
  }) : _viajesService = viajesService ?? ViajesService();

  final ViajesService _viajesService;

  final List<Viaje> _viajes = [];

  bool _cargando = false;
  String? _error;

  List<Viaje> get viajes {
  final listaOrdenada = List<Viaje>.from(_viajes);

  listaOrdenada.sort((a, b) {
    final aDisponible =
        a.estado.trim().toLowerCase() ==
            Viaje.estadoDisponible;

    final bDisponible =
        b.estado.trim().toLowerCase() ==
            Viaje.estadoDisponible;

    if (aDisponible && !bDisponible) {
      return -1;
    }

    if (!aDisponible && bDisponible) {
      return 1;
    }

    return b.fechaViaje.compareTo(
      a.fechaViaje,
    );
  });

  return List.unmodifiable(
    listaOrdenada,
  );
}

  int get cantidad => _viajes.length;

  bool get estaVacio => _viajes.isEmpty;

  bool get cargando => _cargando;

  String? get error => _error;

  void agregar(Viaje viaje) {
    _viajes.add(viaje);
    notifyListeners();
  }

  /// Marca un viaje como completado en el backend.
  Future<bool> completarViaje({
    required Viaje viaje,
    required String idToken,
  }) async {
    if (viaje.id == null ||
        viaje.id!.isEmpty) {
      _error =
          'El viaje no tiene un identificador válido.';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _viajesService.cambiarEstadoViaje(
        viajeId: viaje.id!,
        estado: Viaje.estadoCompletado,
        idToken: idToken,
      );

      final indice = _viajes.indexWhere(
        (elemento) =>
            elemento.id == viaje.id,
      );

      if (indice != -1) {
        _viajes[indice] =
            viaje.copyWith(
          estado:
              Viaje.estadoCompletado,
        );
      }

      return true;
    } on ViajesException catch (excepcion) {
      _error =
          _mensajeDeError(excepcion);
      return false;
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
            'No fue posible cambiar el estado del viaje.';

      case 'UNAUTHORIZED':
        return 'Tu sesión expiró o no es válida.';

      case 'FORBIDDEN':
        return 'No tienes permiso para modificar este viaje.';

      case 'NOT_FOUND':
        return 'El viaje no fue encontrado.';

      case 'NETWORK_ERROR':
        return 'No fue posible conectar con el servidor.';

      case 'SERVER_ERROR':
        return 'El servidor presentó un problema.';
    }

    return excepcion.detalle ??
        'No fue posible completar el viaje.';
  }

Future<void> cargarViajes({
  required String idToken,
}) async {
  _cargando = true;
  _error = null;
  notifyListeners();

  try {
    final viajesBackend =
        await _viajesService.obtenerViajes(
      idToken: idToken,
    );

    _viajes
      ..clear()
      ..addAll(viajesBackend);
  } on ViajesException catch (excepcion) {
    _error = _mensajeDeError(excepcion);
  } finally {
    _cargando = false;
    notifyListeners();
  }
}

}
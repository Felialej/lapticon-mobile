import 'package:flutter/foundation.dart';

import '../models/encomienda.dart';
import '../services/encomiendas_service.dart';

/// HU-13: confirma una toma solo si el backend acepta la solicitud.
class TomarEncomiendaController extends ChangeNotifier {
  TomarEncomiendaController({
    required this.idToken,
    EncomiendasService? servicio,
  }) : _servicio = servicio ?? EncomiendasService();

  final String idToken;
  final EncomiendasService _servicio;
  bool _procesando = false;
  bool _tomada = false;
  bool _disposed = false;
  String? _error;

  bool get procesando => _procesando;
  bool get tomada => _tomada;
  String? get error => _error;

  Future<bool> aceptar(Encomienda encomienda) async {
    if (_disposed || _procesando || _tomada) return false;
    _error = null;
    if (encomienda.estado != EstadoEncomienda.disponible) {
      _error = 'La encomienda ya no está disponible.';
      notifyListeners();
      return false;
    }
    if (encomienda.id == null || encomienda.id!.trim().isEmpty) {
      _error = 'La encomienda no tiene un identificador válido.';
      notifyListeners();
      return false;
    }
    if (idToken.trim().isEmpty) {
      _error = 'Tu sesión expiró. Inicia sesión nuevamente.';
      notifyListeners();
      return false;
    }

    _procesando = true;
    notifyListeners();
    try {
      await _servicio.tomarEncomienda(id: encomienda.id!, idToken: idToken);
      if (_disposed) return false;
      _tomada = true;
      return true;
    } on EncomiendasException catch (e) {
      if (_disposed) return false;
      _error = switch (e.codigo) {
        'NOT_AVAILABLE' =>
          'La encomienda ya no está disponible. Vuelve a buscar.',
        'UNAUTHORIZED' => 'No tienes permiso o tu sesión expiró.',
        'BAD_REQUEST' => 'La solicitud de asignación no es válida.',
        'NETWORK_ERROR' => 'No se pudo conectar con el servidor.',
        'SERVER_ERROR' => 'El servidor presentó un problema.',
        'RESPUESTA_INVALIDA' =>
          'No se pudo confirmar el estado devuelto por el servidor. Consulta tus encomiendas tomadas antes de volver a intentarlo.',
        _ => 'No se pudo tomar la encomienda.',
      };
      return false;
    } catch (_) {
      if (_disposed) return false;
      _error = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      if (!_disposed) {
        _procesando = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

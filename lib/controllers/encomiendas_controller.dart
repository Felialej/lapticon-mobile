import 'package:flutter/foundation.dart';

import '../models/encomienda.dart';
import '../services/encomiendas_service.dart';

class EncomiendasController extends ChangeNotifier {
  EncomiendasController({
    EncomiendasService? encomiendasService,
  }) : _encomiendasService =
           encomiendasService ?? EncomiendasService();

  final EncomiendasService _encomiendasService;

  final List<Encomienda> _encomiendas = [];

  bool _cargando = false;
  String? _error;

  List<Encomienda> get encomiendas =>
      List.unmodifiable(_encomiendas);

  int get cantidad => _encomiendas.length;

  bool get estaVacio => _encomiendas.isEmpty;

  bool get cargando => _cargando;

  String? get error => _error;

  void agregar(Encomienda encomienda) {
    _encomiendas.insert(0, encomienda);
    notifyListeners();
  }

  Future<void> cargarEncomiendas({
    required String idToken,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final encomiendasBackend =
          await _encomiendasService.obtenerEncomiendas(
        idToken: idToken,
      );

      _encomiendas
        ..clear()
        ..addAll(encomiendasBackend);
    } on EncomiendasException catch (excepcion) {
      _error = _mensajeDeError(excepcion);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _mensajeDeError(
    EncomiendasException excepcion,
  ) {
    switch (excepcion.codigo) {
      case 'UNAUTHORIZED':
        return 'Tu sesión expiró o no es válida.';

      case 'NETWORK_ERROR':
        return 'No fue posible conectar con el servidor.';

      case 'SERVER_ERROR':
        return 'El servidor presentó un problema.';

      case 'RESPUESTA_INVALIDA':
        return 'El servidor devolvió una respuesta no válida.';
    }

    return excepcion.detalle ??
        'No fue posible consultar tus encomiendas.';
  }
}

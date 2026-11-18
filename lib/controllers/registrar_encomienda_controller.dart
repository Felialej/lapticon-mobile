import 'package:flutter/foundation.dart';

import '../models/encomienda.dart';
import '../services/encomiendas_service.dart';
import '../utils/validadores.dart';

class RegistrarEncomiendaController extends ChangeNotifier {
  RegistrarEncomiendaController({
    EncomiendasService? encomiendasService,
  }) : _encomiendasService =
           encomiendasService ?? EncomiendasService();

  final EncomiendasService _encomiendasService;

  static const List<String> ciudadesDisponibles = [
    'Bogota',
    'Medellin',
    'Cali',
    'Madrid',
    'Paris',
    'Miami',
  ];

  static const List<String> monedasDisponibles = [
    'USD',
    'COP',
    'EUR',
  ];

  static final _formatoValor = RegExp(
    r'^(?:[0-9]+|[0-9]{1,3}(?:\.[0-9]{3})+)(?:,[0-9]+)?$',
  );

  String? _origen;
  String? _destino;
  String? _moneda;

  bool _cargando = false;
  String? _error;

  String? get origen => _origen;

  String? get destino => _destino;

  String? get moneda => _moneda;

  bool get cargando => _cargando;

  String? get error => _error;

  void seleccionarOrigen(String? ciudad) {
    _origen = ciudad;
    notifyListeners();
  }

  void seleccionarDestino(String? ciudad) {
    _destino = ciudad;
    notifyListeners();
  }

  void seleccionarMoneda(String? moneda) {
    _moneda = moneda;
    notifyListeners();
  }

  String? validarCiudad(String? valor) {
    if (valor == null) {
      return 'Selecciona una ciudad';
    }

    return null;
  }

  String? validarMoneda(String? valor) {
    if (valor == null) {
      return 'Selecciona la moneda';
    }

    return null;
  }

  String? validarObservaciones(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Describe tu encomienda';
    }

    return null;
  }

  String? validarValor(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa el valor declarado';
    }

    if (superaMaximoValorDeclarado(texto)) {
      return mensajeMaximoValorDeclarado;
    }

    final numero = _interpretarValor(texto);

    if (numero == null) {
      return 'El valor debe ser un número';
    }

    if (numero <= 0) {
      return 'El valor debe ser mayor que cero';
    }

    return null;
  }

  static double? _interpretarValor(String texto) {
    if (!_formatoValor.hasMatch(texto)) return null;

    final normalizado = texto.replaceAll('.', '').replaceAll(',', '.');
    final numero = double.tryParse(normalizado);
    return numero != null && numero.isFinite ? numero : null;
  }

  String? validarSeleccion() {
    if (_origen == _destino) {
      return 'Origen y destino deben ser diferentes';
    }

    return null;
  }

  Encomienda construirEncomienda({
    required String observaciones,
    required String valor,
  }) {
    final texto = valor.trim();
    if (superaMaximoValorDeclarado(texto)) {
      throw const FormatException(mensajeMaximoValorDeclarado);
    }

    final numero = _interpretarValor(texto);
    if (numero == null) {
      throw const FormatException('El valor declarado no es válido');
    }

    return Encomienda(
      ciudadOrigen: _origen!,
      ciudadDestino: _destino!,
      observaciones: observaciones.trim(),
      moneda: _moneda!,
      valor: numero,
    );
  }

  Future<Encomienda?> registrarEncomienda({
    required String observaciones,
    required String valor,
    required String idToken,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final encomienda = construirEncomienda(
        observaciones: observaciones,
        valor: valor,
      );

      return await _encomiendasService.registrarEncomienda(
        encomienda: encomienda,
        idToken: idToken,
      );
    } on EncomiendasException catch (excepcion) {
      _error = _mensajeDeError(excepcion);
      return null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _mensajeDeError(
    EncomiendasException excepcion,
  ) {
    switch (excepcion.codigo) {
      case 'BAD_REQUEST':
        return excepcion.detalle ??
            'Los datos enviados no son válidos.';

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
        'No fue posible registrar la encomienda.';
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/encomienda.dart';

class EncomiendasException implements Exception {
  const EncomiendasException({
    required this.codigo,
    this.detalle,
  });

  final String codigo;
  final String? detalle;

  @override
  String toString() => 'EncomiendasException($codigo)';
}

class EncomiendasService {
  /// Consulta únicamente las encomiendas tomadas que devuelve la API para
  /// la ruta y el viajero autenticado. No representa un historial de entregas.
  Future<List<Encomienda>> buscarEncomiendasTomadas({
    required String origen,
    required String destino,
    required String idToken,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.backendUrl}/api/encomiendas/buscar',
    ).replace(queryParameters: {'origen': origen, 'destino': destino});

    final http.Response respuesta;
    try {
      respuesta = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $idToken',
      });
    } catch (_) {
      throw const EncomiendasException(codigo: 'NETWORK_ERROR');
    }

    // Clasificar el estado HTTP también cuando el servidor responde sin JSON.
    if (respuesta.statusCode != 200) {
      final codigo = switch (respuesta.statusCode) {
        400 => 'BAD_REQUEST',
        401 || 403 => 'UNAUTHORIZED',
        >= 500 => 'SERVER_ERROR',
        _ => 'UNKNOWN_ERROR',
      };
      throw EncomiendasException(codigo: codigo);
    }

    try {
      final datos = jsonDecode(respuesta.body);
      if (datos is! Map<String, dynamic> || datos['tomadas'] is! List) {
        throw const FormatException('Se esperaba el arreglo tomadas.');
      }
      return (datos['tomadas'] as List).map((elemento) {
        if (elemento is! Map<String, dynamic>) {
          throw const FormatException('Encomienda no válida.');
        }
        return Encomienda.desdeJson(elemento);
      }).toList();
    } catch (_) {
      throw const EncomiendasException(codigo: 'RESPUESTA_INVALIDA');
    }
  }

  Future<List<Encomienda>> obtenerEncomiendas({
    required String idToken,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.backendUrl}/api/encomiendas',
    );

    final http.Response respuesta;

    try {
      respuesta = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    } catch (_) {
      throw const EncomiendasException(
        codigo: 'NETWORK_ERROR',
      );
    }

    dynamic datos;

    if (respuesta.body.isNotEmpty) {
      try {
        datos = jsonDecode(respuesta.body);
      } catch (_) {
        throw const EncomiendasException(
          codigo: 'RESPUESTA_INVALIDA',
        );
      }
    }

    if (respuesta.statusCode == 200) {
      if (datos is! List) {
        throw const EncomiendasException(
          codigo: 'RESPUESTA_INVALIDA',
        );
      }

      return datos
          .whereType<Map<String, dynamic>>()
          .map(Encomienda.desdeJson)
          .toList();
    }

    String? detalle;

    if (datos is Map<String, dynamic>) {
      detalle =
          datos['message']?.toString() ??
          datos['error']?.toString();
    }

    if (respuesta.statusCode == 401) {
      throw EncomiendasException(
        codigo: 'UNAUTHORIZED',
        detalle: detalle,
      );
    }

    if (respuesta.statusCode >= 500) {
      throw EncomiendasException(
        codigo: 'SERVER_ERROR',
        detalle: detalle,
      );
    }

    throw EncomiendasException(
      codigo: 'UNKNOWN_ERROR',
      detalle: detalle,
    );
  }

  Future<Encomienda> registrarEncomienda({
    required Encomienda encomienda,
    required String idToken,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.backendUrl}/api/encomiendas',
    );

    final http.Response respuesta;

    try {
      respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(
          encomienda.toJson(),
        ),
      );
    } catch (_) {
      throw const EncomiendasException(
        codigo: 'NETWORK_ERROR',
      );
    }

    Map<String, dynamic>? datos;

    if (respuesta.body.isNotEmpty) {
      try {
        final json = jsonDecode(respuesta.body);

        if (json is Map<String, dynamic>) {
          datos = json;
        }
      } catch (_) {
        datos = null;
      }
    }

    if (respuesta.statusCode == 201 ||
        respuesta.statusCode == 200) {
      if (datos == null) {
        throw const EncomiendasException(
          codigo: 'RESPUESTA_INVALIDA',
        );
      }

      final encomiendaJson = datos['encomienda'];

      if (encomiendaJson is Map<String, dynamic>) {
        return Encomienda.desdeJson(encomiendaJson);
      }

      return Encomienda.desdeJson(datos);
    }

    final detalle =
        datos?['message']?.toString() ??
        datos?['error']?.toString();

    if (respuesta.statusCode == 400) {
      throw EncomiendasException(
        codigo: 'BAD_REQUEST',
        detalle: detalle,
      );
    }

    if (respuesta.statusCode == 401) {
      throw EncomiendasException(
        codigo: 'UNAUTHORIZED',
        detalle: detalle,
      );
    }

    if (respuesta.statusCode >= 500) {
      throw EncomiendasException(
        codigo: 'SERVER_ERROR',
        detalle: detalle,
      );
    }

    throw EncomiendasException(
      codigo: 'UNKNOWN_ERROR',
      detalle: detalle,
    );
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/viaje.dart';
import '../models/viaje_disponible.dart';

/// Error producido al consumir los endpoints de viajes.
class ViajesException implements Exception {
  const ViajesException({
    required this.codigo,
    this.detalle,
  });

  final String codigo;
  final String? detalle;

  @override
  String toString() => 'ViajesException($codigo)';
}

/// Servicio encargado de comunicarse con los endpoints REST de viajes.
///
/// No construye interfaz ni guarda estado. Su única responsabilidad es
/// comunicarse con el backend y convertir JSON en modelos de la aplicación.
class ViajesService {
  /// Registra un nuevo viaje para el usuario autenticado.
  ///
  /// El backend exige el ID Token de Firebase en:
  /// Authorization: Bearer idToken
  Future<Viaje> registrarViaje({
    required Viaje viaje,
    required String idToken,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.backendUrl}/api/viajes',
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
          viaje.toJson(),
        ),
      );
    } catch (_) {
      throw const ViajesException(
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
        // El status HTTP se procesa igualmente aunque el body
        // no tenga un JSON válido.
      }
    }

    if (respuesta.statusCode == 201) {
      if (datos == null) {
        throw const ViajesException(
          codigo: 'RESPUESTA_INVALIDA',
        );
      }

      // Se admite tanto una respuesta directa:
      // { "_id": ..., "numeroVuelo": ... }
      //
      // como una respuesta envuelta:
      // { "viaje": { ... } }
      final viajeJson = datos['viaje'];

      if (viajeJson is Map<String, dynamic>) {
        return Viaje.desdeJson(viajeJson);
      }

      return Viaje.desdeJson(datos);
    }

    final detalle =
        datos?['message']?.toString() ??
        datos?['error']?.toString();

    if (respuesta.statusCode == 400) {
      throw ViajesException(
        codigo: 'BAD_REQUEST',
        detalle: detalle,
      );
    }

    if (respuesta.statusCode == 401) {
      throw ViajesException(
        codigo: 'UNAUTHORIZED',
        detalle: detalle,
      );
    }

    if (respuesta.statusCode >= 500) {
      throw ViajesException(
        codigo: 'SERVER_ERROR',
        detalle: detalle,
      );
    }

    throw ViajesException(
      codigo: 'UNKNOWN_ERROR',
      detalle: detalle,
    );
  }

  Future<List<Viaje>> obtenerViajes({
  required String idToken,
}) async {
  final uri = Uri.parse(
    '${ApiConfig.backendUrl}/api/viajes',
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
    throw const ViajesException(
      codigo: 'NETWORK_ERROR',
    );
  }

  dynamic datos;

  if (respuesta.body.isNotEmpty) {
    try {
      datos = jsonDecode(respuesta.body);
    } catch (_) {
      throw const ViajesException(
        codigo: 'RESPUESTA_INVALIDA',
      );
    }
  }

  if (respuesta.statusCode == 200) {
    if (datos is! List) {
      throw const ViajesException(
        codigo: 'RESPUESTA_INVALIDA',
      );
    }

    return datos
        .whereType<Map<String, dynamic>>()
        .map(Viaje.desdeJson)
        .toList();
  }

  String? detalle;

  if (datos is Map<String, dynamic>) {
    detalle =
        datos['message']?.toString() ??
        datos['error']?.toString();
  }

  if (respuesta.statusCode == 401) {
    throw ViajesException(
      codigo: 'UNAUTHORIZED',
      detalle: detalle,
    );
  }

  if (respuesta.statusCode >= 500) {
    throw ViajesException(
      codigo: 'SERVER_ERROR',
      detalle: detalle,
    );
  }

  throw ViajesException(
    codigo: 'UNKNOWN_ERROR',
    detalle: detalle,
  );
}


Future<void> cambiarEstadoViaje({
  required String viajeId,
  required String estado,
  required String idToken,
}) async {
  final uri = Uri.parse(
    '${ApiConfig.backendUrl}/api/viajes/$viajeId/estado',
  );

  final http.Response respuesta;

  try {
    respuesta = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'estado': estado,
      }),
    );
  } catch (_) {
    throw const ViajesException(
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
      // Si la respuesta no trae JSON, se procesa por status code.
    }
  }

  if (respuesta.statusCode == 200 ||
      respuesta.statusCode == 204) {
    return;
  }

  final detalle =
      datos?['message']?.toString() ??
      datos?['error']?.toString();

  if (respuesta.statusCode == 400) {
    throw ViajesException(
      codigo: 'BAD_REQUEST',
      detalle: detalle,
    );
  }

  if (respuesta.statusCode == 401) {
    throw ViajesException(
      codigo: 'UNAUTHORIZED',
      detalle: detalle,
    );
  }

  if (respuesta.statusCode == 403) {
    throw ViajesException(
      codigo: 'FORBIDDEN',
      detalle: detalle,
    );
  }

  if (respuesta.statusCode == 404) {
    throw ViajesException(
      codigo: 'NOT_FOUND',
      detalle: detalle,
    );
  }

  if (respuesta.statusCode >= 500) {
    throw ViajesException(
      codigo: 'SERVER_ERROR',
      detalle: detalle,
    );
  }

  throw ViajesException(
    codigo: 'UNKNOWN_ERROR',
    detalle: detalle,
  );
}





  /// HU-15: consulta viajes disponibles por ruta, sin token (API pública).
  Future<List<ViajeDisponible>> buscarViajesDisponibles({
    required String ciudadOrigen,
    required String ciudadDestino,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.backendUrl}/api/viajes/disponibles',
    ).replace(queryParameters: {
      'ciudadOrigen': ciudadOrigen,
      'ciudadDestino': ciudadDestino,
    });

    final http.Response respuesta;
    try {
      respuesta = await http.get(uri, headers: {'Accept': 'application/json'});
    } catch (_) {
      throw const ViajesException(codigo: 'NETWORK_ERROR');
    }

    dynamic datos;
    try {
      datos = jsonDecode(respuesta.body);
    } catch (_) {
      throw const ViajesException(codigo: 'RESPUESTA_INVALIDA');
    }

    if (respuesta.statusCode == 200) {
      if (datos is! List) {
        throw const ViajesException(codigo: 'RESPUESTA_INVALIDA');
      }
      try {
        return datos.map((elemento) {
          if (elemento is! Map<String, dynamic>) {
            throw const FormatException('El viaje no es un objeto JSON');
          }
          return ViajeDisponible.desdeJson(elemento);
        }).toList();
      } catch (_) {
        throw const ViajesException(codigo: 'RESPUESTA_INVALIDA');
      }
    }

    String? detalle;
    if (datos is Map<String, dynamic>) {
      detalle = datos['error']?.toString() ??
          datos['message']?.toString();
    }
    if (respuesta.statusCode == 400) {
      throw ViajesException(codigo: 'BAD_REQUEST', detalle: detalle);
    }
    if (respuesta.statusCode >= 500) {
      throw ViajesException(codigo: 'SERVER_ERROR', detalle: detalle);
    }
    throw ViajesException(codigo: 'UNKNOWN_ERROR', detalle: detalle);
  }

}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/perfil_usuario.dart';

/// Error producido al consumir los endpoints de usuarios.
class UsuariosException implements Exception {
  const UsuariosException({
    required this.codigo,
    this.detalle,
  });

  /// Causa clasificada del fallo: `NETWORK_ERROR`, `UNAUTHORIZED`, etc.
  final String codigo;

  /// Mensaje que envía el backend, cuando lo incluye en la respuesta.
  final String? detalle;

  @override
  String toString() => 'UsuariosException($codigo)';
}

/// Servicio encargado de comunicarse con los endpoints REST de usuarios.
///
/// Los tres endpoints exigen el ID Token de Firebase en la cabecera
/// `Authorization: Bearer <idToken>` y devuelven la ficha del usuario, por lo
/// que comparten el armado de cabeceras y la lectura de la respuesta.
class UsuariosService {
  /// Guarda el perfil del usuario autenticado.
  ///
  /// Corresponde a `POST /api/users/register`, que responde 201 con la ficha
  /// recién guardada.
  Future<PerfilUsuario> registrarPerfil({
    required PerfilUsuario perfil,
    required String idToken,
  }) async {
    final respuesta = await _enviar(
      () => http.post(
        Uri.parse('${ApiConfig.backendUrl}/api/users/register'),
        headers: _cabeceras(idToken),
        body: jsonEncode(perfil.toJsonRegistro()),
      ),
    );

    return _leerPerfil(
      respuesta,
      codigosDeExito: const [200, 201],
    );
  }

  /// Consulta el perfil de un usuario.
  ///
  /// Corresponde a `GET /api/users/{uid}`. El backend solo deja consultar el
  /// perfil propio: con el uid de otra persona responde 403.
  Future<PerfilUsuario> obtenerPerfil({
    required String uid,
    required String idToken,
  }) async {
    final respuesta = await _enviar(
      () => http.get(
        Uri.parse('${ApiConfig.backendUrl}/api/users/$uid'),
        headers: _cabeceras(idToken),
      ),
    );

    return _leerPerfil(
      respuesta,
      codigosDeExito: const [200],
    );
  }

  /// Actualiza los datos personales del perfil propio.
  ///
  /// Corresponde a `PUT /api/users/{uid}`. El cuerpo se arma sin el uid ni el
  /// correo, que el backend no permite modificar.
  Future<PerfilUsuario> actualizarPerfil({
    required PerfilUsuario perfil,
    required String idToken,
  }) async {
    final respuesta = await _enviar(
      () => http.put(
        Uri.parse('${ApiConfig.backendUrl}/api/users/${perfil.uid}'),
        headers: _cabeceras(idToken),
        body: jsonEncode(perfil.toJsonActualizacion()),
      ),
    );

    return _leerPerfil(
      respuesta,
      codigosDeExito: const [200],
    );
  }

  /// Cabeceras comunes a los tres endpoints, con el token de la sesión.
  Map<String, String> _cabeceras(String idToken) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Ejecuta la petición y traduce cualquier fallo de red a una excepción
  /// propia, para que las capas superiores no dependan del paquete `http`.
  Future<http.Response> _enviar(
    Future<http.Response> Function() peticion,
  ) async {
    try {
      return await peticion();
    } catch (_) {
      throw const UsuariosException(codigo: 'NETWORK_ERROR');
    }
  }

  /// Convierte la respuesta en un perfil, o lanza la excepción que
  /// corresponda al código HTTP recibido.
  PerfilUsuario _leerPerfil(
    http.Response respuesta, {
    required List<int> codigosDeExito,
  }) {
    final datos = _decodificar(respuesta.body);

    if (codigosDeExito.contains(respuesta.statusCode)) {
      if (datos == null) {
        throw const UsuariosException(codigo: 'RESPUESTA_INVALIDA');
      }

      // El registro y la consulta envuelven la ficha en "user", mientras que
      // la actualización la devuelve directamente. Se admiten los dos casos.
      final usuarioJson = datos['user'];

      if (usuarioJson is Map<String, dynamic>) {
        return PerfilUsuario.desdeJson(usuarioJson);
      }

      return PerfilUsuario.desdeJson(datos);
    }

    throw _errorDeRespuesta(respuesta.statusCode, datos);
  }

  /// Interpreta el cuerpo de la respuesta como JSON.
  ///
  /// Devuelve nulo cuando viene vacío o no es un objeto, de modo que el código
  /// HTTP se pueda procesar igualmente.
  Map<String, dynamic>? _decodificar(String cuerpo) {
    if (cuerpo.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(cuerpo);

      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }

  /// Clasifica el código HTTP de una respuesta fallida.
  UsuariosException _errorDeRespuesta(
    int codigoHttp,
    Map<String, dynamic>? datos,
  ) {
    final detalle =
        datos?['message']?.toString() ?? datos?['error']?.toString();

    switch (codigoHttp) {
      case 400:
        return UsuariosException(
          codigo: 'BAD_REQUEST',
          detalle: detalle,
        );
      case 401:
        return UsuariosException(
          codigo: 'UNAUTHORIZED',
          detalle: detalle,
        );
      case 403:
        return UsuariosException(
          codigo: 'FORBIDDEN',
          detalle: detalle,
        );
      case 404:
        return UsuariosException(
          codigo: 'NOT_FOUND',
          detalle: detalle,
        );
    }

    if (codigoHttp >= 500) {
      return UsuariosException(
        codigo: 'SERVER_ERROR',
        detalle: detalle,
      );
    }

    return UsuariosException(
      codigo: 'UNKNOWN_ERROR',
      detalle: detalle,
    );
  }
}

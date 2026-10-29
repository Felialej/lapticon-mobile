import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario.dart';

/// Error devuelto por la API de autenticación de Firebase.
///
/// Transporta únicamente el código original (`EMAIL_EXISTS`,
/// `INVALID_LOGIN_CREDENTIALS`, `NETWORK_ERROR`...). Traducirlo a un mensaje
/// en español es responsabilidad del controlador, no del servicio, para que el
/// texto que ve el usuario no quede atado a la capa de red.
class AuthException implements Exception {
  const AuthException(this.codigo);

  /// Código tal como lo reporta Firebase o como lo clasifica el servicio
  /// cuando la falla ocurre antes de recibir respuesta.
  final String codigo;

  @override
  String toString() => 'AuthException($codigo)';
}

/// Acceso a los endpoints REST de Firebase Identity Toolkit.
///
/// Construye las peticiones y traduce las respuestas a modelos. No guarda
/// estado ni conoce las pantallas que lo utilizan, así que puede reemplazarse
/// por otro proveedor de autenticación sin tocar el resto de la aplicación.
class AuthService {
  /// Crea una cuenta nueva con correo y contraseña.
  Future<Usuario> registrar({
    required String email,
    required String password,
  }) {
    return _autenticar(
      endpoint: 'accounts:signUp',
      email: email,
      password: password,
    );
  }

  /// Valida las credenciales de una cuenta existente y devuelve su token.
  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _autenticar(
      endpoint: 'accounts:signInWithPassword',
      email: email,
      password: password,
    );
  }

  /// Envía las credenciales al endpoint indicado y construye el usuario.
  ///
  /// El registro y el inicio de sesión comparten cuerpo, cabeceras y manejo de
  /// errores: solo cambia el endpoint, de modo que ambos reutilizan este
  /// método. Cada causa de falla se captura por separado para no confundir un
  /// problema de red con una respuesta mal formada.
  Future<Usuario> _autenticar({
    required String endpoint,
    required String email,
    required String password,
  }) async {
    if (ApiConfig.firebaseApiKey.isEmpty) {
      throw const AuthException('CONFIG_ERROR');
    }

    final uri = Uri.parse(
      '${ApiConfig.firebaseAuthUrl}/$endpoint'
      '?key=${ApiConfig.firebaseApiKey}',
    );

    final http.Response respuesta;

    try {
      respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );
    } catch (_) {
      throw const AuthException('NETWORK_ERROR');
    }

    final Map<String, dynamic> datos;

    try {
      datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AuthException('RESPUESTA_INVALIDA');
    }

    if (respuesta.statusCode == 200) {
      return Usuario.desdeFirebase(datos);
    }

    // Firebase describe el fallo en `error.message`, por ejemplo
    // {"error": {"message": "EMAIL_EXISTS"}}.
    final codigo = datos['error']?['message']?.toString() ?? 'UNKNOWN_ERROR';

    throw AuthException(codigo);
  }
}

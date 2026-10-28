import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/firebase_config.dart';

class RegistroFirebaseResultado {
  final String uid;
  final String email;
  final String idToken;

  RegistroFirebaseResultado({
    required this.uid,
    required this.email,
    required this.idToken,
  });
}

class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

class FirebaseAuthService {
  Future<RegistroFirebaseResultado> registrarUsuario({
    required String email,
    required String password,
  }) async {
    if (FirebaseConfig.apiKey.isEmpty) {
      throw FirebaseAuthException(
        code: 'CONFIG_ERROR',
        message: 'No se configuró la API Key de Firebase.',
      );
    }

    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp'
      '?key=${FirebaseConfig.apiKey}',
    );

    try {
      final response = await http.post(
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

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return RegistroFirebaseResultado(
          uid: data['localId']?.toString() ?? '',
          email: data['email']?.toString() ?? email,
          idToken: data['idToken']?.toString() ?? '',
        );
      }

      final firebaseError =
          data['error']?['message']?.toString() ??
              'UNKNOWN_ERROR';

      throw FirebaseAuthException(
        code: firebaseError,
        message: _mensajeError(firebaseError),
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      throw FirebaseAuthException(
        code: 'NETWORK_ERROR',
        message:
            'No fue posible conectar con Firebase. Revisa tu conexión a Internet.',
      );
    }
  }

  String _mensajeError(String error) {
    if (error == 'EMAIL_EXISTS') {
      return 'Ya existe una cuenta registrada con este correo.';
    }

    if (error == 'INVALID_EMAIL') {
      return 'El correo electrónico no es válido.';
    }

    if (error.startsWith('WEAK_PASSWORD')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    if (error == 'OPERATION_NOT_ALLOWED') {
      return 'El registro con correo y contraseña no está habilitado.';
    }

    if (error == 'TOO_MANY_ATTEMPTS_TRY_LATER') {
      return 'Se realizaron demasiados intentos. Intenta nuevamente más tarde.';
    }

    return 'No fue posible crear la cuenta. Intenta nuevamente.';
  }
}
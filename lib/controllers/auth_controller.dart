import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

/// Controlador de la autenticación y de la sesión activa.
///
/// Guarda el usuario autenticado, expone el estado que las pantallas de login y
/// registro necesitan dibujar, y concentra las reglas de validación de los
/// formularios. No importa `material.dart` porque no construye interfaz: solo
/// avisa de sus cambios con `notifyListeners` para que las vistas se redibujen.
class AuthController extends ChangeNotifier {
  /// El servicio se recibe por parámetro para poder sustituirlo en pruebas.
  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  /// Usuario de la sesión activa, o nulo si nadie ha iniciado sesión.
  Usuario? get usuario => _usuario;

  /// Indica si hay una operación de autenticación en curso.
  ///
  /// Las vistas lo usan para mostrar el indicador de carga y deshabilitar los
  /// botones mientras se espera la respuesta.
  bool get cargando => _cargando;

  /// Mensaje del último error ocurrido, listo para mostrarse al usuario.
  String? get error => _error;

  /// Indica si existe una sesión abierta.
  ///
  /// La raíz de la aplicación lo consulta para decidir si muestra el login o la
  /// navegación principal.
  bool get haySesion => _usuario != null;

  /// Crea una cuenta nueva y la deja como sesión activa.
  ///
  /// Devuelve `true` cuando el registro se completa; si falla, el detalle queda
  /// disponible en [error].
  Future<bool> registrar({
    required String email,
    required String password,
  }) {
    return _ejecutarAutenticacion(
      () => _authService.registrar(email: email, password: password),
    );
  }

  /// Valida las credenciales y abre la sesión.
  ///
  /// Devuelve `true` cuando el inicio de sesión se completa; si falla, el
  /// detalle queda disponible en [error].
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _ejecutarAutenticacion(
      () => _authService.iniciarSesion(email: email, password: password),
    );
  }

  /// Descarta la sesión activa.
  void cerrarSesion() {
    _usuario = null;
    _error = null;
    notifyListeners();
  }

  /// Borra el último error, por ejemplo al volver a abrir un formulario.
  void limpiarError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }

  /// Ejecuta una operación de autenticación controlando carga y errores.
  ///
  /// El registro y el inicio de sesión siguen exactamente la misma secuencia
  /// (activar la carga, llamar al servicio, guardar el usuario o el error y
  /// apagar la carga), por lo que ambos la comparten.
  Future<bool> _ejecutarAutenticacion(
    Future<Usuario> Function() operacion,
  ) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await operacion();
      return true;
    } on AuthException catch (excepcion) {
      _error = _mensajeDeError(excepcion.codigo);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Traduce el código técnico de Firebase al mensaje que lee el usuario.
  String _mensajeDeError(String codigo) {
    switch (codigo) {
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'El correo o la contraseña son incorrectos.';
      case 'USER_DISABLED':
        return 'Esta cuenta fue deshabilitada.';
      case 'EMAIL_EXISTS':
        return 'Ya existe una cuenta registrada con este correo.';
      case 'INVALID_EMAIL':
        return 'El correo electrónico no es válido.';
      case 'OPERATION_NOT_ALLOWED':
        return 'El acceso con correo y contraseña no está habilitado.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Se realizaron demasiados intentos. Intenta nuevamente más tarde.';
      case 'CONFIG_ERROR':
        return 'No se configuró la API Key de Firebase.';
      case 'NETWORK_ERROR':
        return 'No fue posible conectar con Firebase. Revisa tu conexión a Internet.';
    }

    // El código de contraseña débil llega con el detalle del mínimo exigido,
    // por lo que se compara por prefijo y no por igualdad.
    if (codigo.startsWith('WEAK_PASSWORD')) {
      return 'La contraseña debe tener al menos $minimoCaracteresPassword caracteres.';
    }

    return 'No fue posible completar la operación. Intenta nuevamente.';
  }

  /// Longitud mínima de contraseña que exige Firebase.
  static const int minimoCaracteresPassword = 6;

  /// Expresión que comprueba que el correo tenga un texto, una arroba, un
  /// dominio y una extensión, sin espacios.
  static final RegExp _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Valida el campo de correo de un formulario.
  ///
  /// Devuelve el mensaje de error, o nulo si el valor es correcto, que es el
  /// contrato que esperan los `TextFormField`.
  String? validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'El correo es obligatorio';
    }

    if (!_formatoCorreo.hasMatch(correo)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  /// Valida el campo de contraseña de un formulario.
  ///
  /// El inicio de sesión solo exige que no esté vacía, mientras que el registro
  /// debe comprobar el mínimo de caracteres, de ahí el parámetro
  /// [exigirLongitudMinima].
  String? validarPassword(
    String? valor, {
    bool exigirLongitudMinima = false,
  }) {
    final password = valor ?? '';

    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (exigirLongitudMinima &&
        password.length < minimoCaracteresPassword) {
      return 'La contraseña debe tener al menos '
          '$minimoCaracteresPassword caracteres';
    }

    return null;
  }
}

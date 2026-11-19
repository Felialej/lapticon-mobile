import 'package:flutter/foundation.dart';

import '../models/perfil_usuario.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuarios_service.dart';
import 'perfil_controller.dart';

/// Controlador de la autenticación y de la sesión activa.
///
/// Guarda el usuario autenticado, expone el estado que las pantallas de login y
/// registro necesitan dibujar, y concentra las reglas de validación de los
/// formularios. No importa `material.dart` porque no construye interfaz: solo
/// avisa de sus cambios con `notifyListeners` para que las vistas se redibujen.
class AuthController extends ChangeNotifier {
  /// Los servicios se reciben por parámetro para poder sustituirlos en pruebas.
  AuthController({
    AuthService? authService,
    UsuariosService? usuariosService,
  }) : _authService = authService ?? AuthService(),
       _usuariosService = usuariosService ?? UsuariosService();

  final AuthService _authService;
  final UsuariosService _usuariosService;

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

  /// Crea una cuenta nueva junto con su perfil y la deja como sesión activa.
  ///
  /// El registro ocurre en dos pasos encadenados: primero Firebase crea la
  /// cuenta y devuelve el token, y con ese token el backend guarda los datos
  /// personales. La sesión solo se abre cuando los dos pasos funcionan, para
  /// que nadie entre a la aplicación sin perfil guardado.
  ///
  /// Devuelve `true` cuando el registro se completa; si falla, el detalle
  /// queda disponible en [error].
  Future<bool> registrarConPerfil({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required DateTime fechaNacimiento,
    required String nacionalidad,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _authService.registrar(
        email: email,
        password: password,
      );

      // El correo se guarda en los dos campos que maneja el backend, y el uid
      // es el que acaba de asignar Firebase.
      final perfil = PerfilUsuario(
        uid: usuario.uid,
        email: usuario.email,
        correo: usuario.email,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        telefono: telefono.trim(),
        nacionalidad: nacionalidad,
        fechaNacimiento: fechaNacimiento,
      );

      await _usuariosService.registrarPerfil(
        perfil: perfil,
        idToken: usuario.idToken,
      );

      _usuario = usuario;
      return true;
    } on AuthException catch (excepcion) {
      _error = _mensajeDeError(excepcion.codigo);
      return false;
    } on UsuariosException catch (excepcion) {
      // La cuenta de Firebase ya quedó creada, pero sus datos no se
      // guardaron, así que se avisa para que el usuario pueda reintentar.
      _error =
          '${PerfilController.mensajeDeError(excepcion)} '
          'Tu cuenta fue creada: inicia sesión para completar tus datos.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Valida las credenciales y abre la sesión.
  ///
  /// Devuelve `true` cuando el inicio de sesión se completa; si falla, el
  /// detalle queda disponible en [error].
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.iniciarSesion(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (excepcion) {
      _error = _mensajeDeError(excepcion.codigo);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
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

    if (exigirLongitudMinima && password.length < minimoCaracteresPassword) {
      return 'La contraseña debe tener al menos '
          '$minimoCaracteresPassword caracteres';
    }

    return null;
  }
}

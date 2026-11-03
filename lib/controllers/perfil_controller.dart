import 'package:flutter/foundation.dart';

import '../models/perfil_usuario.dart';
import '../services/usuarios_service.dart';

/// Controlador del perfil del usuario.
///
/// Guarda la ficha consultada al backend y el estado que la pestaña de perfil
/// necesita dibujar: si está cargando, si está guardando y cuál fue el último
/// error.
class PerfilController extends ChangeNotifier {
  /// El servicio se recibe por parámetro para poder sustituirlo en pruebas.
  PerfilController({UsuariosService? usuariosService})
    : _usuariosService = usuariosService ?? UsuariosService();

  final UsuariosService _usuariosService;

  PerfilUsuario? _perfil;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  /// Perfil consultado, o nulo mientras no se ha cargado.
  PerfilUsuario? get perfil => _perfil;

  /// Indica si la consulta del perfil está en curso.
  bool get cargando => _cargando;

  /// Indica si hay una actualización en curso.
  bool get guardando => _guardando;

  /// Mensaje del último error, listo para mostrarse al usuario.
  String? get error => _error;

  /// Indica si ya hay datos que mostrar.
  bool get tienePerfil => _perfil != null;

  /// Consulta el perfil del usuario autenticado.
  Future<void> cargarPerfil({
    required String uid,
    required String idToken,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _perfil = await _usuariosService.obtenerPerfil(
        uid: uid,
        idToken: idToken,
      );
    } on UsuariosException catch (excepcion) {
      _error = mensajeDeError(excepcion);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Envía los datos modificados y deja el perfil devuelto por el backend.
  ///
  /// Devuelve `true` cuando la actualización se completa; si falla, el detalle
  /// queda disponible en [error].
  Future<bool> actualizarPerfil({
    required PerfilUsuario perfil,
    required String idToken,
  }) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      _perfil = await _usuariosService.actualizarPerfil(
        perfil: perfil,
        idToken: idToken,
      );
      return true;
    } on UsuariosException catch (excepcion) {
      _error = mensajeDeError(excepcion);
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  /// Traduce el error del servicio al mensaje que lee el usuario.
  ///
  /// Es público porque el registro de la cuenta reutiliza esta traducción al
  /// guardar el perfil por primera vez.
  static String mensajeDeError(UsuariosException excepcion) {
    switch (excepcion.codigo) {
      case 'NETWORK_ERROR':
        return 'No fue posible conectar con el servidor. Revisa tu conexión a Internet.';
      case 'UNAUTHORIZED':
        return 'Tu sesión expiró. Vuelve a iniciar sesión.';
      case 'FORBIDDEN':
        return 'Solo puedes consultar y modificar tu propio perfil.';
      case 'NOT_FOUND':
        return 'Todavía no hay datos guardados para esta cuenta.';
      case 'BAD_REQUEST':
        return excepcion.detalle ?? 'Revisa los datos enviados.';
      case 'SERVER_ERROR':
        return 'El servidor no está disponible en este momento.';
    }

    return 'No fue posible completar la operación. Intenta nuevamente.';
  }
}

import '../utils/formato_fecha.dart';

/// Datos personales del usuario guardados en el backend de Lapticon.
///
/// Se diferencia de `Usuario`, que solo representa la sesión de Firebase
/// (uid, correo y token). Este modelo es la ficha completa que viaja hacia y
/// desde los endpoints `/api/users`.
class PerfilUsuario {
  const PerfilUsuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.nacionalidad,
    required this.correo,
    this.fechaNacimiento,
  });

  /// Reconstruye el perfil a partir de la respuesta del backend.
  ///
  /// Si el campo `correo` no viene, se toma el valor de `email`, porque ambos
  /// guardan el mismo dato.
  factory PerfilUsuario.desdeJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    final fechaTexto = json['fechaNacimiento']?.toString() ?? '';

    return PerfilUsuario(
      uid: json['uid']?.toString() ?? '',
      email: email,
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      nacionalidad: json['nacionalidad']?.toString() ?? '',
      correo: json['correo']?.toString() ?? email,
      fechaNacimiento: DateTime.tryParse(fechaTexto),
    );
  }

  /// Identificador de la cuenta. Lo asigna Firebase y no se puede modificar.
  final String uid;

  /// Correo de la cuenta, tal como lo guarda el campo `email` del backend.
  final String email;

  final String nombre;
  final String apellido;
  final String telefono;
  final String nacionalidad;

  /// Mismo correo que [email], guardado además en el campo `correo` que
  /// también expone el backend.
  final String correo;

  /// Fecha de nacimiento, o nulo si el perfil todavía no la tiene registrada.
  final DateTime? fechaNacimiento;

  /// Nombre y apellido juntos, para mostrarlos como un solo título.
  String get nombreCompleto => '$nombre $apellido'.trim();

  /// Arma el cuerpo de `POST /api/users/register`.
  ///
  /// Solo se envía `correo`: el uid y el campo `email` los completa el backend
  /// a partir del token, de modo que los dos campos de correo terminan con el
  /// mismo valor que se usó para crear la cuenta.
  Map<String, dynamic> toJsonRegistro() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'nacionalidad': nacionalidad,
      'correo': correo,
      if (fechaNacimiento != null)
        'fechaNacimiento': formatearFechaApi(fechaNacimiento!),
    };
  }

  /// Arma el cuerpo de `PUT /api/users/{uid}`.
  ///
  /// Deja fuera el uid y el correo a propósito: el backend responde 400 si se
  /// intenta modificar alguno de los dos.
  Map<String, dynamic> toJsonActualizacion() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'nacionalidad': nacionalidad,
      if (fechaNacimiento != null)
        'fechaNacimiento': formatearFechaApi(fechaNacimiento!),
    };
  }
}

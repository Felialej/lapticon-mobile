/// Usuario autenticado durante la sesión actual.
///
/// El `idToken` es la credencial que el backend de Lapticon espera en la
/// cabecera `Authorization: Bearer <idToken>` de sus endpoints protegidos.
class Usuario {
  const Usuario({
    required this.uid,
    required this.email,
    required this.idToken,
  });

  /// Reconstruye el usuario a partir de la respuesta de Firebase Identity
  /// Toolkit, donde el identificador de la cuenta llega en el campo `localId`.
  factory Usuario.desdeFirebase(Map<String, dynamic> json) {
    return Usuario(
      uid: json['localId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      idToken: json['idToken']?.toString() ?? '',
    );
  }

  /// Identificador único que Firebase asigna a la cuenta.
  ///
  /// El backend lo usa como dueño de los viajes, las encomiendas y el perfil.
  final String uid;

  /// Correo con el que la cuenta se registró o inició sesión.
  final String email;

  /// Token de acceso firmado por Firebase, válido por una hora.
  final String idToken;
}

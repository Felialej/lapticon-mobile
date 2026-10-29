/// Configuración de los servicios remotos que consume la aplicación.
///
/// Centraliza las URL y las claves en un único archivo para que ningún servicio
/// las declare por su cuenta y un cambio de ambiente se haga en un solo lugar.
class ApiConfig {
  /// Constructor privado: la clase solo agrupa constantes y no se instancia.
  const ApiConfig._();

  /// Clave pública del proyecto de Firebase.
  ///
  /// Identity Toolkit la exige como parámetro `key` en cada petición. Es una
  /// clave de cliente y no un secreto, pero debe restringirse por aplicación
  /// desde la consola de Google Cloud.
  static const String firebaseApiKey =
      'AIzaSyAuh64b_I2OtC7KYuubCVx9plEe2pojp2M';

  /// Raíz de la API REST de autenticación de Firebase.
  static const String firebaseAuthUrl =
      'https://identitytoolkit.googleapis.com/v1';

  /// Raíz del backend de Lapticon, que expone usuarios, viajes, encomiendas,
  /// calificaciones, chats y el catálogo de ciudades.
  static const String backendUrl =
      'https://lapticon-backend.onrender.com';
}

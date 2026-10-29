import 'package:flutter/foundation.dart';

import '../models/viaje.dart';

/// Controlador del formulario de registro de viaje.
///
/// Conserva la selección del usuario (origen, destino y fecha), valida cada
/// campo y construye el [Viaje] resultante. Las acciones que necesitan el
/// contexto de la interfaz, como abrir el calendario o mostrar un aviso, se
/// quedan en la vista.
class RegistrarViajeController extends ChangeNotifier {
  /// Ciudades que ofrecen los selectores de origen y destino.
  ///
  /// Es una lista fija provisional. El catálogo completo lo expone el backend
  /// en `GET /api/ciudades/ciudades`, que ya está implementado en
  /// `CiudadesService` y pendiente de conectar aquí.
  static const List<String> ciudadesDisponibles = [
    'Bogota',
    'Medellin',
    'Cali',
    'Madrid',
    'Paris',
    'Miami',
  ];

  String? _origen;
  String? _destino;
  DateTime? _fecha;

  /// Ciudad de origen seleccionada, o nulo si aún no se elige ninguna.
  String? get origen => _origen;

  /// Ciudad de destino seleccionada, o nulo si aún no se elige ninguna.
  String? get destino => _destino;

  /// Fecha del vuelo seleccionada, o nulo si aún no se elige ninguna.
  DateTime? get fecha => _fecha;

  /// Primer día que el calendario permite elegir: no se registran vuelos en
  /// fechas pasadas.
  DateTime get fechaMinima => DateTime.now();

  /// Último día que el calendario permite elegir.
  DateTime get fechaMaxima => DateTime(DateTime.now().year + 2);

  /// Registra la ciudad de origen elegida.
  void seleccionarOrigen(String? ciudad) {
    _origen = ciudad;
    notifyListeners();
  }

  /// Registra la ciudad de destino elegida.
  void seleccionarDestino(String? ciudad) {
    _destino = ciudad;
    notifyListeners();
  }

  /// Registra la fecha elegida en el calendario.
  void seleccionarFecha(DateTime fechaElegida) {
    _fecha = fechaElegida;
    notifyListeners();
  }

  /// Valida el campo del número de vuelo.
  String? validarNumeroVuelo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el número de vuelo';
    }

    return null;
  }

  /// Valida que se haya elegido una ciudad en un selector.
  String? validarCiudad(String? valor) {
    if (valor == null) {
      return 'Selecciona una ciudad';
    }

    return null;
  }

  /// Comprueba las reglas que los validadores de campo no alcanzan a cubrir.
  ///
  /// Devuelve el mensaje del primer problema encontrado, o nulo si el
  /// formulario puede enviarse. La fecha se revisa aquí porque se elige en un
  /// calendario y no en un campo del formulario, y la comparación entre origen
  /// y destino porque involucra dos campos a la vez.
  String? validarSeleccion() {
    if (_fecha == null) {
      return 'Selecciona la fecha del viaje';
    }

    if (_origen == _destino) {
      return 'Origen y destino deben ser diferentes';
    }

    return null;
  }

  /// Construye el viaje con los datos del formulario.
  ///
  /// Solo debe llamarse después de que [validarSeleccion] devuelva nulo, porque
  /// asume que la ciudad de origen, la de destino y la fecha ya están elegidas.
  /// El número de vuelo se normaliza a mayúsculas, que es el formato con el que
  /// se identifican los vuelos.
  Viaje construirViaje(String numeroVuelo) {
    return Viaje(
      numeroVuelo: numeroVuelo.trim().toUpperCase(),
      ciudadOrigen: _origen!,
      ciudadDestino: _destino!,
      fechaViaje: _fecha!,
    );
  }
}

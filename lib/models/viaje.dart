import '../utils/formato_fecha.dart';

/// Viaje que un usuario registra para transportar encomiendas en su vuelo.
class Viaje {
  const Viaje({
    required this.numeroVuelo,
    required this.ciudadOrigen,
    required this.ciudadDestino,
    required this.fechaViaje,
    this.id,
    this.estado = estadoDisponible,
  });

  /// Reconstruye un viaje a partir de la respuesta de `GET /api/viajes`.
  ///
  /// La fecha puede llegar como fecha simple o con hora, por lo que se usa
  /// `tryParse` y se conserva la fecha actual cuando el valor no es válido.
  factory Viaje.desdeJson(Map<String, dynamic> json) {
    final fechaTexto = json['fechaViaje']?.toString() ?? '';

    return Viaje(
      id: json['_id']?.toString(),
      numeroVuelo: json['numeroVuelo']?.toString() ?? '',
      ciudadOrigen: json['ciudadOrigen']?.toString() ?? '',
      ciudadDestino: json['ciudadDestino']?.toString() ?? '',
      fechaViaje: DateTime.tryParse(fechaTexto) ?? DateTime.now(),
      estado: json['estado']?.toString() ?? estadoDisponible,
    );
  }

  /// Estado con el que el backend crea todo viaje nuevo.
  ///
  /// Solo se admite un viaje en este estado por usuario: intentar crear otro
  /// mientras uno sigue disponible responde 400.
  static const String estadoDisponible = 'disponible';

  /// Identificador que asigna el backend.
  ///
  /// Es nulo mientras el viaje solo existe en memoria y aún no se ha enviado.
  final String? id;

  /// Código del vuelo en mayúsculas, por ejemplo `AA123`.
  final String numeroVuelo;

  /// Ciudad desde la que sale el vuelo.
  final String ciudadOrigen;

  /// Ciudad a la que llega el vuelo.
  final String ciudadDestino;

  /// Día del vuelo. La hora no se usa en ninguna parte del flujo.
  final DateTime fechaViaje;

  /// Situación del viaje dentro del backend.
  final String estado;

  /// Arma el cuerpo que espera `POST /api/viajes`.
  ///
  /// El estado y el identificador no se envían: los asigna el backend.
  Map<String, dynamic> toJson() {
    return {
      'numeroVuelo': numeroVuelo,
      'ciudadOrigen': ciudadOrigen,
      'ciudadDestino': ciudadDestino,
      'fechaViaje': formatearFechaApi(fechaViaje),
    };
  }
}

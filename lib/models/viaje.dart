class Viaje {
  final String numeroVuelo;
  final String ciudadOrigen;
  final String ciudadDestino;
  final DateTime fechaViaje;
  final String estado;

  Viaje({
    required this.numeroVuelo,
    required this.ciudadOrigen,
    required this.ciudadDestino,
    required this.fechaViaje,
    this.estado = 'disponible',
  });

  Map<String, dynamic> toJson() {
    return {
      'numeroVuelo': numeroVuelo,
      'ciudadOrigen': ciudadOrigen,
      'ciudadDestino': ciudadDestino,
      'fechaViaje': fechaViaje.toIso8601String().split('T').first,
    };
  }
}
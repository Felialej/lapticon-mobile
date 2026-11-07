class Encomienda {
  const Encomienda({
    required this.ciudadOrigen,
    required this.ciudadDestino,
    required this.observaciones,
    required this.moneda,
    required this.valor,
    this.id,
    this.estado = estadoDisponible,
  });

  factory Encomienda.desdeJson(Map<String, dynamic> json) {
    return Encomienda(
      id: json['_id']?.toString(),
      ciudadOrigen: json['ciudadOrigen']?.toString() ?? '',
      ciudadDestino: json['ciudadDestino']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      moneda: json['moneda']?.toString() ?? '',
      valor: double.tryParse(json['valor']?.toString() ?? '') ?? 0,
      estado: json['estado']?.toString() ?? estadoDisponible,
    );
  }

  static const String estadoDisponible = 'disponible';
  static const String estadoTomada = 'tomada';
  static const String estadoVencida = 'vencida';
  static const String estadoRecibida = 'recibida';

  final String? id;
  final String ciudadOrigen;
  final String ciudadDestino;
  final String observaciones;
  final String moneda;
  final double valor;
  final String estado;

  Map<String, dynamic> toJson() {
    return {
      'ciudadOrigen': ciudadOrigen,
      'ciudadDestino': ciudadDestino,
      'observaciones': observaciones,
      'moneda': moneda,
      'valor': valor,
    };
  }
}

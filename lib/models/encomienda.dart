enum EstadoEncomienda {
  disponible(
    valor: 'disponible',
    etiqueta: 'Disponible',
    descripcion: 'Publicada por el remitente.',
    paso: 0,
  ),
  tomada(
    valor: 'tomada',
    etiqueta: 'Tomada',
    descripcion: 'Asignada a un viajero.',
    paso: 1,
  ),
  recibida(
    valor: 'recibida',
    etiqueta: 'Recibida',
    descripcion: 'Confirmada por el viajero.',
    paso: 2,
  ),
  vencida(
    valor: 'vencida',
    etiqueta: 'Vencida',
    descripcion: 'Ningún viajero la tomó a tiempo.',
    paso: 0,
  );

  const EstadoEncomienda({
    required this.valor,
    required this.etiqueta,
    required this.descripcion,
    required this.paso,
  });

  static EstadoEncomienda desdeTexto(String texto) {
    final normalizado = texto.trim().toLowerCase();

    for (final estado in EstadoEncomienda.values) {
      if (estado.valor == normalizado) {
        return estado;
      }
    }

    return EstadoEncomienda.disponible;
  }

  final String valor;
  final String etiqueta;
  final String descripcion;
  final int paso;
}

class Encomienda {
  const Encomienda({
    required this.ciudadOrigen,
    required this.ciudadDestino,
    required this.observaciones,
    required this.moneda,
    required this.valor,
    this.id,
    this.estado = EstadoEncomienda.disponible,
  });

  factory Encomienda.desdeJson(Map<String, dynamic> json) {
    return Encomienda(
      id: json['_id']?.toString(),
      ciudadOrigen: json['ciudadOrigen']?.toString() ?? '',
      ciudadDestino: json['ciudadDestino']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      moneda: json['moneda']?.toString() ?? '',
      valor: double.tryParse(json['valor']?.toString() ?? '') ?? 0,
      estado: EstadoEncomienda.desdeTexto(
        json['estado']?.toString() ?? '',
      ),
    );
  }

  final String? id;
  final String ciudadOrigen;
  final String ciudadDestino;
  final String observaciones;
  final String moneda;
  final double valor;
  final EstadoEncomienda estado;

  String get ruta => '$ciudadOrigen → $ciudadDestino';

  String get valorConMoneda {
    final entero = valor == valor.roundToDouble();

    return '$moneda ${entero ? valor.toStringAsFixed(0) : valor.toStringAsFixed(2)}';
  }

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

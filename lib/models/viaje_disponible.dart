import 'viaje.dart';

/// Resultado del buscador público de viajes disponibles.
///
/// El backend puede omitir número de vuelo y estado en esta consulta.
/// Por eso se guardan como datos opcionales y no se inventan en la vista.
class ViajeDisponible {
  const ViajeDisponible({
    required this.viaje,
    required this.fechaInformada,
    this.nombreUsuario,
    this.numeroVuelo,
    this.estado,
  });

  factory ViajeDisponible.desdeJson(Map<String, dynamic> json) {
    String? texto(String clave) {
      final valor = json[clave]?.toString().trim();
      return valor == null || valor.isEmpty ? null : valor;
    }

    return ViajeDisponible(
      viaje: Viaje.desdeJson(json),
      fechaInformada: DateTime.tryParse(texto('fechaViaje') ?? ''),
      nombreUsuario: texto('nombreUsuario'),
      numeroVuelo: texto('numeroVuelo'),
      estado: texto('estado'),
    );
  }

  final Viaje viaje;
  final DateTime? fechaInformada;
  final String? nombreUsuario;
  final String? numeroVuelo;
  final String? estado;
}

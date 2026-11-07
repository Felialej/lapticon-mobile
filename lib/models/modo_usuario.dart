/// Forma en la que una persona usa Lapticon.
///
/// Determina qué funciones ve al entrar: quien envía encomiendas o quien viaja
/// y las transporta. Los textos viven aquí para que la pantalla de inicio solo
/// se ocupe de dibujarlos.
enum ModoUsuario {
  remitente(
    titulo: 'Remitente',
    descripcion: 'Publica encomiendas con su origen, destino y valor.',
  ),
  viajero(
    titulo: 'Viajero',
    descripcion: 'Registra vuelos y consulta tus viajes.',
  );

  const ModoUsuario({required this.titulo, required this.descripcion});

  /// Nombre del modo, tal como se muestra en la pantalla de inicio.
  final String titulo;

  /// Frase que resume lo que permite hacer el modo.
  final String descripcion;
}

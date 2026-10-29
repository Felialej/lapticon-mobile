// Conversiones de fecha compartidas por las vistas y los modelos.
//
// Se agrupan aquí para que el mismo formato se aplique en toda la aplicación
// y no se repita en cada pantalla.

/// Convierte una fecha al texto `dd/MM/yyyy` que se muestra en la interfaz.
String formatearFechaVisible(DateTime fecha) {
  return '${_dosDigitos(fecha.day)}/'
      '${_dosDigitos(fecha.month)}/'
      '${fecha.year}';
}

/// Convierte una fecha al texto `yyyy-MM-dd` que esperan los endpoints del
/// backend, que trabajan con fechas sin hora.
String formatearFechaApi(DateTime fecha) {
  return '${fecha.year}-'
      '${_dosDigitos(fecha.month)}-'
      '${_dosDigitos(fecha.day)}';
}

/// Completa un número con un cero a la izquierda cuando tiene un solo dígito.
String _dosDigitos(int valor) {
  return valor.toString().padLeft(2, '0');
}

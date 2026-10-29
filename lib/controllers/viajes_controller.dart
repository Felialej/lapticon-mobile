import 'package:flutter/foundation.dart';

import '../models/viaje.dart';

/// Controlador de los viajes registrados por el usuario.
///
/// Es la única fuente de la lista de viajes: la pestaña de inicio muestra el
/// total y la pestaña de viajes muestra el detalle, y ambas leen de aquí.
///
/// Por ahora los viajes viven solo en memoria y se pierden al cerrar sesión.
/// Cuando se conecte `POST /api/viajes` y `GET /api/viajes`, este controlador
/// será el que llame al servicio correspondiente.
class ViajesController extends ChangeNotifier {
  final List<Viaje> _viajes = [];

  /// Viajes registrados, en el orden en que se crearon.
  ///
  /// Se entrega como lista no modificable para que ninguna vista pueda
  /// agregar o quitar elementos sin pasar por el controlador.
  List<Viaje> get viajes => List.unmodifiable(_viajes);

  /// Cantidad de viajes registrados.
  int get cantidad => _viajes.length;

  /// Indica si todavía no hay viajes, para que la vista muestre el estado
  /// vacío en lugar del listado.
  bool get estaVacio => _viajes.isEmpty;

  /// Agrega un viaje a la lista y notifica a las vistas.
  void agregar(Viaje viaje) {
    _viajes.add(viaje);
    notifyListeners();
  }
}

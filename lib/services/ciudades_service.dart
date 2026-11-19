import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Acceso al catálogo público de ciudades del backend de Lapticon.
///
/// Los endpoints de este catálogo no exigen token de autenticación.
class CiudadesService {
  /// Devuelve los nombres de las ciudades admitidas para origen y destino.
  ///
  /// `GET /api/ciudades/ciudades` responde una lista plana de nombres.
  Future<List<String>> obtenerCiudades() => _obtenerNombres('ciudades');

  /// Devuelve los nombres exactos de `GET /api/ciudades/paises`.
  Future<List<String>> obtenerPaises() => _obtenerNombres('paises');

  Future<List<String>> _obtenerNombres(String catalogo) async {
    final respuesta = await http.get(
      Uri.parse('${ApiConfig.backendUrl}/api/ciudades/$catalogo'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al obtener el catálogo de $catalogo: ${respuesta.statusCode}',
      );
    }

    final lista = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List<dynamic>;

    return lista
        .whereType<String>()
        .where((ciudad) => ciudad.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }
}

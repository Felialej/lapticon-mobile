import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Acceso al catálogo público de ciudades del backend de Lapticon.
///
/// Los endpoints de este catálogo no exigen token de autenticación.
class CiudadesService {
  /// Devuelve los nombres de las ciudades admitidas para origen y destino.
  ///
  /// `GET /api/ciudades/ciudades` responde una lista plana de cadenas, por
  /// ejemplo `["Abbotsford", "Aberdeen", ...]`.
  Future<List<String>> obtenerCiudades() async {
    final respuesta = await http.get(
      Uri.parse('${ApiConfig.backendUrl}/api/ciudades/ciudades'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al obtener las ciudades: ${respuesta.statusCode}',
      );
    }

    final lista = jsonDecode(respuesta.body) as List<dynamic>;

    return lista.map((ciudad) => ciudad.toString()).toList();
  }
}

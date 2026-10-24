import 'dart:convert';

import 'package:http/http.dart' as http;

class CiudadesService {
  static const String baseUrl =
      'https://lapticon-backend.onrender.com';

  Future<dynamic> obtenerCiudades() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ciudades/ciudades'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error al obtener ciudades: ${response.statusCode}',
    );
  }
}   
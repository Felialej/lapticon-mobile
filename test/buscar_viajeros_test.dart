import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/buscar_viajeros_controller.dart';
import 'package:lapticon_mobile/services/viajes_service.dart';

void main() {
  test('Busca por ruta y lee nombreUsuario sin inventar campos', () async {
    await http.runWithClient(() async {
      final resultados = await ViajesService().buscarViajesDisponibles(
        ciudadOrigen: 'Bogota',
        ciudadDestino: 'Miami',
      );

      expect(resultados, hasLength(1));
      expect(resultados.single.viaje.ciudadOrigen, 'Bogota');
      expect(resultados.single.nombreUsuario, 'Viajero de prueba');
      expect(resultados.single.numeroVuelo, isNull);
      expect(resultados.single.estado, isNull);
      expect(resultados.single.fechaInformada, DateTime.utc(2026, 12, 1));
    }, () => MockClient((solicitud) async {
      expect(solicitud.method, 'GET');
      expect(solicitud.url.path, '/api/viajes/disponibles');
      expect(solicitud.url.queryParameters, {
        'ciudadOrigen': 'Bogota',
        'ciudadDestino': 'Miami',
      });
      expect(solicitud.headers.containsKey('Authorization'), isFalse);

      return http.Response(
        jsonEncode([
          {
            'uid': 'viajero-1',
            'ciudadOrigen': 'Bogota',
            'ciudadDestino': 'Miami',
            'fechaViaje': '2026-12-01T00:00:00.000Z',
            'nombreUsuario': 'Viajero de prueba',
          }
        ]),
        200,
      );
    }));
  });

  test('Una búsqueda sin coincidencias devuelve la lista vacía', () async {
    await http.runWithClient(() async {
      final resultados = await ViajesService().buscarViajesDisponibles(
        ciudadOrigen: 'Bogota',
        ciudadDestino: 'Cali',
      );
      expect(resultados, isEmpty);
    }, () => MockClient((_) async => http.Response('[]', 200)));
  });

  test('Un error de servidor genera una excepción identificable', () async {
    await http.runWithClient(() async {
      expect(
        () => ViajesService().buscarViajesDisponibles(
          ciudadOrigen: 'Bogota',
          ciudadDestino: 'Miami',
        ),
        throwsA(
          isA<ViajesException>().having(
            (error) => error.codigo,
            'codigo',
            'SERVER_ERROR',
          ),
        ),
      );
    }, () => MockClient(
      (_) async => http.Response('{"error":"Servidor no disponible"}', 500),
    ));
  });

  test('El controlador usa el catálogo, valida filtros y busca', () async {
    await http.runWithClient(() async {
      final controlador = BuscarViajerosController();
      addTearDown(controlador.dispose);
      await controlador.cargarCiudades();

      expect(controlador.ciudades, ['Bogota', 'Miami']);
      expect(controlador.validarOrigen(), isNotNull);
      expect(controlador.validarDestino(), isNotNull);

      controlador.seleccionarOrigen('Bogota');
      controlador.seleccionarDestino('Bogota');
      await controlador.buscar();
      expect(controlador.errorBusqueda, contains('diferentes'));

      controlador.seleccionarDestino('Miami');
      await controlador.buscar();
      expect(controlador.busquedaRealizada, isTrue);
      expect(controlador.resultados, isEmpty);
      expect(controlador.errorBusqueda, isNull);
    }, () => MockClient((solicitud) async {
      if (solicitud.url.path == '/api/ciudades/ciudades') {
        return http.Response('["Miami","Bogota","Bogota"]', 200);
      }
      if (solicitud.url.path == '/api/viajes/disponibles') {
        return http.Response('[]', 200);
      }
      throw StateError('Ruta inesperada: ${solicitud.url.path}');
    }));
  });
}

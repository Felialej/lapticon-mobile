import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/buscar_encomiendas_controller.dart';
import 'package:lapticon_mobile/models/encomienda.dart';
import 'package:lapticon_mobile/services/encomiendas_service.dart';

const encomiendaDisponible = {
  '_id': 'enc-1',
  'ciudadOrigen': 'Bogota',
  'ciudadDestino': 'Miami',
  'observaciones': 'Caja pequeña',
  'moneda': 'USD',
  'valor': 100,
  'estado': 'disponible',
};

void main() {
  test('HU-12 envía GET con filtros y token y muestra disponibles', () async {
    await http.runWithClient(
      () async {
        final service = EncomiendasService();
        final resultados = await service.buscarEncomiendasDisponibles(
          origen: 'Bogota',
          destino: 'Miami',
          idToken: 'prueba',
        );
        expect(resultados, hasLength(1));
        expect(resultados.single.id, 'enc-1');
        expect(resultados.single.estado, EstadoEncomienda.disponible);
      },
      () => MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/encomiendas/disponibles');
        expect(request.url.queryParameters, {
          'origen': 'Bogota',
          'destino': 'Miami',
        });
        expect(request.headers['Authorization'], 'Bearer prueba');
        return http.Response(
          jsonEncode({
            'encomiendas': [
              encomiendaDisponible,
              {...encomiendaDisponible, '_id': 'enc-2', 'estado': 'tomada'},
              {
                ...encomiendaDisponible,
                '_id': 'enc-3',
                'estado': 'desconocido',
              },
            ],
          }),
          200,
        );
      }),
    );
  });

  test('HU-12 interpreta lista vacía', () async {
    await http.runWithClient(() async {
      final service = EncomiendasService();
      final resultado = await service.buscarEncomiendasDisponibles(
        origen: 'Bogota',
        destino: 'Miami',
        idToken: 'prueba',
      );
      expect(resultado, isEmpty);
    }, () => MockClient((_) async => http.Response('[]', 200)));
  });

  test('HU-12 muestra el error de permisos sin inventar resultados', () async {
    await http.runWithClient(
      () async {
        final controller = BuscarEncomiendasController(idToken: 'prueba');
        addTearDown(controller.dispose);
        await controller.cargarCiudades();
        controller.seleccionarOrigen('Bogota');
        controller.seleccionarDestino('Miami');
        await controller.buscar();
        expect(controller.resultados, isEmpty);
        expect(controller.errorBusqueda, contains('sesión'));
      },
      () => MockClient((request) async {
        if (request.url.path == '/api/ciudades/ciudades') {
          return http.Response(jsonEncode(['Bogota', 'Miami']), 200);
        }
        return http.Response('Sin permisos', 403);
      }),
    );
  });

  test('HU-12 valida que origen y destino sean distintos', () async {
    await http.runWithClient(
      () async {
        final controller = BuscarEncomiendasController(idToken: 'prueba');
        addTearDown(controller.dispose);
        await controller.cargarCiudades();
        controller.seleccionarOrigen('Bogota');
        controller.seleccionarDestino('Bogota');
        await controller.buscar();
        expect(controller.errorBusqueda, contains('diferentes'));
      },
      () => MockClient((request) async {
        expect(request.url.path, '/api/ciudades/ciudades');
        return http.Response(jsonEncode(['Bogota', 'Miami']), 200);
      }),
    );
  });
}

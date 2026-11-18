import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/encomiendas_tomadas_controller.dart';
import 'package:lapticon_mobile/models/encomienda.dart';
import 'package:lapticon_mobile/services/encomiendas_service.dart';
import 'package:lapticon_mobile/views/encomiendas_tomadas_view.dart';

const _tomada = {
  '_id': 'enc-14',
  'ciudadOrigen': 'Bogota',
  'ciudadDestino': 'Miami',
  'valor': 120,
  'moneda': 'USD',
  'observaciones': 'Caja',
  'estado': 'tomada',
};

http.Response _resultados() => http.Response(
  jsonEncode({
    'tomadas': [_tomada],
  }),
  200,
  headers: {'content-type': 'application/json'},
);

Future<EncomiendasTomadasController> _cargarController() async {
  final controlador = EncomiendasTomadasController(idToken: 'token-prueba');
  addTearDown(controlador.dispose);
  await controlador.cargarCiudades();
  controlador.seleccionarOrigen('Bogota');
  controlador.seleccionarDestino('Miami');
  await controlador.buscar();
  expect(controlador.resultados, hasLength(1));
  return controlador;
}

void main() {
  test('HU-14 envía PUT con token Firebase y estado recibida', () async {
    var cambios = 0;
    await http.runWithClient(
      () async {
        final controlador = await _cargarController();
        final original = controlador.resultados.single;
        expect(original.estado, EstadoEncomienda.tomada);
        expect(await controlador.confirmarEntrega(original), isTrue);
        expect(controlador.resultados.single.estado, EstadoEncomienda.recibida);
        expect(controlador.confirmandoEntrega, isFalse);
        expect(cambios, 1);
        expect(
          await controlador.confirmarEntrega(controlador.resultados.single),
          isFalse,
        );
        expect(cambios, 1);
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return http.Response('["Bogota","Miami"]', 200);
        }
        if (solicitud.url.path == '/api/encomiendas/buscar') {
          return _resultados();
        }
        expect(solicitud.method, 'PUT');
        expect(solicitud.url.path, '/api/encomiendas/enc-14/estado');
        expect(solicitud.headers['Authorization'], 'Bearer token-prueba');
        final tipoContenido = solicitud.headers.entries
            .firstWhere((header) => header.key.toLowerCase() == 'content-type')
            .value;
        expect(tipoContenido, contains('application/json'));
        expect(jsonDecode(solicitud.body), {'estado': 'recibida'});
        cambios++;
        return http.Response(jsonEncode({'estado': 'recibida'}), 200);
      }),
    );
  });

  test('HU-14 acepta 204 sin cuerpo como confirmación', () async {
    await http.runWithClient(() async {
      final servicio = EncomiendasService();
      await servicio.confirmarEntrega(id: 'enc-14', idToken: 'token');
    }, () => MockClient((_) async => http.Response('', 204)));
  });

  for (final caso in {
    400: 'solicitud',
    403: 'permiso',
    404: 'existe',
    409: 'estado tomada',
    500: 'servidor',
  }.entries) {
    test('HU-14 no cambia estado si el backend responde ${caso.key}', () async {
      await http.runWithClient(
        () async {
          final controlador = await _cargarController();
          expect(
            await controlador.confirmarEntrega(controlador.resultados.single),
            isFalse,
          );
          expect(controlador.resultados.single.estado, EstadoEncomienda.tomada);
          expect(controlador.errorEntrega?.toLowerCase(), contains(caso.value));
        },
        () => MockClient((solicitud) async {
          if (solicitud.url.path == '/api/ciudades/ciudades') {
            return http.Response('["Bogota","Miami"]', 200);
          }
          if (solicitud.url.path == '/api/encomiendas/buscar') {
            return _resultados();
          }
          return http.Response('Rechazado', caso.key);
        }),
      );
    });
  }

  test(
    'HU-14 no marca recibida si la respuesta explícita contradice',
    () async {
      await http.runWithClient(
        () async {
          final controlador = await _cargarController();
          expect(
            await controlador.confirmarEntrega(controlador.resultados.single),
            isFalse,
          );
          expect(controlador.resultados.single.estado, EstadoEncomienda.tomada);
          expect(controlador.errorEntrega, contains('no confirmó'));
        },
        () => MockClient((solicitud) async {
          if (solicitud.url.path == '/api/ciudades/ciudades') {
            return http.Response('["Bogota","Miami"]', 200);
          }
          if (solicitud.url.path == '/api/encomiendas/buscar') {
            return _resultados();
          }
          return http.Response('{"estado":"tomada"}', 200);
        }),
      );
    },
  );

  test('HU-14 conserva tomada ante un fallo de red', () async {
    await http.runWithClient(
      () async {
        final controlador = await _cargarController();
        expect(
          await controlador.confirmarEntrega(controlador.resultados.single),
          isFalse,
        );
        expect(controlador.errorEntrega, contains('conectar'));
        expect(controlador.resultados.single.estado, EstadoEncomienda.tomada);
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return http.Response('["Bogota","Miami"]', 200);
        }
        if (solicitud.url.path == '/api/encomiendas/buscar') {
          return _resultados();
        }
        throw http.ClientException('Sin conexión');
      }),
    );
  });

  test('HU-14 impide confirmar dos veces mientras espera respuesta', () async {
    final pendiente = Completer<http.Response>();
    var cambios = 0;
    await http.runWithClient(
      () async {
        final controlador = await _cargarController();
        final original = controlador.resultados.single;
        final primera = controlador.confirmarEntrega(original);
        expect(controlador.confirmandoEntrega, isTrue);
        expect(await controlador.confirmarEntrega(original), isFalse);
        pendiente.complete(http.Response('', 204));
        expect(await primera, isTrue);
        expect(cambios, 1);
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return http.Response('["Bogota","Miami"]', 200);
        }
        if (solicitud.url.path == '/api/encomiendas/buscar') {
          return _resultados();
        }
        cambios++;
        return pendiente.future;
      }),
    );
  });

  testWidgets('HU-14 pide confirmación y cancelar no llama al backend', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var entregas = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: EncomiendasTomadasView(idToken: 'token-prueba'),
          ),
        );
        await tester.pumpAndSettle();
        final origen = find.byType(TextFormField).at(0);
        await tester.enterText(origen, 'Bog');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bogota').last);
        await tester.pumpAndSettle();
        final destino = find.byType(TextFormField).at(1);
        await tester.enterText(destino, 'Mia');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Miami').last);
        await tester.pumpAndSettle();
        final buscar = find.text('Buscar encomiendas tomadas');
        await tester.ensureVisible(buscar);
        await tester.tap(buscar);
        await tester.pumpAndSettle();

        final boton = find.text('Confirmar entrega');
        await tester.ensureVisible(boton);
        await tester.tap(boton);
        await tester.pumpAndSettle();
        expect(find.text('Sí, confirmar entrega'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(entregas, 0);
        expect(find.text('Tomada'), findsOneWidget);

        await tester.ensureVisible(boton);
        await tester.tap(boton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sí, confirmar entrega'));
        await tester.pumpAndSettle();
        expect(entregas, 1);
        expect(find.text('Recibida'), findsOneWidget);
        expect(find.text('Confirmar entrega'), findsNothing);
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return http.Response('["Bogota","Miami"]', 200);
        }
        if (solicitud.url.path == '/api/encomiendas/buscar') {
          return _resultados();
        }
        if (solicitud.url.path == '/api/encomiendas/enc-14/estado') {
          entregas++;
          return http.Response('{"estado":"recibida"}', 200);
        }
        throw StateError('Solicitud inesperada: ${solicitud.url.path}');
      }),
    );
  });
}

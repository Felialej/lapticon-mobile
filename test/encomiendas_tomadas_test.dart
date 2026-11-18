import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/encomiendas_tomadas_controller.dart';
import 'package:lapticon_mobile/main.dart';
import 'package:lapticon_mobile/models/encomienda.dart';
import 'package:lapticon_mobile/services/encomiendas_service.dart';
import 'package:lapticon_mobile/views/encomiendas_tomadas_view.dart';

const _tomada = {
  '_id': 'tomada-1',
  'ciudadOrigen': 'Bogota',
  'ciudadDestino': 'Miami',
  'valor': 150.5,
  'moneda': 'USD',
  'observaciones': 'Frágil',
  'estado': 'tomada',
};

void main() {
  test(
    'Consulta la ruta con el token y procesa exclusivamente tomadas',
    () async {
      await http.runWithClient(
        () async {
          final resultados = await _consultar();
          expect(resultados, hasLength(1));
          final encomienda = resultados.single;
          expect(encomienda.id, 'tomada-1');
          expect(encomienda.ciudadOrigen, 'Bogota');
          expect(encomienda.ciudadDestino, 'Miami');
          expect(encomienda.valor, 150.5);
          expect(encomienda.moneda, 'USD');
          expect(encomienda.observaciones, 'Frágil');
          expect(encomienda.estado, EstadoEncomienda.tomada);
        },
        () => MockClient((solicitud) async {
          expect(solicitud.method, 'GET');
          expect(solicitud.url.path, '/api/encomiendas/buscar');
          expect(solicitud.url.queryParameters, {
            'origen': 'Bogota',
            'destino': 'Miami',
          });
          expect(solicitud.headers['Authorization'], 'Bearer token-prueba');
          return _respuesta([_tomada]);
        }),
      );
    },
  );

  test('Tomadas vacío sigue vacío aunque haya disponibles', () async {
    await http.runWithClient(() async {
      expect(await _consultar(), isEmpty);
    }, () => MockClient((_) async => _respuesta([])));
  });

  for (final caso in {
    400: 'BAD_REQUEST',
    401: 'UNAUTHORIZED',
    403: 'UNAUTHORIZED',
    500: 'SERVER_ERROR',
    404: 'UNKNOWN_ERROR',
  }.entries) {
    test('Clasifica HTTP ${caso.key} incluso con respuesta sin JSON', () async {
      await http.runWithClient(() async {
        await expectLater(
          _consultar(),
          throwsA(
            isA<EncomiendasException>().having(
              (error) => error.codigo,
              'código',
              caso.value,
            ),
          ),
        );
      }, () => MockClient((_) async => http.Response('Error', caso.key)));
    });
  }

  test('Clasifica los errores de conexión', () async {
    await http.runWithClient(() async {
      await expectLater(
        _consultar(),
        throwsA(
          isA<EncomiendasException>().having(
            (error) => error.codigo,
            'código',
            'NETWORK_ERROR',
          ),
        ),
      );
    }, () => MockClient((_) async => throw http.ClientException('Sin red')));
  });

  for (final cuerpo in [
    '{}',
    '{"tomadas":null}',
    '{"tomadas":[1]}',
    'no-json',
  ]) {
    test('Rechaza una respuesta inválida $cuerpo', () async {
      await http.runWithClient(() async {
        await expectLater(
          _consultar(),
          throwsA(
            isA<EncomiendasException>().having(
              (error) => error.codigo,
              'código',
              'RESPUESTA_INVALIDA',
            ),
          ),
        );
      }, () => MockClient((_) async => http.Response(cuerpo, 200)));
    });
  }

  test(
    'Valida el catálogo y permite nuevas búsquedas sin acumular resultados',
    () async {
      var consultas = 0;
      await http.runWithClient(
        () async {
          final controller = EncomiendasTomadasController(
            idToken: 'token-prueba',
          );
          addTearDown(controller.dispose);
          await controller.cargarCiudades();
          expect(controller.ciudades, [
            'Bogota',
            'Cali',
            'Madrid',
            'Medellin',
            'Miami',
            'Paris',
          ]);
          expect(controller.validarOrigen(), isNotNull);
          expect(controller.validarDestino(), isNotNull);
          await controller.buscar();
          expect(controller.errorBusqueda, contains('Selecciona'));
          controller.seleccionarOrigen('Bogota');
          await controller.buscar();
          expect(controller.errorBusqueda, contains('Selecciona'));
          controller.seleccionarDestino('Bogota');
          await controller.buscar();
          expect(controller.errorBusqueda, contains('diferentes'));
          expect(consultas, 0);
          controller.seleccionarDestino('Ciudad inexistente');
          expect(controller.validarDestino(), isNotNull);
          controller.seleccionarDestino('Miami');
          await controller.buscar();
          expect(controller.resultados.single.id, 'tomada-1');
          expect(controller.busquedaRealizada, isTrue);
          expect(controller.buscando, isFalse);
          await controller.buscar();
          expect(controller.resultados, isEmpty);
          expect(controller.errorBusqueda, isNull);
          expect(consultas, 2);
        },
        () => MockClient((solicitud) async {
          if (solicitud.url.path == '/api/ciudades/ciudades') {
            return _ciudades();
          }
          consultas++;
          return _respuesta(consultas == 1 ? [_tomada] : []);
        }),
      );
    },
  );

  test(
    'Descarta éxitos y errores atrasados y conserva la carga más reciente',
    () async {
      final pendientes = <Completer<http.Response>>[];
      await http.runWithClient(
        () async {
          final controller = EncomiendasTomadasController(
            idToken: 'token-prueba',
          );
          addTearDown(controller.dispose);
          await controller.cargarCiudades();
          controller.seleccionarOrigen('Bogota');
          controller.seleccionarDestino('Miami');
          final primera = controller.buscar();
          await Future<void>.delayed(Duration.zero);
          controller.seleccionarDestino('Cali');
          final segunda = controller.buscar();
          await Future<void>.delayed(Duration.zero);
          pendientes[0].complete(_respuesta([_tomada]));
          await primera;
          expect(controller.resultados, isEmpty);
          expect(controller.buscando, isTrue);
          pendientes[1].complete(
            _respuesta([
              {..._tomada, '_id': 'reciente'},
            ]),
          );
          await segunda;
          expect(controller.resultados.single.id, 'reciente');

          final tercera = controller.buscar();
          await Future<void>.delayed(Duration.zero);
          final cuarta = controller.buscar();
          await Future<void>.delayed(Duration.zero);
          pendientes[3].complete(_respuesta([_tomada]));
          await cuarta;
          pendientes[2].complete(http.Response('Error', 500));
          await tercera;
          expect(controller.resultados.single.id, 'tomada-1');
          expect(controller.errorBusqueda, isNull);
          expect(controller.buscando, isFalse);
        },
        () => MockClient((solicitud) {
          if (solicitud.url.path == '/api/ciudades/ciudades') {
            return Future.value(_ciudades());
          }
          final pendiente = Completer<http.Response>();
          pendientes.add(pendiente);
          return pendiente.future;
        }),
      );
    },
  );

  test('Cerrar la vista invalida una consulta pendiente', () async {
    final pendiente = Completer<http.Response>();
    await http.runWithClient(
      () async {
        final controller = EncomiendasTomadasController(
          idToken: 'token-prueba',
        );
        await controller.cargarCiudades();
        controller.seleccionarOrigen('Bogota');
        controller.seleccionarDestino('Miami');
        final busqueda = controller.buscar();
        await Future<void>.delayed(Duration.zero);
        controller.dispose();
        pendiente.complete(_respuesta([_tomada]));
        await busqueda;
        expect(controller.resultados, isEmpty);
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return _ciudades();
        }
        return pendiente.future;
      }),
    );
  });

  test('Un error de autenticación se muestra y permite reintentar', () async {
    var consultas = 0;
    await http.runWithClient(
      () async {
        final controller = EncomiendasTomadasController(
          idToken: 'token-prueba',
        );
        addTearDown(controller.dispose);
        await controller.cargarCiudades();
        controller.seleccionarOrigen('Bogota');
        controller.seleccionarDestino('Miami');
        await controller.buscar();
        expect(controller.errorBusqueda, contains('sesión'));
        expect(controller.buscando, isFalse);
        await controller.buscar();
        expect(controller.errorBusqueda, isNull);
        expect(controller.resultados.single.id, 'tomada-1');
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return _ciudades();
        }
        return ++consultas == 1
            ? http.Response('', 401)
            : _respuesta([_tomada]);
      }),
    );
  });

  testWidgets('El viajero abre la consulta con su sesión y ve los detalles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var consultas = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(const LapticonApp());
        await tester.enterText(
          find.byType(TextFormField).first,
          'ana@ejemplo.com',
        );
        await tester.enterText(find.byType(TextFormField).last, 'clave-prueba');
        await _pulsar(
          tester,
          find.widgetWithText(FilledButton, 'Iniciar sesión'),
        );
        await _pulsar(tester, find.text('Viajero'));
        await _pulsar(tester, find.text('Continuar'));
        await _pulsar(tester, find.text('Encomiendas tomadas'));
        expect(find.byType(EncomiendasTomadasView), findsOneWidget);
        final buscar = find.text('Buscar encomiendas tomadas');
        await _pulsar(tester, buscar);
        expect(
          find.text('Selecciona una ciudad del catálogo.'),
          findsNWidgets(2),
        );
        await _elegirCiudad(tester, 0, 'Bogota');
        await _elegirCiudad(tester, 1, 'Miami');
        await _pulsar(tester, buscar);
        expect(find.text('Valor: USD 150.50'), findsOneWidget);
        expect(find.text('Bogota → Miami'), findsOneWidget);
        expect(find.text('Frágil'), findsOneWidget);
        expect(find.text('Tomada'), findsOneWidget);
        expect(find.textContaining('Disponible'), findsNothing);
        await _pulsar(tester, buscar);
        expect(find.text('Valor: USD 150.50'), findsNothing);
        expect(
          find.text('No tienes encomiendas tomadas para esta ruta.'),
          findsOneWidget,
        );
        expect(consultas, 2);
      },
      () => MockClient((solicitud) async {
        switch (solicitud.url.path) {
          case '/v1/accounts:signInWithPassword':
            return http.Response(
              '{"localId":"ana","email":"ana@ejemplo.com","idToken":"token-prueba"}',
              200,
            );
          case '/api/users/ana':
            return http.Response('{"uid":"ana","nombre":"Ana"}', 200);
          case '/api/viajes':
            return http.Response('[]', 200);
          case '/api/ciudades/ciudades':
            return _ciudades();
          case '/api/encomiendas/buscar':
            expect(solicitud.headers['Authorization'], 'Bearer token-prueba');
            return _respuesta(++consultas == 1 ? [_tomada] : []);
          default:
            throw StateError('Petición inesperada: ${solicitud.url.path}');
        }
      }),
    );
  });
}

Future<List<Encomienda>> _consultar() =>
    EncomiendasService().buscarEncomiendasTomadas(
      origen: 'Bogota',
      destino: 'Miami',
      idToken: 'token-prueba',
    );

http.Response _respuesta(List<Map<String, Object>> tomadas) => http.Response(
  jsonEncode({
    'disponibles': [
      {..._tomada, '_id': 'disponible-1', 'estado': 'disponible'},
    ],
    'tomadas': tomadas,
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _ciudades() =>
    http.Response('["Miami","Bogota","Cali","Bogota"]', 200);

Future<void> _pulsar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _elegirCiudad(
  WidgetTester tester,
  int indice,
  String ciudad,
) async {
  final campo = find.byType(TextFormField).at(indice);
  await tester.ensureVisible(campo);
  await tester.enterText(campo, ciudad);
  await tester.pumpAndSettle();
  await tester.tap(find.text(ciudad).last);
  await tester.pumpAndSettle();
}

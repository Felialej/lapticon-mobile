import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/views/buscar_encomiendas_view.dart';
import 'package:lapticon_mobile/views/buscar_viajeros_view.dart';
import 'package:lapticon_mobile/views/encomiendas_tomadas_view.dart';
import 'package:lapticon_mobile/views/registrar_encomienda_view.dart';
import 'package:lapticon_mobile/views/registrar_viaje_view.dart';
import 'package:lapticon_mobile/views/widgets/busqueda_por_ruta.dart';

void main() {
  const vistas = <String, Widget>{
    'publicar encomienda': RegistrarEncomiendaView(idToken: 'prueba'),
    'buscar viajeros': BuscarViajerosView(),
    'registrar viaje': RegistrarViajeView(idToken: 'prueba'),
    'buscar encomiendas': BuscarEncomiendasView(idToken: 'prueba'),
    'encomiendas tomadas': EncomiendasTomadasView(idToken: 'prueba'),
  };

  for (final caso in vistas.entries) {
    testWidgets('${caso.key} solo ofrece las ciudades de la API', (
      tester,
    ) async {
      const ciudades = ['Madrid', 'Paris'];
      var consultas = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MaterialApp(home: caso.value));
          await tester.pumpAndSettle();
          _comprobarCatalogo(tester, ciudades);
          await _elegirCiudad(tester, 0, 'MADRID', 'Madrid');
          await _elegirCiudad(tester, 1, 'PARÍS', 'Paris');
          expect(find.text('Madrid'), findsOneWidget);
          expect(find.text('Paris'), findsOneWidget);
          expect(consultas, 1);
        },
        () => MockClient((solicitud) async {
          consultas++;
          expect(solicitud.method, 'GET');
          expect(solicitud.url.path, '/api/ciudades/ciudades');
          return _catalogo(ciudades);
        }),
      );
    });

    testWidgets('${caso.key} reintenta sin ofrecer ciudades de respaldo', (
      tester,
    ) async {
      const ciudades = ['Cúcuta'];
      var consultas = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MaterialApp(home: caso.value));
          await tester.pumpAndSettle();
          final reintentar = find.text('Reintentar');

          expect(
            find.text('El catálogo de ciudades está vacío.'),
            findsOneWidget,
          );
          expect(find.byType(SelectorCiudad), findsNothing);
          await tester.tap(reintentar);
          await tester.pumpAndSettle();

          expect(
            find.textContaining('No fue posible cargar las ciudades'),
            findsOneWidget,
          );
          expect(find.byType(SelectorCiudad), findsNothing);
          await tester.tap(reintentar);
          await tester.pumpAndSettle();

          _comprobarCatalogo(tester, ciudades);
          await _buscarCiudad(tester, 0, 'MADRID');
          expect(find.text('Madrid'), findsNothing);
          await _buscarCiudad(tester, 1, 'PARÍS');
          expect(find.text('Paris'), findsNothing);
          expect(find.text('París'), findsNothing);
          expect(reintentar, findsNothing);
          expect(consultas, 3);
        },
        () => MockClient((solicitud) async {
          expect(solicitud.method, 'GET');
          expect(solicitud.url.path, '/api/ciudades/ciudades');
          return switch (++consultas) {
            1 => _catalogo([]),
            2 => http.Response('Servicio no disponible', 503),
            _ => _catalogo(ciudades),
          };
        }),
      );
    });
  }

  const operaciones = [
    ('publicar encomienda', 'Publicar encomienda', 'POST', '/api/encomiendas'),
    (
      'buscar viajeros',
      'Buscar viajeros disponibles',
      'GET',
      '/api/viajes/disponibles',
    ),
    ('registrar viaje', 'Registrar viaje', 'POST', '/api/viajes'),
    (
      'buscar encomiendas',
      'Buscar encomiendas',
      'GET',
      '/api/encomiendas/disponibles',
    ),
    (
      'encomiendas tomadas',
      'Buscar encomiendas tomadas',
      'GET',
      '/api/encomiendas/buscar',
    ),
  ];

  for (final (nombre, accion, metodo, ruta) in operaciones) {
    testWidgets(
      '$nombre valida la ruta y envía los nombres exactos de la API',
      (tester) async {
        final vista = vistas[nombre]!;
        final solicitudes = <http.Request>[];

        await http.runWithClient(
          () async {
            await tester.pumpWidget(MaterialApp(home: vista));
            await tester.pumpAndSettle();
            await _completarDatos(tester, vista);
            final enviar = find.widgetWithText(FilledButton, accion);

            await _pulsar(tester, enviar);
            expect(
              find.text('Selecciona una ciudad del catálogo.'),
              findsNWidgets(2),
            );
            expect(solicitudes, isEmpty);

            await _elegirCiudad(tester, 0, 'madrid', 'Madrid');
            await _elegirCiudad(tester, 1, 'MADRID', 'Madrid');
            await _pulsar(tester, enviar);
            expect(
              find.textContaining('Origen y destino deben ser diferentes'),
              findsOneWidget,
            );
            expect(solicitudes, isEmpty);

            await tester.pump(const Duration(seconds: 5));
            await tester.pumpAndSettle();
            await _elegirCiudad(tester, 1, 'PARIS', 'París');
            await _pulsar(tester, enviar);
            expect(solicitudes, hasLength(1));
            final solicitud = solicitudes.single;
            expect(solicitud.method, metodo);
            expect(solicitud.url.path, ruta);

            final datos = metodo == 'POST'
                ? jsonDecode(solicitud.body) as Map<String, dynamic>
                : solicitud.url.queryParameters;
            if (ruta.startsWith('/api/encomiendas/')) {
              expect(datos['origen'], 'Madrid');
              expect(datos['destino'], 'París');
            } else {
              expect(datos['ciudadOrigen'], 'Madrid');
              expect(datos['ciudadDestino'], 'París');
            }
          },
          () => MockClient((solicitud) async {
            if (solicitud.url.path == '/api/ciudades/ciudades') {
              return _catalogo(['Madrid', 'París']);
            }
            solicitudes.add(solicitud);
            return switch (ruta) {
              '/api/encomiendas/buscar' => http.Response('{"tomadas":[]}', 200),
              _ when metodo == 'POST' => http.Response('{}', 400),
              _ => http.Response('[]', 200),
            };
          }),
        );
      },
    );
  }

  testWidgets(
    'prioriza coincidencias exactas y prefijos y permite desplazarse',
    (tester) async {
      final ciudades = [
        'Nuevo Madrid',
        ...List.generate(15, (indice) => 'Madrid ${indice + 10}'),
        'Madrid',
      ];
      await http.runWithClient(() async {
        await tester.pumpWidget(const MaterialApp(home: BuscarViajerosView()));
        await tester.pumpAndSettle();
        await _buscarCiudad(tester, 0, 'madrid');
        final opciones = find.byType(ListView);
        expect(
          tester.getTopLeft(find.text('Madrid')).dy,
          lessThan(tester.getTopLeft(find.text('Madrid 10')).dy),
        );
        await tester.scrollUntilVisible(
          find.text('Nuevo Madrid'),
          140,
          scrollable: find.descendant(
            of: opciones,
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.text('Nuevo Madrid'));
        await tester.pumpAndSettle();
        expect(find.text('Nuevo Madrid'), findsOneWidget);
      }, () => MockClient((_) async => _catalogo(ciudades)));
    },
  );

  testWidgets('permite reintentar tras desconexión y catálogo vacío', (
    tester,
  ) async {
    var consultas = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(home: RegistrarEncomiendaView(idToken: 'prueba')),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('No fue posible cargar las ciudades'),
          findsOneWidget,
        );
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(
          find.text('El catálogo de ciudades está vacío.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(find.byType(SelectorCiudad), findsNWidgets(2));
        expect(consultas, 3);
      },
      () => MockClient((_) async {
        switch (++consultas) {
          case 1:
            throw http.ClientException('Sin conexión');
          case 2:
            return _catalogo([]);
          default:
            return _catalogo(['Madrid', 'París']);
        }
      }),
    );
  });

  testWidgets('exige una ruta distinta y envía los nombres exactos elegidos', (
    tester,
  ) async {
    final rutas = <Map<String, String>>[];
    await http.runWithClient(
      () async {
        await tester.pumpWidget(const MaterialApp(home: BuscarViajerosView()));
        await tester.pumpAndSettle();
        final buscar = find.text('Buscar viajeros disponibles');
        await tester.tap(buscar);
        await tester.pumpAndSettle();
        expect(
          find.text('Selecciona una ciudad del catálogo.'),
          findsNWidgets(2),
        );

        await _elegirCiudad(tester, 0, 'MADRID', 'Madrid');
        await _elegirCiudad(tester, 1, 'MADRID', 'Madrid');
        await tester.tap(buscar);
        await tester.pumpAndSettle();
        expect(
          find.text('Origen y destino deben ser diferentes.'),
          findsOneWidget,
        );
        expect(rutas, isEmpty);

        await _elegirCiudad(tester, 1, 'paris', 'París');
        await tester.tap(buscar);
        await tester.pumpAndSettle();
        expect(rutas.single, {
          'ciudadOrigen': 'Madrid',
          'ciudadDestino': 'París',
        });

        await _buscarCiudad(tester, 1, 'Parí');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(buscar);
        await tester.pumpAndSettle();
        expect(
          find.text('Selecciona una ciudad del catálogo.'),
          findsOneWidget,
        );
        expect(rutas, hasLength(1));

        await _elegirCiudad(tester, 1, 'bogota', 'Bogotá');
        await tester.tap(buscar);
        await tester.pumpAndSettle();
        expect(rutas.last, {
          'ciudadOrigen': 'Madrid',
          'ciudadDestino': 'Bogotá',
        });
        expect(rutas, hasLength(2));
      },
      () => MockClient((solicitud) async {
        if (solicitud.url.path == '/api/ciudades/ciudades') {
          return _catalogo(['Madrid', 'París', 'Bogotá']);
        }
        expect(solicitud.url.path, '/api/viajes/disponibles');
        rutas.add(solicitud.url.queryParameters);
        return http.Response('[]', 200);
      }),
    );
  });
}

Future<void> _elegirCiudad(
  WidgetTester tester,
  int indice,
  String consulta,
  String ciudad,
) async {
  await _buscarCiudad(tester, indice, consulta);
  await tester.tap(find.text(ciudad).last);
  await tester.pumpAndSettle();
}

Future<void> _completarDatos(WidgetTester tester, Widget vista) async {
  final campos = find.byType(TextFormField);
  if (vista is RegistrarViajeView) {
    await tester.enterText(campos.first, 'AA123');
    await _pulsar(tester, find.text('Seleccionar fecha'));
    await _pulsar(tester, find.text('OK'));
  } else if (vista is RegistrarEncomiendaView) {
    final observaciones = campos.at(2);
    final valor = campos.at(3);
    await tester.ensureVisible(observaciones);
    await tester.enterText(observaciones, 'Paquete pequeño');
    await _pulsar(tester, find.byType(DropdownButtonFormField<String>));
    await _pulsar(tester, find.text('COP').last);
    await tester.ensureVisible(valor);
    await tester.enterText(valor, '10000');
  }
}

Future<void> _pulsar(WidgetTester tester, Finder control) async {
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  await tester.tap(control);
  await tester.pumpAndSettle();
}

void _comprobarCatalogo(WidgetTester tester, List<String> ciudades) {
  final selectores = find.byType(SelectorCiudad);
  expect(selectores, findsNWidgets(2));
  for (final selector in tester.widgetList<SelectorCiudad>(selectores)) {
    expect(selector.ciudades, ciudades);
  }
}

Future<void> _buscarCiudad(
  WidgetTester tester,
  int indice,
  String texto,
) async {
  final campo = find.descendant(
    of: find.byType(SelectorCiudad).at(indice),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(campo);
  await tester.enterText(campo, texto);
  await tester.pumpAndSettle();
}

http.Response _catalogo(List<String> ciudades) => http.Response(
  jsonEncode(ciudades),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/main.dart';
import 'package:lapticon_mobile/models/modo_usuario.dart';
import 'package:lapticon_mobile/views/home_view.dart';
import 'package:lapticon_mobile/views/login_view.dart';
import 'package:lapticon_mobile/views/mis_viajes_view.dart';
import 'package:lapticon_mobile/views/perfil_view.dart';

void main() {
  testWidgets(
    'Permite cerrar sesión sin elegir función con el perfil pendiente',
    (tester) async {
      final perfilPendiente = Completer<http.Response>();
      var solicitoPerfil = false;
      await _conApp(
        tester,
        () async {
          await _iniciarSesion(tester);
          expect(solicitoPerfil, isTrue);
          expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
          await _pulsar(tester, find.byTooltip('Opciones de sesión'));
          await _pulsar(tester, find.text('Cerrar sesión'));
          expect(find.byType(LoginView), findsOneWidget);

          perfilPendiente.complete(
            await _respuesta(
              http.Request(
                'GET',
                Uri.parse('https://ejemplo.com/api/users/ana'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(LoginView), findsOneWidget);
        },
        responder: (solicitud) {
          if (solicitud.url.path == '/api/users/ana') {
            solicitoPerfil = true;
            return perfilPendiente.future;
          }
          return _respuesta(solicitud);
        },
      );
    },
  );

  testWidgets(
    'Una cuenta existente cambia de rol desde la cabecera y puede cerrar sesión',
    (tester) => _conApp(tester, () async {
      await _iniciarSesion(tester);
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final continuar = find.widgetWithText(FilledButton, 'Continuar');
      expect(tester.widget<FilledButton>(continuar).onPressed, isNull);

      await _pulsar(tester, find.text('Remitente'));
      await _pulsar(tester, find.text('Continuar'));
      final selector = find.byType(SegmentedButton<ModoUsuario>);
      final cabecera = find.byType(AppBar);
      final modoRemitente = find.descendant(
        of: cabecera,
        matching: find.text('Remitente'),
      );
      final modoViajero = find.descendant(
        of: cabecera,
        matching: find.text('Viajero'),
      );
      expect(modoRemitente, findsOneWidget);
      expect(modoViajero, findsOneWidget);
      expect(tester.widget<SegmentedButton<ModoUsuario>>(selector).selected, {
        ModoUsuario.remitente,
      });
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
      expect(find.text('Publicar encomienda'), findsOneWidget);
      expect(find.text('Mis encomiendas'), findsOneWidget);
      expect(find.text('Buscar viajeros'), findsOneWidget);
      expect(find.text('Mis viajes'), findsNothing);
      expect(find.byType(HomeView), findsNothing);
      expect(find.byType(MisViajesView), findsNothing);

      final marca = find.descendant(
        of: cabecera,
        matching: find.text('Lapticon'),
      );
      await tester.binding.setSurfaceSize(const Size(560, 844));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(modoRemitente).dy,
        closeTo(tester.getCenter(marca).dy, 1),
      );

      await _pulsar(
        tester,
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Mis encomiendas'),
        ),
      );
      expect(modoRemitente, findsOneWidget);
      await _pulsar(tester, modoRemitente);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      await _pulsar(tester, find.text('Perfil'));
      expect(find.byType(PerfilView).hitTestable(), findsOneWidget);
      expect(find.text('ID de la cuenta'), findsNothing);
      expect(find.text('ana'), findsNothing);
      expect(modoRemitente, findsOneWidget);
      expect(find.text('Cambiar función'), findsNothing);

      await tester.binding.setSurfaceSize(const Size(320, 740));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(modoViajero).dy,
        greaterThan(tester.getCenter(marca).dy),
      );
      await _pulsar(tester, modoViajero);
      expect(find.byType(HomeView).hitTestable(), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
      expect(find.text('¿Cómo usarás Lapticon?'), findsNothing);
      expect(tester.widget<SegmentedButton<ModoUsuario>>(selector).selected, {
        ModoUsuario.viajero,
      });
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
      expect(find.text('Registrar viaje'), findsOneWidget);
      expect(find.text('Mis viajes'), findsOneWidget);
      expect(find.text('Buscar encomiendas'), findsOneWidget);
      expect(find.text('Encomiendas tomadas'), findsOneWidget);
      await _pulsar(
        tester,
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Mis viajes'),
        ),
      );
      expect(find.byType(MisViajesView).hitTestable(), findsOneWidget);
      expect(find.byTooltip('Registrar viaje'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Registrar viaje'),
        findsOneWidget,
      );
      expect(modoViajero, findsOneWidget);
      await _pulsar(tester, find.text('Perfil'));
      expect(modoViajero, findsOneWidget);
      await _pulsar(tester, find.text('Cerrar sesión'));
      expect(find.byType(LoginView), findsOneWidget);

      await _iniciarSesion(tester);
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
    }),
  );

  testWidgets('Una cuenta nueva llega al selector al confirmar el registro', (
    tester,
  ) {
    final registros = <Map<String, dynamic>>[];
    var consultas = 0;
    return _conApp(
      tester,
      () async {
        await _pulsar(tester, find.text('Regístrate'));
        expect(consultas, 1);
        expect(find.text('No pudimos cargar los países.'), findsOneWidget);
        await _pulsar(tester, find.text('Reintentar'));
        expect(consultas, 2);
        final campos = find.byType(TextFormField);
        final datos = [
          'Ana',
          'Gómez',
          '3001234567',
          'ana@ejemplo.com',
          'clave-prueba',
        ];
        for (var i = 0; i < datos.length; i++) {
          await tester.ensureVisible(campos.at(i));
          await tester.enterText(campos.at(i), datos[i]);
        }
        await _pulsar(tester, find.text('AAAA/MM/DD'));
        await _pulsar(tester, find.text('OK'));
        final crear = find.widgetWithText(FilledButton, 'Crear cuenta');
        await _pulsar(tester, crear);
        expect(find.text('Selecciona tu país de nacimiento'), findsOneWidget);
        expect(registros, isEmpty);

        await _pulsar(tester, find.text('Selecciona un país'));
        await tester.enterText(find.byType(TextField).last, 'País inexistente');
        await tester.pumpAndSettle();
        expect(find.text('No encontramos ese país.'), findsOneWidget);
        await _pulsar(tester, find.widgetWithText(OutlinedButton, 'Cancelar'));
        await _pulsar(tester, crear);
        expect(registros, isEmpty);

        await _elegirPais(tester, 'Selecciona un país', 'México');
        await _pulsar(tester, crear);
        expect(registros.single['nacionalidad'], 'México');
        expect(find.text('Cuenta creada'), findsOneWidget);
        await _pulsar(tester, find.widgetWithText(FilledButton, 'Continuar'));
        expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        await _pulsar(tester, find.text('Remitente'));
        await _pulsar(tester, find.text('Continuar'));
        await _pulsar(tester, find.text('Perfil'));
        expect(find.text('México'), findsOneWidget);
      },
      responder: (solicitud) async {
        if (solicitud.url.path == '/api/ciudades/paises') {
          expect(solicitud.method, 'GET');
          if (++consultas == 1) return http.Response('', 503);
        }
        if (solicitud.url.path == '/api/users/register') {
          registros.add(jsonDecode(solicitud.body) as Map<String, dynamic>);
        }
        if (solicitud.url.path == '/api/users/ana' && registros.isNotEmpty) {
          return http.Response(
            jsonEncode({
              ...registros.single,
              'uid': 'ana',
              'email': 'ana@ejemplo.com',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return _respuesta(solicitud);
      },
    );
  });

  testWidgets('Permite conservar el dato anterior o elegir un país nuevo', (
    tester,
  ) async {
    var paisGuardado = 'Colombiano';
    var consultas = 0;
    final enviados = <Map<String, dynamic>>[];

    await _conApp(
      tester,
      () async {
        await _iniciarSesion(tester);
        await _pulsar(tester, find.text('Remitente'));
        await _pulsar(tester, find.text('Continuar'));
        await _pulsar(tester, find.text('Perfil'));
        expect(find.text('País de nacimiento'), findsOneWidget);
        expect(find.text('Dato anterior: Colombiano'), findsOneWidget);

        await _pulsar(tester, find.text('Actualizar datos'));
        expect(
          find.textContaining('Dato anterior: Colombiano.'),
          findsOneWidget,
        );
        expect(find.text('No pudimos cargar los países.'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).first, 'Anabel');
        await _pulsar(tester, find.text('Guardar cambios'));
        expect(enviados.single['nombre'], 'Anabel');
        expect(enviados.single['nacionalidad'], 'Colombiano');
        expect(find.text('Dato anterior: Colombiano'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await _pulsar(tester, find.text('Actualizar datos'));
        await _pulsar(tester, find.text('Reintentar'));
        expect(consultas, 4);
        await _elegirPais(tester, 'Selecciona un país', 'México');
        await _pulsar(tester, find.text('Guardar cambios'));
        expect(enviados, hasLength(2));
        expect(enviados.last['nacionalidad'], 'México');
        expect(find.text('México'), findsOneWidget);
        expect(find.textContaining('Dato anterior: Colombiano'), findsNothing);
      },
      responder: (solicitud) async {
        if (solicitud.url.path == '/api/ciudades/paises' &&
            const [2, 3].contains(++consultas)) {
          return http.Response('', 503);
        }
        if (solicitud.url.path == '/api/users/ana') {
          if (solicitud.method == 'PUT') {
            final datos = jsonDecode(solicitud.body) as Map<String, dynamic>;
            enviados.add(datos);
            paisGuardado = datos['nacionalidad'] as String;
          }
          return http.Response(
            jsonEncode({
              'uid': 'ana',
              'email': 'ana@ejemplo.com',
              'nombre': enviados.isEmpty ? 'Ana' : enviados.last['nombre'],
              'apellido': 'Gómez',
              'telefono': '3001234567',
              'fechaNacimiento': '2000-01-01',
              'nacionalidad': paisGuardado,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return _respuesta(solicitud);
      },
    );
  });
}

Future<void> _elegirPais(
  WidgetTester tester,
  String textoSelector,
  String pais,
) async {
  await _pulsar(tester, find.text(textoSelector));
  await tester.enterText(find.byType(TextField).last, pais.toUpperCase());
  await tester.pumpAndSettle();
  await _pulsar(tester, find.widgetWithText(ListTile, pais));
}

Future<void> _conApp(
  WidgetTester tester,
  Future<void> Function() probar, {
  Future<http.Response> Function(http.Request)? responder,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await http.runWithClient(() async {
    await tester.pumpWidget(const LapticonApp());
    await probar();
  }, () => MockClient(responder ?? _respuesta));
}

Future<http.Response> _respuesta(http.Request solicitud) async {
  const usuario =
      '{"localId":"ana","email":"ana@ejemplo.com","idToken":"prueba"}';
  const perfil =
      '{"uid":"ana","email":"ana@ejemplo.com","nombre":"Ana",'
      '"apellido":"Gómez","telefono":"3001234567",'
      '"nacionalidad":"Colombia","fechaNacimiento":"2000-01-01"}';
  return switch ((solicitud.method, solicitud.url.path)) {
    ('POST', '/v1/accounts:signInWithPassword') => http.Response(usuario, 200),
    ('POST', '/v1/accounts:signUp') => http.Response(usuario, 200),
    ('POST', '/api/users/register') => http.Response(perfil, 201),
    ('GET', '/api/users/ana') => http.Response(perfil, 200),
    ('GET', '/api/encomiendas') => http.Response('[]', 200),
    ('GET', '/api/ciudades/paises') => http.Response(
      '["Colombia","México"]',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
    ('GET', '/api/viajes') => http.Response('[]', 200),
    _ => throw StateError('Solicitud inesperada: ${solicitud.url.path}'),
  };
}

Future<void> _iniciarSesion(WidgetTester tester) async {
  final campos = find.byType(TextFormField);
  await tester.enterText(campos.first, 'ana@ejemplo.com');
  await tester.enterText(campos.last, 'clave-prueba');
  await _pulsar(tester, find.widgetWithText(FilledButton, 'Iniciar sesión'));
}

Future<void> _pulsar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

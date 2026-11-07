import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/main.dart';
import 'package:lapticon_mobile/views/home_view.dart';
import 'package:lapticon_mobile/views/login_view.dart';
import 'package:lapticon_mobile/views/mis_viajes_view.dart';
import 'package:lapticon_mobile/views/perfil_view.dart';

void main() {
  testWidgets(
    'Una cuenta existente puede cambiar de función y volver al login',
    (tester) => _conApp(tester, () async {
      await _iniciarSesion(tester);
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final continuar = find.widgetWithText(FilledButton, 'Continuar');
      expect(tester.widget<FilledButton>(continuar).onPressed, isNull);

      await _pulsar(tester, find.text('Remitente'));
      await _pulsar(tester, find.text('Continuar'));
      expect(find.text('Hola, remitente'), findsOneWidget);
      expect(find.text('Publicar encomienda'), findsOneWidget);
      expect(find.text('Viajes'), findsNothing);
      expect(find.byType(HomeView), findsNothing);
      expect(find.byType(MisViajesView), findsNothing);

      await _pulsar(tester, find.text('Perfil'));
      expect(find.byType(PerfilView).hitTestable(), findsOneWidget);
      await _pulsar(tester, find.text('Inicio'));
      expect(find.text('Hola, remitente'), findsOneWidget);
      await _pulsar(tester, find.text('Perfil'));
      await _pulsar(tester, find.text('Cambiar función'));
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
      expect(tester.widget<FilledButton>(continuar).onPressed, isNull);

      await _pulsar(tester, find.text('Viajero'));
      await _pulsar(tester, find.text('Continuar'));
      expect(find.byType(HomeView).hitTestable(), findsOneWidget);
      await _pulsar(tester, find.text('Viajes'));
      expect(find.byType(MisViajesView).hitTestable(), findsOneWidget);
      await _pulsar(tester, find.text('Perfil'));
      await _pulsar(tester, find.text('Cerrar sesión'));
      expect(find.byType(LoginView), findsOneWidget);

      await _iniciarSesion(tester);
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
    }),
  );

  testWidgets(
    'Una cuenta nueva llega al selector al confirmar el registro',
    (tester) => _conApp(tester, () async {
      await _pulsar(tester, find.text('Regístrate'));
      final campos = find.byType(TextFormField);
      final datos = [
        'Ana',
        'Gómez',
        '3001234567',
        'Colombia',
        'ana@ejemplo.com',
        'clave-prueba',
      ];
      for (var i = 0; i < datos.length; i++) {
        await tester.ensureVisible(campos.at(i));
        await tester.enterText(campos.at(i), datos[i]);
      }
      await _pulsar(tester, find.text('AAAA/MM/DD'));
      await _pulsar(tester, find.text('OK'));
      await _pulsar(tester, find.widgetWithText(FilledButton, 'Crear cuenta'));
      expect(find.text('Cuenta creada'), findsOneWidget);
      await _pulsar(tester, find.widgetWithText(FilledButton, 'Continuar'));
      expect(find.text('¿Cómo usarás Lapticon?'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    }),
  );
}

Future<void> _conApp(
  WidgetTester tester,
  Future<void> Function() probar,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await http.runWithClient(() async {
    await tester.pumpWidget(const LapticonApp());
    await probar();
  }, () => MockClient(_respuesta));
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

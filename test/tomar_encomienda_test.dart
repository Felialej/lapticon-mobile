import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/tomar_encomienda_controller.dart';
import 'package:lapticon_mobile/models/encomienda.dart';
import 'package:lapticon_mobile/theme/app_theme.dart';
import 'package:lapticon_mobile/views/detalle_encomienda_view.dart';

const enc = Encomienda(
  id: 'enc-1',
  ciudadOrigen: 'Bogota',
  ciudadDestino: 'Miami',
  observaciones: 'Caja',
  moneda: 'USD',
  valor: 25,
);

void main() {
  testWidgets('Cancelar queda alineado con Aceptar y cierra el diálogo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DetalleEncomiendaView(
          encomienda: enc,
          idToken: 'token-prueba',
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Tomar encomienda'));
    await tester.pumpAndSettle();
    final cancelar = find.widgetWithText(OutlinedButton, 'Cancelar');
    final aceptar = find.widgetWithText(FilledButton, 'Aceptar');
    expect(
      tester.getCenter(cancelar).dy,
      closeTo(tester.getCenter(aceptar).dy, 1),
    );

    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Disponible'), findsOneWidget);
  });

  test('HU-13: PUT sin body ni uid y autenticado con Firebase', () async {
    await http.runWithClient(
      () async {
        final controller = TomarEncomiendaController(idToken: 'token-prueba');
        addTearDown(controller.dispose);
        expect(await controller.aceptar(enc), isTrue);
        expect(controller.tomada, isTrue);
      },
      () => MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/encomiendas/tomar/enc-1');
        expect(request.headers['Authorization'], 'Bearer token-prueba');
        expect(request.body, isEmpty);
        return http.Response(
          jsonEncode({
            'encomienda': {'estado': 'tomada'},
          }),
          200,
        );
      }),
    );
  });

  test('HU-13: 409 no cambia el estado ni acepta', () async {
    await http.runWithClient(() async {
      final controller = TomarEncomiendaController(idToken: 'token-prueba');
      addTearDown(controller.dispose);
      expect(await controller.aceptar(enc), isFalse);
      expect(controller.tomada, isFalse);
      expect(controller.error, contains('disponible'));
    }, () => MockClient((_) async => http.Response('No disponible', 409)));
  });

  test('HU-13: 403 no acepta y muestra error de permisos', () async {
    await http.runWithClient(() async {
      final controller = TomarEncomiendaController(idToken: 'token-prueba');
      addTearDown(controller.dispose);
      expect(await controller.aceptar(enc), isFalse);
      expect(controller.tomada, isFalse);
      expect(controller.error, contains('permiso'));
    }, () => MockClient((_) async => http.Response('Sin permisos', 403)));
  });

  test('HU-13: estado explícito inesperado no marca tomada', () async {
    await http.runWithClient(
      () async {
        final controller = TomarEncomiendaController(idToken: 'token-prueba');
        addTearDown(controller.dispose);
        expect(await controller.aceptar(enc), isFalse);
        expect(controller.tomada, isFalse);
      },
      () => MockClient(
        (_) async => http.Response(
          jsonEncode({
            'encomienda': {'estado': 'disponible'},
          }),
          200,
        ),
      ),
    );
  });

  test('HU-13: encomienda sin id nunca llama al backend', () async {
    final controller = TomarEncomiendaController(idToken: 'token-prueba');
    addTearDown(controller.dispose);
    const sinId = Encomienda(
      ciudadOrigen: 'Bogota',
      ciudadDestino: 'Miami',
      observaciones: '',
      moneda: 'USD',
      valor: 0,
    );
    expect(await controller.aceptar(sinId), isFalse);
    expect(controller.error, contains('identificador'));
  });
}

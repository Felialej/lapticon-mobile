import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/tomar_encomienda_controller.dart';
import 'package:lapticon_mobile/models/encomienda.dart';


const enc = Encomienda(
  id: 'enc-1',
  ciudadOrigen: 'Bogota',
  ciudadDestino: 'Miami',
  observaciones: 'Caja',
  moneda: 'USD',
  valor: 25,
);

void main() {
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

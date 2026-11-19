import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lapticon_mobile/controllers/auth_controller.dart';
import 'package:lapticon_mobile/controllers/perfil_controller.dart';
import 'package:lapticon_mobile/controllers/registrar_encomienda_controller.dart';
import 'package:lapticon_mobile/models/perfil_usuario.dart';
import 'package:lapticon_mobile/utils/validadores.dart';
import 'package:lapticon_mobile/views/editar_perfil_view.dart';
import 'package:lapticon_mobile/views/registrar_encomienda_view.dart';
import 'package:lapticon_mobile/views/registro_view.dart';

void main() {
  test('El teléfono admite entre 7 y 10 dígitos exclusivamente', () {
    for (final valido in ['3001234', '3001234567']) {
      expect(validarTelefono(valido), isNull);
    }
    for (final invalido in [
      null,
      '',
      '300123',
      '30012345678',
      '300A234',
      '+3001234',
      '300 1234',
      '3001234 ',
    ]) {
      expect(validarTelefono(invalido), isNotNull, reason: '$invalido');
    }
  });

  testWidgets(
    'Registro filtra caracteres y limita el teléfono al pegar o escribir',
    (tester) async {
      final auth = AuthController();
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RegistroView(authController: auth)),
      );
      final campo = find.widgetWithText(TextFormField, 'Ejemplo: 3001234567');
      await tester.ensureVisible(campo);
      await tester.enterText(campo, '+300a123-456789');
      final editor = find.descendant(
        of: campo,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editor).controller.text, '3001234567');
      await _editar(tester, '30012345678', 11);
      expect(tester.widget<EditableText>(editor).controller.text, '3001234567');
      await tester.enterText(campo, '3001234');
      expect(tester.widget<EditableText>(editor).controller.text, '3001234');
    },
  );

  testWidgets('Editar perfil conserva el teléfono antiguo y deja corregirlo', (
    tester,
  ) async {
    final controller = PerfilController();
    addTearDown(controller.dispose);
    final perfil = PerfilUsuario.desdeJson({'telefono': '300123456789'});
    await tester.pumpWidget(
      MaterialApp(
        home: EditarPerfilView(
          perfilController: controller,
          perfil: perfil,
          idToken: 'prueba',
        ),
      ),
    );
    final campo = find.widgetWithText(TextFormField, 'Ejemplo: 3001234567');
    final editor = find.descendant(
      of: campo,
      matching: find.byType(EditableText),
    );
    final texto = tester.widget<EditableText>(editor).controller;
    expect(texto.text, '300123456789');
    await tester.ensureVisible(campo);
    await tester.showKeyboard(campo);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '30012345678',
        selection: TextSelection.collapsed(offset: 11),
      ),
    );
    await tester.pump();
    expect(texto.text, '30012345678');
    await tester.enterText(campo, '3001234a5678');
    expect(texto.text, '30012345678');
    await tester.enterText(campo, '300a1234567');
    expect(texto.text, '3001234567');
  });

  testWidgets(
    'El campo Valor agrupa miles y millones y conserva los decimales',
    (tester) async {
      final editor = await _abrirCampoValor(tester);
      for (final caso in {
        '1000': '1.000',
        '100000': '100.000',
        '1000000': '1.000.000',
        '1000000,50': '1.000.000,50',
        '2.500,75': '2.500,75',
        '': '',
        ',': '0,',
        ',50': '0,50',
      }.entries) {
        await _editar(tester, caso.key, caso.key.length);
        expect(editor.text, caso.value);
        expect(editor.selection.extentOffset, caso.value.length);
      }
    },
  );

  testWidgets('El cursor permite editar y borrar junto al separador de miles', (
    tester,
  ) async {
    final editor = await _abrirCampoValor(tester);
    await _editar(tester, '123456', 6);
    await _editar(tester, '123.4956', 6);
    expect(editor.text, '1.234.956');
    expect(editor.selection.extentOffset, 7);
    await _editar(tester, '1.234956', 5);
    expect(editor.text, '1.234.956');
    expect(editor.selection.extentOffset, 5);
    await _editar(tester, '1.23956', 4);
    expect(editor.text, '123.956');
    expect(editor.selection.extentOffset, 3);
    await _editar(tester, 'abc', 3);
    expect(editor.text, '123.956');

    await _editar(tester, '1232.500.956', 8);
    expect(editor.text, '1.232.500.956');
    expect(editor.selection.extentOffset, 9);
    await _editar(tester, '1.232.500956', 9);
    expect(editor.text, '1.232.500.956');
    expect(editor.selection.extentOffset, 10);

    editor.selection = TextSelection(
      baseOffset: 0,
      extentOffset: editor.text.length,
    );
    await tester.pump();
    await _editar(tester, '12.34', 5);
    expect(editor.text, '1.232.500.956');
  });

  testWidgets('Valor rechaza ediciones y pegados de más de 13 dígitos', (
    tester,
  ) async {
    final editor = await _abrirCampoValor(tester);

    await _editar(tester, '1234567890123', 13);
    expect(editor.text, '1.234.567.890.123');
    await _editar(tester, '1.234.567.890.1234', 18);
    expect(editor.text, '1.234.567.890.123');

    editor.selection = TextSelection(
      baseOffset: 0,
      extentOffset: editor.text.length,
    );
    await tester.pump();
    await _editar(tester, '100.000.000.000.000.000', 23);
    expect(editor.text, '1.234.567.890.123');

    await _editar(tester, '99.999.999.999,99', 17);
    expect(editor.text, '99.999.999.999,99');
    await _editar(tester, '99.999.999.999,999', 18);
    expect(editor.text, '99.999.999.999,99');
  });

  test('El controlador aplica el máximo antes de construir la encomienda', () {
    final controller = RegistrarEncomiendaController()
      ..seleccionarOrigen('Bogota')
      ..seleccionarDestino('Cali')
      ..seleccionarMoneda('COP');
    addTearDown(controller.dispose);

    expect(controller.validarValor('9.999.999.999.999'), isNull);
    expect(controller.validarValor('99.999.999.999,99'), isNull);
    for (final valor in ['10.000.000.000.000', '99.999.999.999,999']) {
      expect(controller.validarValor(valor), contains('13 dígitos'));
      expect(
        () => controller.construirEncomienda(
          observaciones: 'Paquete',
          valor: valor,
        ),
        throwsFormatException,
      );
    }
  });

  test('El controlador rechaza importes vacíos, inválidos e incompletos', () {
    final controller = RegistrarEncomiendaController();
    addTearDown(controller.dispose);
    for (final invalido in [
      null,
      '',
      ' ',
      '0',
      '0,00',
      'abc',
      'NaN',
      'Infinity',
      '-1',
      '12.34',
      '1,2,3',
      '1.000,',
    ]) {
      expect(controller.validarValor(invalido), isNotNull, reason: '$invalido');
    }
    for (final valido in ['100000', '100.000', '1.000.000,50', '0,50']) {
      expect(controller.validarValor(valido), isNull, reason: valido);
    }
  });

  test(
    'El JSON de registro envía valores numéricos sin separadores de miles',
    () async {
      final controller = RegistrarEncomiendaController()
        ..seleccionarOrigen('Bogota')
        ..seleccionarDestino('Cali')
        ..seleccionarMoneda('COP');
      addTearDown(controller.dispose);
      final enviados = <Object?>[];
      await http.runWithClient(
        () async {
          for (final valor in ['100.000', '1.000.000,50']) {
            final resultado = await controller.registrarEncomienda(
              observaciones: 'Paquete',
              valor: valor,
              idToken: 'prueba',
            );
            expect(resultado, isNotNull);
          }
        },
        () => MockClient((solicitud) async {
          final datos = jsonDecode(solicitud.body) as Map<String, dynamic>;
          enviados.add(datos['valor']);
          return http.Response(solicitud.body, 201);
        }),
      );
      expect(enviados, [100000, 1000000.5]);
    },
  );
}

Future<TextEditingController> _abrirCampoValor(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: RegistrarEncomiendaView(idToken: 'prueba')),
  );
  final campo = find.byType(TextFormField).last;
  await tester.ensureVisible(campo);
  await tester.showKeyboard(campo);
  final editor = find.descendant(
    of: campo,
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editor).controller;
}

Future<void> _editar(WidgetTester tester, String texto, int cursor) async {
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: cursor),
    ),
  );
  await tester.pump();
}

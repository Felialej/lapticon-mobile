import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/main.dart';

void main() {
  testWidgets(
    'La pantalla de registro valida campos obligatorios',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const LapticonApp(),
      );

      expect(
        find.text('Crear cuenta'),
        findsWidgets,
      );

      expect(
        find.text('Correo electrónico'),
        findsOneWidget,
      );

      expect(
        find.text('Contraseña'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(
          FilledButton,
          'Crear cuenta',
        ),
      );

      await tester.pump();

      expect(
        find.text('El correo es obligatorio'),
        findsOneWidget,
      );

      expect(
        find.text('La contraseña es obligatoria'),
        findsOneWidget,
      );
    },
  );
}
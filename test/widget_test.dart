import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/main.dart';

void main() {
  testWidgets(
    'La navegación principal de Lapticon funciona',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const LapticonApp(),
      );

      expect(
        find.text('Lapticon'),
        findsOneWidget,
      );

      expect(
        find.text('Viaja y conecta'),
        findsOneWidget,
      );

      expect(
        find.text('Registrar viaje'),
        findsWidgets,
      );

      expect(
        find.text('Inicio'),
        findsOneWidget,
      );

      expect(
        find.text('Viajes'),
        findsOneWidget,
      );

      expect(
        find.text('Perfil'),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Perfil'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Mi perfil'),
        findsOneWidget,
      );
    },
  );
}
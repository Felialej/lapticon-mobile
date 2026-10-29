import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/controllers/auth_controller.dart';
import 'package:lapticon_mobile/main.dart';
import 'package:lapticon_mobile/views/registro_view.dart';

void main() {
  // Pruebas de interfaz: comprueban que los formularios muestren los errores
  // cuando se envían incompletos.
  group('Formularios de acceso', () {
    testWidgets(
      'El inicio de sesión exige correo y contraseña',
      (tester) async {
        await tester.pumpWidget(const LapticonApp());

        // Sin sesión activa, la aplicación arranca en el inicio de sesión.
        final boton = find.widgetWithText(
          FilledButton,
          'Iniciar sesión',
        );

        expect(boton, findsOneWidget);

        await tester.tap(boton);
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

    testWidgets(
      'El registro exige la longitud mínima de contraseña',
      (tester) async {
        // La vista se construye directamente con su controlador para probarla
        // sin pasar por el inicio de sesión.
        await tester.pumpWidget(
          MaterialApp(
            home: RegistroView(
              authController: AuthController(),
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.first,
          'persona@correo.com',
        );

        await tester.enterText(campos.last, '123');

        await tester.tap(
          find.widgetWithText(
            FilledButton,
            'Crear cuenta',
          ),
        );

        await tester.pump();

        expect(
          find.text(
            'La contraseña debe tener al menos 6 caracteres',
          ),
          findsOneWidget,
        );
      },
    );
  });

  // Pruebas de lógica: al vivir las reglas en el controlador, se verifican sin
  // construir ninguna pantalla.
  group('Validaciones de AuthController', () {
    final authController = AuthController();

    test('rechaza un correo sin arroba', () {
      expect(
        authController.validarCorreo('correo.com'),
        isNotNull,
      );
    });

    test('rechaza un correo vacío', () {
      expect(
        authController.validarCorreo('   '),
        isNotNull,
      );
    });

    test('acepta un correo con formato válido', () {
      expect(
        authController.validarCorreo('persona@correo.com'),
        isNull,
      );
    });

    test(
      'el inicio de sesión acepta cualquier contraseña no vacía',
      () {
        expect(
          authController.validarPassword('123'),
          isNull,
        );
      },
    );

    test(
      'el registro rechaza contraseñas de menos de 6 caracteres',
      () {
        expect(
          authController.validarPassword(
            '123',
            exigirLongitudMinima: true,
          ),
          isNotNull,
        );
      },
    );

    test('no hay sesión activa al iniciar el controlador', () {
      expect(authController.haySesion, isFalse);
      expect(authController.usuario, isNull);
    });
  });
}

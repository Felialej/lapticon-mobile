import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/controllers/auth_controller.dart';
import 'package:lapticon_mobile/main.dart';
import 'package:lapticon_mobile/models/perfil_usuario.dart';
import 'package:lapticon_mobile/utils/validadores.dart';
import 'package:lapticon_mobile/views/registro_view.dart';
import 'package:lapticon_mobile/views/seleccion_modo_view.dart';

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
      'El registro exige los datos personales y la contraseña',
      (tester) async {
        // El formulario es más alto que la ventana de prueba, así que se
        // agranda para que todos los campos y el botón queden visibles.
        await tester.binding.setSurfaceSize(const Size(900, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // La vista se construye directamente con su controlador para probarla
        // sin pasar por el inicio de sesión.
        await tester.pumpWidget(
          MaterialApp(
            home: RegistroView(
              authController: AuthController(),
            ),
          ),
        );

        // La contraseña es el último campo del formulario.
        await tester.enterText(
          find.byType(TextFormField).last,
          '123',
        );

        final boton = find.widgetWithText(
          FilledButton,
          'Crear cuenta',
        );

        await tester.ensureVisible(boton);
        await tester.pumpAndSettle();
        await tester.tap(boton);
        await tester.pumpAndSettle();

        expect(
          find.text('La contraseña debe tener al menos 6 caracteres'),
          findsOneWidget,
        );

        expect(
          find.text('Ingresa tu nombre'),
          findsOneWidget,
        );

        expect(
          find.text('Ingresa tu teléfono'),
          findsOneWidget,
        );
      },
    );
  });

  group('Pantalla de inicio', () {
    testWidgets(
      'Continuar se habilita al elegir un modo',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SeleccionModoView(
              authController: AuthController(),
            ),
          ),
        );

        expect(find.text('Remitente'), findsOneWidget);
        expect(find.text('Viajero'), findsOneWidget);

        final boton = find.widgetWithText(FilledButton, 'Continuar');

        // Sin modo marcado el botón está deshabilitado.
        expect(
          tester.widget<FilledButton>(boton).onPressed,
          isNull,
        );

        await tester.tap(find.text('Viajero'));
        await tester.pump();

        expect(
          tester.widget<FilledButton>(boton).onPressed,
          isNotNull,
        );
      },
    );
  });

  // Pruebas de lógica: al vivir las reglas en el controlador y en las
  // utilidades, se verifican sin construir ninguna pantalla.
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

  group('Validaciones del perfil', () {
    test('rechaza un texto obligatorio vacío', () {
      expect(
        validarTextoObligatorio('  ', 'nombre'),
        isNotNull,
      );
    });

    test('acepta un texto obligatorio con contenido', () {
      expect(
        validarTextoObligatorio('Ana', 'nombre'),
        isNull,
      );
    });

    test('rechaza un teléfono con letras', () {
      expect(
        validarTelefono('300ABC4567'),
        isNotNull,
      );
    });

    test('rechaza un teléfono demasiado corto', () {
      expect(
        validarTelefono('30012'),
        isNotNull,
      );
    });

    test('acepta un teléfono de solo números', () {
      expect(
        validarTelefono('3001234567'),
        isNull,
      );
    });
  });

  group('Modelo PerfilUsuario', () {
    test(
      'toma el correo del campo email cuando no viene el campo correo',
      () {
        final perfil = PerfilUsuario.desdeJson({
          'uid': 'abc123',
          'email': 'persona@correo.com',
          'nombre': 'Ana',
          'apellido': 'Gómez',
        });

        expect(perfil.correo, 'persona@correo.com');
        expect(perfil.nombreCompleto, 'Ana Gómez');
      },
    );

    test(
      'el cuerpo de registro envía el correo y deja el email al backend',
      () {
        const perfil = PerfilUsuario(
          uid: 'abc123',
          email: 'persona@correo.com',
          correo: 'persona@correo.com',
          nombre: 'Ana',
          apellido: 'Gómez',
          telefono: '3001234567',
          nacionalidad: 'Colombia',
        );

        final cuerpo = perfil.toJsonRegistro();

        expect(cuerpo['correo'], 'persona@correo.com');
        expect(cuerpo.containsKey('email'), isFalse);
        expect(cuerpo.containsKey('uid'), isFalse);
      },
    );

    test(
      'el cuerpo de actualización no incluye el uid ni el correo',
      () {
        final perfil = PerfilUsuario(
          uid: 'abc123',
          email: 'persona@correo.com',
          correo: 'persona@correo.com',
          nombre: 'Ana',
          apellido: 'Gómez',
          telefono: '3001234567',
          nacionalidad: 'Colombia',
          fechaNacimiento: DateTime(2000, 5, 14),
        );

        final cuerpo = perfil.toJsonActualizacion();

        expect(cuerpo.containsKey('uid'), isFalse);
        expect(cuerpo.containsKey('email'), isFalse);
        expect(cuerpo.containsKey('correo'), isFalse);
        expect(cuerpo['fechaNacimiento'], '2000-05-14');
      },
    );
  });
}

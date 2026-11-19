import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/models/encomienda.dart';
import 'package:lapticon_mobile/views/mis_encomiendas_view.dart';
import 'package:lapticon_mobile/views/seguimiento_encomienda_view.dart';

void main() {
  const encomiendaTomada = Encomienda(
    id: '1',
    ciudadOrigen: 'Bogotá',
    ciudadDestino: 'Miami',
    observaciones: 'Paquete pequeño',
    moneda: 'COP',
    valor: 60000,
    estado: EstadoEncomienda.tomada,
  );

  Widget conPantalla(Widget pantalla) {
    return MaterialApp(home: Scaffold(body: pantalla));
  }

  testWidgets(
    'El listado muestra la ruta, el valor y el estado de cada encomienda',
    (tester) async {
      await tester.pumpWidget(
        conPantalla(
          MisEncomiendasView(
            encomiendas: const [encomiendaTomada],
            cargando: false,
            error: null,
            onPublicarEncomienda: () {},
            onVerSeguimiento: (_) {},
            onRecargar: () async {},
          ),
        ),
      );

      expect(find.text('Bogotá → Miami'), findsOneWidget);
      expect(find.text('COP 60.000'), findsOneWidget);
      expect(find.text('Tomada'), findsOneWidget);
      expect(find.text('Ver seguimiento'), findsOneWidget);
      expect(
        find.text('Publicar otra encomienda'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'El listado vacío invita a publicar la primera encomienda',
    (tester) async {
      await tester.pumpWidget(
        conPantalla(
          MisEncomiendasView(
            encomiendas: const [],
            cargando: false,
            error: null,
            onPublicarEncomienda: () {},
            onVerSeguimiento: (_) {},
            onRecargar: () async {},
          ),
        ),
      );

      expect(
        find.text('Todavía no tienes encomiendas'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'El seguimiento marca los pasos alcanzados y no permite cambiar el estado',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SeguimientoEncomiendaView(
            encomienda: encomiendaTomada,
          ),
        ),
      );

      expect(find.text('Progreso de entrega'), findsOneWidget);
      expect(find.text('COP 60.000'), findsOneWidget);
      expect(find.text('Disponible'), findsOneWidget);
      expect(find.text('Tomada'), findsWidgets);
      expect(find.text('Recibida'), findsOneWidget);

      // Disponible y Tomada quedan confirmadas; Recibida sigue pendiente.
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      // El remitente solo consulta: la pantalla no ofrece acciones.
      expect(find.byType(FilledButton), findsNothing);
      expect(
        find.textContaining('El viajero actualiza los estados'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Una encomienda vencida no marca pasos de entrega',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SeguimientoEncomiendaView(
            encomienda: Encomienda(
              id: '2',
              ciudadOrigen: 'Cali',
              ciudadDestino: 'Madrid',
              observaciones: '',
              moneda: 'EUR',
              valor: 25.5,
              estado: EstadoEncomienda.vencida,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.text('EUR 25,50'), findsOneWidget);
      expect(
        find.textContaining('venció antes de que un viajero'),
        findsOneWidget,
      );
    },
  );
}

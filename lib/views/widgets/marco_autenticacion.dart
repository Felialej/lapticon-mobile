import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Encabezado y tarjeta compartidos por las pantallas de acceso.
class MarcoAutenticacion extends StatelessWidget {
  const MarcoAutenticacion({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.child,
    this.separacionTarjeta = 26,
    this.accionEncabezado,
  });

  final String titulo;
  final String subtitulo;
  final Widget child;
  final double separacionTarjeta;
  final Widget? accionEncabezado;

  static const _degradado = LinearGradient(
    colors: [AppTheme.primary, AppTheme.secondary],
    end: Alignment(1.7, 0),
  );

  @override
  Widget build(BuildContext context) {
    final tema = AppTheme.paraAutenticacion(Theme.of(context));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _degradado),
        child: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // El degradado continúa detrás del borde de la tarjeta.
                        const Positioned.fill(
                          bottom: -28,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _degradado,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(190, 12),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 456),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    26,
                                    52,
                                    26,
                                    separacionTarjeta,
                                  ),
                                  child: const _Encabezado(),
                                ),
                                if (accionEncabezado case final accion?)
                                  PositionedDirectional(
                                    top: 0,
                                    end: 14,
                                    child: accion,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 456),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Theme(
                            data: tema,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(27),
                              textStyle: tema.textTheme.bodyMedium,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  33,
                                  24,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      titulo,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 25,
                                        height: 1.32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      subtitulo,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        height: 1.55,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    child,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    const textoClaro = Color(0xFFE8F1FD);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final mostrarRuta =
                constraints.maxWidth >= 320 &&
                MediaQuery.textScalerOf(context).scale(26) <= 30;

            return Row(
              children: [
                Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                    color: const Color(0xFF456B99),
                    border: Border.all(color: const Color(0xFF7896BE)),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Transform.rotate(
                    angle: math.pi / 8,
                    child: const Icon(
                      Icons.flight_rounded,
                      color: Colors.white,
                      size: 41,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lapticon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1.23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Viaja y conecta',
                        style: TextStyle(
                          color: textoClaro,
                          fontSize: 13,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                ),
                if (mostrarRuta)
                  const CustomPaint(
                    size: Size(113, 57),
                    painter: _RutaDecorativa(),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 47),
        const Text(
          'Conecta tus destinos.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Envía encomiendas o viaja con ellas.',
          style: TextStyle(color: textoClaro, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _RutaDecorativa extends CustomPainter {
  const _RutaDecorativa();

  @override
  void paint(Canvas canvas, Size size) {
    final ruta = Path()
      ..moveTo(12, 6)
      ..quadraticBezierTo(66, -16, 103, 31);
    final tramo = ruta.computeMetrics().first;
    final linea = Paint()
      ..color = const Color(0x669EBBDE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double inicio = 0; inicio + 5 < tramo.length; inicio += 12) {
      canvas.drawPath(tramo.extractPath(inicio, inicio + 5), linea);
    }

    linea.color = const Color(0xFF9EBBDE);
    canvas.drawCircle(const Offset(5, 8), 5, linea);
    canvas.drawPath(
      Path()
        ..moveTo(92, 31)
        ..lineTo(112, 44)
        ..lineTo(91, 46)
        ..lineTo(97, 39)
        ..close(),
      Paint()..color = linea.color,
    );
  }

  @override
  bool shouldRepaint(_RutaDecorativa oldDelegate) => false;
}

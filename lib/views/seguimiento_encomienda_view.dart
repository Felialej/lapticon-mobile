import 'package:flutter/material.dart';

import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import 'widgets/etiqueta_estado.dart';

class SeguimientoEncomiendaView extends StatelessWidget {
  const SeguimientoEncomiendaView({
    super.key,
    required this.encomienda,
  });

  final Encomienda encomienda;

  static const List<EstadoEncomienda> _pasos = [
    EstadoEncomienda.disponible,
    EstadoEncomienda.tomada,
    EstadoEncomienda.recibida,
  ];

  @override
  Widget build(BuildContext context) {
    final vencida =
        encomienda.estado == EstadoEncomienda.vencida;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seguimiento',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    encomienda.ruta,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme
                                    .textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              encomienda.valorConMoneda,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      EtiquetaEstado(
                        estado: encomienda.estado,
                      ),
                    ],
                  ),

                  if (encomienda
                      .observaciones.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      encomienda.observaciones,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Progreso de entrega',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Column(
                children: [
                  for (final paso in _pasos)
                    _PasoSeguimiento(
                      estado: paso,
                      alcanzado: !vencida &&
                          encomienda.estado.paso >=
                              paso.paso,
                      esUltimo: paso == _pasos.last,
                    ),
                ],
              ),
            ),

            if (vencida) ...[
              const SizedBox(height: 18),
              const Text(
                'La encomienda venció antes de que un viajero la tomara.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PasoSeguimiento extends StatelessWidget {
  const _PasoSeguimiento({
    required this.estado,
    required this.alcanzado,
    required this.esUltimo,
  });

  final EstadoEncomienda estado;
  final bool alcanzado;
  final bool esUltimo;

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF12A868);
    const gris = Color(0xFFD0D5DD);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: alcanzado
                      ? verde
                      : const Color(0xFFF2F4F7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: alcanzado ? verde : gris,
                  ),
                ),
                child: Icon(
                  alcanzado
                      ? Icons.check
                      : Icons.circle_outlined,
                  size: 18,
                  color: alcanzado
                      ? Colors.white
                      : const Color(0xFF98A2B3),
                ),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: 2,
                    color: alcanzado ? verde : gris,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: esUltimo ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    estado.etiqueta,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: alcanzado
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    estado.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

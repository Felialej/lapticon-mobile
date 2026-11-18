import 'package:flutter/material.dart';

import '../../models/viaje.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato_fecha.dart';

/// Tarjeta con la información de un viaje.
class ViajeCard extends StatelessWidget {
  const ViajeCard({
    super.key,
    required this.viaje,
    required this.onCompletarViaje,
  });

  final Viaje viaje;

  final Future<void> Function(Viaje viaje) onCompletarViaje;

  @override
  Widget build(BuildContext context) {
    final estado = viaje.estado.trim().toLowerCase();

    final esDisponible = estado == Viaje.estadoDisponible;

    final esCompletado = estado == Viaje.estadoCompletado;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.flight_rounded,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Vuelo ${viaje.numeroVuelo}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              _EstadoViaje(estado: viaje.estado, completado: esCompletado),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _Ciudad(
                  label: 'ORIGEN',
                  ciudad: viaje.ciudadOrigen,
                  alignment: CrossAxisAlignment.start,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.secondary,
                ),
              ),

              Expanded(
                child: _Ciudad(
                  label: 'DESTINO',
                  ciudad: viaje.ciudadDestino,
                  alignment: CrossAxisAlignment.end,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                formatearFechaVisible(viaje.fechaViaje),
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),

          /// Solo se puede completar un viaje
          /// que todavía está disponible.
          if (esDisponible) ...[
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await onCompletarViaje(viaje);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como completado'),
              ),
            ),
          ],

          /// Si ya está completado simplemente
          /// mostramos una indicación visual.
          if (esCompletado) ...[
            const SizedBox(height: 16),

            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF248A52),
                ),
                SizedBox(width: 7),
                Text(
                  'Este viaje ya fue completado',
                  style: TextStyle(
                    color: Color(0xFF248A52),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Etiqueta visual del estado del viaje.
class _EstadoViaje extends StatelessWidget {
  const _EstadoViaje({required this.estado, required this.completado});

  final String estado;
  final bool completado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: completado ? const Color(0xFFE8F7EE) : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalizarEstado(estado),
        style: TextStyle(
          color: completado ? const Color(0xFF248A52) : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _capitalizarEstado(String valor) {
    if (valor.isEmpty) {
      return valor;
    }

    return '${valor[0].toUpperCase()}'
        '${valor.substring(1)}';
  }
}

/// Ciudad de origen o destino.
class _Ciudad extends StatelessWidget {
  const _Ciudad({
    required this.label,
    required this.ciudad,
    required this.alignment,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final String ciudad;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ciudad,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

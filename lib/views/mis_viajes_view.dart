import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../theme/app_theme.dart';
import 'widgets/viaje_card.dart';

/// Pestaña que lista los viajes registrados.
///
/// Es una vista sin estado: recibe la lista ya resuelta por el controlador
/// de viajes y únicamente se encarga de mostrarla y comunicar las acciones
/// del usuario.
class MisViajesView extends StatelessWidget {
  const MisViajesView({
    super.key,
    required this.viajes,
    required this.onRegistrarViaje,
    required this.onCompletarViaje,
  });

  /// Viajes a mostrar.
  final List<Viaje> viajes;

  /// Acción que abre el formulario de registro.
  final VoidCallback onRegistrarViaje;

  /// Acción que solicita marcar un viaje como completado.
  final Future<void> Function(Viaje viaje) onCompletarViaje;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis viajes',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulta tus rutas registradas',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (viajes.isNotEmpty)
                  IconButton.filled(
                    onPressed: onRegistrarViaje,
                    icon: const Icon(Icons.add),
                    tooltip: 'Registrar viaje',
                  ),
              ],
            ),
          ),

          Expanded(
            child: viajes.isEmpty
                ? _EmptyState(onRegistrarViaje: onRegistrarViaje)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    itemCount: viajes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final viaje = viajes[index];

                      return ViajeCard(
                        viaje: viaje,
                        onCompletarViaje: onCompletarViaje,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío de la pestaña.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRegistrarViaje});

  final VoidCallback onRegistrarViaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flight_outlined,
                size: 52,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes viajes',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando registres un viaje aparecerá en esta sección.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: FilledButton.icon(
                onPressed: onRegistrarViaje,
                icon: const Icon(Icons.add),
                label: const Text('Registrar viaje'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

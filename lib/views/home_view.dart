import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pestaña de inicio con el resumen y los accesos rápidos.
///
/// Es una vista sin estado: recibe el dato que muestra y las acciones que
/// ejecuta, de modo que no necesita controlador propio.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.cantidadViajes,
    required this.onRegistrarViaje,
    required this.onVerViajes,
  });

  /// Total de viajes registrados, tomado del controlador de viajes.
  final int cantidadViajes;

  /// Acción que abre el formulario de registro de viaje.
  final VoidCallback onRegistrarViaje;

  /// Acción que cambia a la pestaña de viajes.
  final VoidCallback onVerViajes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con la marca y el acceso a notificaciones.
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.flight_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lapticon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Viaja y conecta',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Tarjeta destacada que invita a registrar un viaje.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF163A69),
                    Color(0xFF2F80ED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Avión decorativo que sobresale del recuadro.
                  const Positioned(
                    right: -15,
                    bottom: -20,
                    child: Icon(
                      Icons.flight_takeoff_rounded,
                      size: 125,
                      color: Color(0x26FFFFFF),
                    ),
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu próxima ruta\nempieza aquí',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(
                        width: 230,
                        child: Text(
                          'Registra tu viaje y encuentra oportunidades en tu ruta.',
                          style: TextStyle(
                            color: Color(0xFFE7EEF8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              AppTheme.primary,
                          minimumSize: const Size(0, 46),
                        ),
                        onPressed: onRegistrarViaje,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Registrar viaje',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Título de la sección de accesos, con el contador de viajes.
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis opciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (cantidadViajes > 0)
                  Text(
                    '$cantidadViajes viaje(s)',
                    style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            _ActionCard(
              icon: Icons.flight_takeoff_rounded,
              iconColor: AppTheme.secondary,
              title: 'Registrar viaje',
              subtitle:
                  'Agrega los datos de tu próximo vuelo',
              onTap: onRegistrarViaje,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.luggage_outlined,
              iconColor: const Color(0xFF7F56D9),
              title: 'Mis viajes',
              subtitle: cantidadViajes == 0
                  ? 'Todavía no tienes viajes registrados'
                  : '$cantidadViajes viaje(s) registrado(s)',
              onTap: onVerViajes,
            ),

            const SizedBox(height: 26),

            // Recordatorio sobre el uso correcto del registro de viajes.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.secondary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Registra únicamente vuelos que realmente vayas a realizar.',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de acceso a una acción de la aplicación.
///
/// Se declara privada porque solo se usa dentro de esta vista.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

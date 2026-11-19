import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pestaña de inicio de Viajero.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onRegistrarViaje,
    required this.onVerEncomiendasTomadas,
    required this.onBuscarEncomiendas,
  });

  /// Acción que abre el formulario de registro de viaje.
  final VoidCallback onRegistrarViaje;

  final VoidCallback onVerEncomiendasTomadas;
  final VoidCallback onBuscarEncomiendas;

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
            // Tarjeta destacada que invita a registrar un viaje.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    Color(0xFF205CA9),
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
                        'Registra tu próximo viaje',
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
                          'Busca encomiendas que puedas llevar en tu ruta.',
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

            const Text(
              'Accesos rápidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            _ActionCard(
              icon: Icons.search_outlined,
              iconColor: AppTheme.secondary,
              title: 'Buscar encomiendas',
              subtitle: 'Encuentra encomiendas disponibles en tu ruta',
              onTap: onBuscarEncomiendas,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.inventory_2_outlined,
              iconColor: AppTheme.primary,
              title: 'Encomiendas tomadas',
              subtitle: 'Consulta las encomiendas aceptadas por ruta',
              onTap: onVerEncomiendasTomadas,
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

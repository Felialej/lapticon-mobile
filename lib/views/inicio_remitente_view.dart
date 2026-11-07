import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InicioRemitenteView extends StatelessWidget {
  const InicioRemitenteView({
    super.key,
    required this.onPublicarEncomienda,
    required this.onVerEncomiendas,
    required this.onBuscarViajeros,
  });

  final VoidCallback onPublicarEncomienda;
  final VoidCallback onVerEncomiendas;
  final VoidCallback onBuscarViajeros;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
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
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Modo remitente',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textPrimary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Gestiona tus encomiendas de forma sencilla.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Hola, remitente',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Envía con personas que ya van a tu destino.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Publica tu próxima encomienda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Indica origen, destino y los detalles de tu envío.',
                    style: TextStyle(
                      color: Color(0xFFE7EEF8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: onPublicarEncomienda,
                      child: const Text(
                        'Publicar encomienda',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Accesos rápidos',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            _TarjetaAcceso(
              icono: Icons.inventory_2_outlined,
              titulo: 'Mis encomiendas',
              subtitulo: 'Consulta tus publicaciones',
              onTap: onVerEncomiendas,
            ),

            const SizedBox(height: 12),

            _TarjetaAcceso(
              icono: Icons.search,
              titulo: 'Buscar viajeros',
              subtitulo: 'Encuentra rutas disponibles',
              onTap: onBuscarViajeros,
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAcceso extends StatelessWidget {
  const _TarjetaAcceso({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icono,
                  color: AppTheme.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF98A2B3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

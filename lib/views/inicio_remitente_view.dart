import 'package:flutter/material.dart';

import '../models/modo_usuario.dart';
import '../theme/app_theme.dart';
import 'widgets/estilo_modo.dart';

class InicioRemitenteView extends StatelessWidget {
  const InicioRemitenteView({
    super.key,
    required this.onPublicarEncomienda,
    required this.onBuscarViajeros,
  });

  final VoidCallback onPublicarEncomienda;
  final VoidCallback onBuscarViajeros;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, ModoUsuario.remitente.acento],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
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
                        foregroundColor: ModoUsuario.remitente.acento,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 14),


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
                  color: ModoUsuario.remitente.fondo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icono,
                  color: ModoUsuario.remitente.acento,
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

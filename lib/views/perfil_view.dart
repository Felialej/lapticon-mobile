import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

/// Pestaña con los datos de la cuenta y el cierre de sesión.
///
/// Lee del [AuthController] el usuario de la sesión activa. Los datos
/// personales completos (nombre, teléfono, nacionalidad) los expone el backend
/// en `GET /api/users/{uid}` y están pendientes de conectar.
class PerfilView extends StatelessWidget {
  const PerfilView({
    super.key,
    required this.authController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    // El ListenableBuilder mantiene la pestaña al día si la sesión cambia.
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final usuario = authController.usuario;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi perfil',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Información de tu cuenta',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                // Identificación de la cuenta con la que se inició sesión.
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 55,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Usuario Lapticon',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        usuario?.email ??
                            'Sin sesión activa',
                        style: const TextStyle(
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                const Text(
                  'Cuenta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const _InfoCard(
                  icon: Icons.person_outline,
                  title: 'Datos personales',
                  subtitle:
                      'Se cargarán desde tu cuenta',
                ),

                const SizedBox(height: 12),

                const _InfoCard(
                  icon: Icons.star_outline_rounded,
                  title: 'Calificaciones',
                  subtitle:
                      'Consulta tu reputación en Lapticon',
                ),

                const SizedBox(height: 12),

                const _InfoCard(
                  icon: Icons.security_outlined,
                  title: 'Cuenta segura',
                  subtitle:
                      'Autenticación mediante Firebase',
                ),

                const SizedBox(height: 26),

                // Aviso sobre los datos que aún no se consultan al backend.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E8),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tus datos personales se mostrarán aquí cuando se conecte el perfil del backend.',
                          style: TextStyle(
                            color:
                                AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Al cerrar sesión el controlador descarta el usuario y la
                // raíz de la aplicación vuelve al inicio de sesión.
                OutlinedButton.icon(
                  onPressed: authController.cerrarSesion,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar sesión',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(52),
                    foregroundColor:
                        const Color(0xFFB42318),
                    side: const BorderSide(
                      color: Color(0xFFFDA29B),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fila informativa de la sección de cuenta.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}

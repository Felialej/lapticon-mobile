import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/perfil_controller.dart';
import '../models/perfil_usuario.dart';
import '../theme/app_theme.dart';
import '../utils/formato_fecha.dart';
import 'editar_perfil_view.dart';

/// Pestaña con los datos personales de la cuenta.
///
/// Muestra la ficha que el [PerfilController] consulta en
/// `GET /api/users/{uid}` y ofrece las acciones de actualizar y cerrar sesión.
class PerfilView extends StatelessWidget {
  const PerfilView({
    super.key,
    required this.authController,
    required this.perfilController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  /// Controlador que consulta y actualiza los datos personales.
  final PerfilController perfilController;

  /// Abre la pantalla de edición y avisa del resultado al volver.
  Future<void> _editarPerfil(
    BuildContext context,
    PerfilUsuario perfil,
  ) async {
    final usuario = authController.usuario;

    if (usuario == null) {
      return;
    }

    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilView(
          perfilController: perfilController,
          perfil: perfil,
          idToken: usuario.idToken,
        ),
      ),
    );

    if (actualizado != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Vuelve a consultar el perfil al backend.
  Future<void> _recargar() async {
    final usuario = authController.usuario;

    if (usuario == null) {
      return;
    }

    await perfilController.cargarPerfil(
      uid: usuario.uid,
      idToken: usuario.idToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    // El ListenableBuilder redibuja la pestaña cuando el perfil se carga o se
    // actualiza.
    return ListenableBuilder(
      listenable: perfilController,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                const SizedBox(height: 24),

                // El contenido cambia según el estado del controlador:
                // cargando, con error o con los datos ya disponibles.
                _contenido(context),

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
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: const Color(0xFFB42318),
                    side: const BorderSide(
                      color: Color(0xFFFDA29B),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  /// Elige qué mostrar según el estado del controlador.
  Widget _contenido(BuildContext context) {
    if (perfilController.cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final perfil = perfilController.perfil;

    if (perfil == null) {
      return _MensajeDeError(
        mensaje:
            perfilController.error ??
            'No fue posible cargar tus datos.',
        onReintentar: _recargar,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Identificación de la cuenta.
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
              Text(
                perfil.nombreCompleto.isEmpty
                    ? 'Usuario Lapticon'
                    : perfil.nombreCompleto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                perfil.correo,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        const Text(
          'Datos registrados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Cada dato guardado en el backend, en el orden del formulario.
        _FilaDato(
          icono: Icons.key_outlined,
          etiqueta: 'ID de la cuenta',
          valor: perfil.uid,
        ),
        _FilaDato(
          icono: Icons.person_outline,
          etiqueta: 'Nombre',
          valor: perfil.nombre,
        ),
        _FilaDato(
          icono: Icons.badge_outlined,
          etiqueta: 'Apellido',
          valor: perfil.apellido,
        ),
        _FilaDato(
          icono: Icons.phone_outlined,
          etiqueta: 'Teléfono',
          valor: perfil.telefono,
        ),
        _FilaDato(
          icono: Icons.cake_outlined,
          etiqueta: 'Fecha de nacimiento',
          valor: perfil.fechaNacimiento == null
              ? ''
              : formatearFechaAnioMesDia(perfil.fechaNacimiento!),
        ),
        _FilaDato(
          icono: Icons.public_outlined,
          etiqueta: 'Nacionalidad',
          valor: perfil.nacionalidad,
        ),
        _FilaDato(
          icono: Icons.email_outlined,
          etiqueta: 'Correo',
          valor: perfil.correo,
        ),

        const SizedBox(height: 20),

        FilledButton.icon(
          onPressed: () => _editarPerfil(context, perfil),
          icon: const Icon(Icons.edit_outlined),
          label: const Text(
            'Actualizar datos',
          ),
        ),
      ],
    );
  }
}

/// Fila que muestra un dato del perfil con su etiqueta e icono.
class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icono,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Un dato vacío se muestra como un guion para que la fila no
                // quede sin contenido.
                Text(
                  valor.isEmpty ? '—' : valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
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

/// Aviso que se muestra cuando el perfil no se pudo cargar.
class _MensajeDeError extends StatelessWidget {
  const _MensajeDeError({
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFD97706),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/modo_usuario.dart';
import '../theme/app_theme.dart';
import 'main_navigation_view.dart';

/// Pantalla de inicio que se muestra al abrir la sesión.
///
/// Pide elegir con qué modo se va a usar la aplicación. El modo viajero lleva
/// a la navegación principal, donde se registran y consultan los viajes; el
/// modo remitente queda a la espera de su módulo.
class SeleccionModoView extends StatefulWidget {
  const SeleccionModoView({
    super.key,
    required this.authController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  State<SeleccionModoView> createState() => _SeleccionModoViewState();
}

class _SeleccionModoViewState extends State<SeleccionModoView> {
  /// Modo marcado en la lista, o nulo mientras no se elige ninguno.
  ///
  /// Se guarda en la vista porque es la selección de esta pantalla, igual que
  /// el contenido de un campo de formulario.
  ModoUsuario? _modoSeleccionado;

  /// Marca el modo pulsado.
  void _seleccionar(ModoUsuario modo) {
    setState(() {
      _modoSeleccionado = modo;
    });
  }

  /// Entra a la aplicación con el modo elegido.
  void _continuar() {
    final modo = _modoSeleccionado;

    if (modo == null) {
      return;
    }

    // El módulo de remitente todavía no existe, así que este modo no lleva a
    // ninguna pantalla.
    if (modo == ModoUsuario.remitente) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationView(
          authController: widget.authController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          const _Encabezado(),

          // El resto de la pantalla es una hoja blanca con las opciones.
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '¿Cómo usarás Lapticon?',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Selecciona qué quieres hacer hoy.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 22),

                      _TarjetaModo(
                        modo: ModoUsuario.remitente,
                        icono: Icons.inventory_2_outlined,
                        seleccionado:
                            _modoSeleccionado == ModoUsuario.remitente,
                        onTap: () => _seleccionar(ModoUsuario.remitente),
                      ),

                      const SizedBox(height: 14),

                      _TarjetaModo(
                        modo: ModoUsuario.viajero,
                        icono: Icons.send_outlined,
                        seleccionado:
                            _modoSeleccionado == ModoUsuario.viajero,
                        onTap: () => _seleccionar(ModoUsuario.viajero),
                      ),

                      const SizedBox(height: 26),

                      // El botón se habilita solo cuando ya hay un modo
                      // marcado.
                      FilledButton(
                        onPressed:
                            _modoSeleccionado == null ? null : _continuar,
                        child: const Text('Continuar'),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Selecciona un modo para ver sus funciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Franja superior con la marca y el mensaje de bienvenida.
class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF163A69),
            Color(0xFF2F80ED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Avión decorativo que asoma por el borde derecho.
            const Positioned(
              right: -18,
              top: 10,
              child: Icon(
                Icons.flight_takeoff_rounded,
                size: 110,
                color: Color(0x26FFFFFF),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marca de la aplicación.
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.flight_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lapticon',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Viaja y conecta',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE7EEF8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Conecta tus destinos.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Envía encomiendas o viaja con ellas.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE7EEF8),
                      height: 1.4,
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

/// Opción seleccionable con el nombre y la descripción de un modo.
class _TarjetaModo extends StatelessWidget {
  const _TarjetaModo({
    required this.modo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  /// Modo que representa la tarjeta.
  final ModoUsuario modo;

  /// Icono que lo acompaña.
  final IconData icono;

  /// Indica si es el modo marcado en este momento.
  final bool seleccionado;

  /// Acción que marca este modo.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      // La tarjeta marcada se resalta con fondo y borde azules.
      color: seleccionado ? const Color(0xFFEFF5FF) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado
                  ? AppTheme.secondary
                  : const Color(0xFFEAECF0),
              width: seleccionado ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icono,
                  color: AppTheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modo.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modo.descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Marcador(seleccionado: seleccionado),
            ],
          ),
        ),
      ),
    );
  }
}

/// Círculo que indica cuál es la opción marcada.
///
/// Se dibuja a mano, en lugar de usar un `Radio`, porque toda la tarjeta ya
/// responde al toque y así basta con un indicador visual.
class _Marcador extends StatelessWidget {
  const _Marcador({
    required this.seleccionado,
  });

  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: seleccionado
              ? AppTheme.secondary
              : const Color(0xFFD0D5DD),
          width: 2,
        ),
      ),
      child: seleccionado
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary,
                ),
              ),
            )
          : null,
    );
  }
}

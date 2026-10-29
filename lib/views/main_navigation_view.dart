import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/viajes_controller.dart';
import '../models/viaje.dart';
import '../theme/app_theme.dart';
import 'home_view.dart';
import 'mis_viajes_view.dart';
import 'perfil_view.dart';
import 'registrar_viaje_view.dart';

/// Contenedor de la aplicación una vez iniciada la sesión.
///
/// Mantiene la barra inferior y las tres pestañas, y es la dueña del
/// [ViajesController] que inicio y viajes comparten.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({
    super.key,
    required this.authController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  State<MainNavigationView> createState() =>
      _MainNavigationViewState();
}

class _MainNavigationViewState
    extends State<MainNavigationView> {
  /// Pestaña visible actualmente. Es estado de navegación, propio de la vista.
  int _indiceSeleccionado = 0;

  /// Controlador de los viajes registrados. Se crea en este nivel porque las
  /// pestañas de inicio y de viajes leen la misma lista.
  final ViajesController _viajesController =
      ViajesController();

  @override
  void dispose() {
    _viajesController.dispose();
    super.dispose();
  }

  /// Abre el formulario de viaje y agrega al controlador el viaje devuelto.
  Future<void> _registrarViaje() async {
    final nuevoViaje = await Navigator.push<Viaje>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegistrarViajeView(),
      ),
    );

    // El resultado es nulo cuando el formulario se cierra sin registrar nada.
    if (nuevoViaje == null) {
      return;
    }

    _viajesController.agregar(nuevoViaje);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Viaje registrado correctamente',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Cambia a la pestaña de viajes.
  void _irAViajes() {
    setState(() {
      _indiceSeleccionado = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El ListenableBuilder redibuja las pestañas cuando la lista de viajes
      // cambia, de modo que el contador de inicio y el listado quedan al día.
      body: ListenableBuilder(
        listenable: _viajesController,
        builder: (context, _) {
          // IndexedStack conserva el estado de cada pestaña al cambiar entre
          // ellas, en lugar de reconstruirlas desde cero.
          return IndexedStack(
            index: _indiceSeleccionado,
            children: [
              HomeView(
                cantidadViajes:
                    _viajesController.cantidad,
                onRegistrarViaje: _registrarViaje,
                onVerViajes: _irAViajes,
              ),
              MisViajesView(
                viajes: _viajesController.viajes,
                onRegistrarViaje: _registrarViaje,
              ),
              PerfilView(
                authController: widget.authController,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6EFFF),
        elevation: 4,
        height: 72,
        onDestinationSelected: (index) {
          setState(() {
            _indiceSeleccionado = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppTheme.primary,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.flight_outlined,
            ),
            selectedIcon: Icon(
              Icons.flight_rounded,
              color: AppTheme.primary,
            ),
            label: 'Viajes',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

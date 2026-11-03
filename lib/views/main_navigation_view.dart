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

  /// Pestaña visible actualmente.
  int _indiceSeleccionado = 0;

  /// Controlador de viajes.
  final ViajesController _viajesController =
      ViajesController();

  @override
  void initState() {
    super.initState();
    _cargarViajes();
  }

  Future<void> _cargarViajes() async {
    final usuario =
        widget.authController.usuario;

    if (usuario == null) {
      return;
    }

    await _viajesController.cargarViajes(
      idToken: usuario.idToken,
    );
  }

  /// Abre el formulario de viaje y agrega al controlador el viaje devuelto.
  Future<void> _registrarViaje() async {
  final usuario =
      widget.authController.usuario;

  if (usuario == null) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Debes iniciar sesión para registrar un viaje.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

    return;
  }

  final nuevoViaje =
      await Navigator.push<Viaje>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          RegistrarViajeView(
        idToken: usuario.idToken,
      ),
    ),
  );

  if (nuevoViaje == null) {
    return;
  }

  _viajesController.agregar(
    nuevoViaje,
  );

  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: const Text(
        'Viaje registrado correctamente',
      ),
      behavior:
          SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),
  );
}


Future<void> _completarViaje(
  Viaje viaje,
) async {
  final usuario =
      widget.authController.usuario;  

  if (usuario == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Debes iniciar sesión.',
        ),
      ),
    );

    return;
  }

  final confirmado =
      await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:
            const Text('Completar viaje'),
        content: Text(
          '¿Deseas marcar el viaje ${viaje.numeroVuelo} como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child:
                const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child:
                const Text('Completar'),
          ),
        ],
      );
    },
  );

  if (confirmado != true) {
    return;
  }

  final resultado =
      await _viajesController
          .completarViaje(
    viaje: viaje,
    idToken: usuario.idToken,
  );

  if (!mounted) {
    return;
  }

  if (!resultado) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          _viajesController.error ??
              'No fue posible completar el viaje.',
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        'Viaje marcado como completado',
      ),
      behavior:
          SnackBarBehavior.floating,
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
                onCompletarViaje: _completarViaje,
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

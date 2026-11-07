import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/perfil_controller.dart';
import '../controllers/viajes_controller.dart';
import '../models/encomienda.dart';
import '../models/modo_usuario.dart';
import '../models/viaje.dart';
import '../theme/app_theme.dart';
import 'home_view.dart';
import 'inicio_remitente_view.dart';
import 'mis_viajes_view.dart';
import 'perfil_view.dart';
import 'registrar_encomienda_view.dart';
import 'registrar_viaje_view.dart';
import 'seleccion_modo_view.dart';

/// Contenedor de la aplicación una vez iniciada la sesión.
///
/// Mantiene la función elegida, la barra inferior y los controladores que
/// comparten las pestañas.
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

  ModoUsuario? _modoSeleccionado;
  bool _eligiendoFuncion = true;
  bool _viajesSolicitados = false;

  /// Pestaña visible actualmente.
  int _indiceSeleccionado = 0;

  /// Controlador de viajes.
  final ViajesController _viajesController =
      ViajesController();

  /// Controlador del perfil. Se crea en este nivel para que la pestaña de
  /// perfil conserve los datos al cambiar de pestaña.
  final PerfilController _perfilController =
      PerfilController();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _viajesController.dispose();
    _perfilController.dispose();
    super.dispose();
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

  /// Consulta los datos personales del usuario autenticado.
  Future<void> _cargarPerfil() async {
    final usuario =
        widget.authController.usuario;

    if (usuario == null) {
      return;
    }

    await _perfilController.cargarPerfil(
      uid: usuario.uid,
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

  /// Abre el formulario de encomienda y avisa del resultado del registro.
  Future<void> _publicarEncomienda() async {
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      _mostrarAviso(
        'Debes iniciar sesión para publicar una encomienda.',
      );

      return;
    }

    final nuevaEncomienda =
        await Navigator.push<Encomienda>(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrarEncomiendaView(
          idToken: usuario.idToken,
        ),
      ),
    );

    if (nuevaEncomienda == null || !mounted) {
      return;
    }

    _mostrarAviso(
      'Encomienda publicada correctamente',
    );
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Cambia a la pestaña de viajes.
  void _irAViajes() {
    setState(() {
      _indiceSeleccionado = 1;
    });
  }

  void _continuarConFuncion() {
    setState(() {
      _eligiendoFuncion = false;
      _indiceSeleccionado = 0;
    });

    if (_modoSeleccionado == ModoUsuario.viajero && !_viajesSolicitados) {
      _viajesSolicitados = true;
      _cargarViajes();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eligiendoFuncion) {
      return SeleccionModoView(
        modoSeleccionado: _modoSeleccionado,
        onSeleccionar: (modo) => setState(() => _modoSeleccionado = modo),
        onContinuar: _continuarConFuncion,
      );
    }

    final esViajero = _modoSeleccionado == ModoUsuario.viajero;

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
              if (esViajero) ...[
                HomeView(
                  cantidadViajes: _viajesController.cantidad,
                  onRegistrarViaje: _registrarViaje,
                  onVerViajes: _irAViajes,
                ),
                MisViajesView(
                  viajes: _viajesController.viajes,
                  onRegistrarViaje: _registrarViaje,
                  onCompletarViaje: _completarViaje,
                ),
              ] else
                InicioRemitenteView(
                  onPublicarEncomienda: _publicarEncomienda,
                  onVerEncomiendas: () => _mostrarAviso(
                    'Mis encomiendas estará disponible próximamente.',
                  ),
                  onBuscarViajeros: () => _mostrarAviso(
                    'La búsqueda de viajeros estará disponible próximamente.',
                  ),
                ),
              PerfilView(
                authController: widget.authController,
                perfilController: _perfilController,
                onCambiarFuncion: () => setState(() {
                  _modoSeleccionado = null;
                  _eligiendoFuncion = true;
                }),
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
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppTheme.primary,
            ),
            label: 'Inicio',
          ),
          if (esViajero)
            const NavigationDestination(
              icon: Icon(Icons.flight_outlined),
              selectedIcon: Icon(
                Icons.flight_rounded,
                color: AppTheme.primary,
              ),
              label: 'Viajes',
            ),
          const NavigationDestination(
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

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/encomiendas_controller.dart';
import '../controllers/perfil_controller.dart';
import '../controllers/viajes_controller.dart';
import '../models/encomienda.dart';
import '../models/modo_usuario.dart';
import '../models/viaje.dart';
import '../theme/app_theme.dart';
import 'buscar_viajeros_view.dart';
import 'encomiendas_tomadas_view.dart';
import 'home_view.dart';
import 'inicio_remitente_view.dart';
import 'mis_encomiendas_view.dart';
import 'mis_viajes_view.dart';
import 'perfil_view.dart';
import 'registrar_encomienda_view.dart';
import 'registrar_viaje_view.dart';
import 'seguimiento_encomienda_view.dart';
import 'seleccion_modo_view.dart';

/// Contenedor de la aplicación una vez iniciada la sesión.
///
/// Mantiene la función elegida, la barra inferior y los controladores que
/// comparten las pestañas.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key, required this.authController});

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  ModoUsuario? _modoSeleccionado;
  bool _eligiendoFuncion = true;
  bool _viajesSolicitados = false;
  bool _encomiendasSolicitadas = false;

  /// Pestaña visible actualmente.
  int _indiceSeleccionado = 0;

  /// Controlador de viajes.
  final ViajesController _viajesController = ViajesController();

  /// Controlador de las encomiendas publicadas como remitente.
  final EncomiendasController _encomiendasController = EncomiendasController();

  /// Controlador del perfil. Se crea en este nivel para que la pestaña de
  /// perfil conserve los datos al cambiar de pestaña.
  final PerfilController _perfilController = PerfilController();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _viajesController.dispose();
    _encomiendasController.dispose();
    _perfilController.dispose();
    super.dispose();
  }

  Future<void> _cargarEncomiendas() async {
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      return;
    }

    await _encomiendasController.cargarEncomiendas(idToken: usuario.idToken);
  }

  Future<void> _cargarViajes() async {
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      return;
    }

    await _viajesController.cargarViajes(idToken: usuario.idToken);
  }

  /// Consulta los datos personales del usuario autenticado.
  Future<void> _cargarPerfil() async {
    final usuario = widget.authController.usuario;

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
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      _mostrarAviso('Debes iniciar sesión para registrar un viaje.');
      return;
    }

    final nuevoViaje = await Navigator.push<Viaje>(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrarViajeView(idToken: usuario.idToken),
      ),
    );

    if (nuevoViaje == null || !mounted) {
      return;
    }

    _viajesController.agregar(nuevoViaje);
    _mostrarAviso(
      'Viaje registrado correctamente',
      forma: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> _completarViaje(Viaje viaje) async {
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      _mostrarAviso('Debes iniciar sesión.');
      return;
    }

    final confirmado = await _confirmarCompletarViaje(viaje);
    if (confirmado != true || !mounted) {
      return;
    }

    final resultado = await _viajesController.completarViaje(
      viaje: viaje,
      idToken: usuario.idToken,
    );

    _mostrarAviso(
      resultado
          ? 'Viaje marcado como completado'
          : _viajesController.error ?? 'No fue posible completar el viaje.',
    );
  }

  Future<bool?> _confirmarCompletarViaje(Viaje viaje) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar viaje'),
        content: Text(
          '¿Deseas marcar el viaje ${viaje.numeroVuelo} como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  /// Abre el formulario de encomienda y avisa del resultado del registro.
  Future<void> _publicarEncomienda() async {
    final usuario = widget.authController.usuario;

    if (usuario == null) {
      _mostrarAviso('Debes iniciar sesión para publicar una encomienda.');

      return;
    }

    final nuevaEncomienda = await Navigator.push<Encomienda>(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrarEncomiendaView(idToken: usuario.idToken),
      ),
    );

    if (nuevaEncomienda == null || !mounted) {
      return;
    }

    _encomiendasController.agregar(nuevaEncomienda);

    _mostrarAviso('Encomienda publicada correctamente');
  }

  /// Abre el detalle de seguimiento, que el remitente solo consulta.
  void _verSeguimiento(Encomienda encomienda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeguimientoEncomiendaView(encomienda: encomienda),
      ),
    );
  }

  /// Abre la búsqueda de viajeros para el remitente.
  void _buscarViajeros() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const BuscarViajerosView()),
    );
  }

  void _verEncomiendasTomadas() {
    final usuario = widget.authController.usuario;
    if (usuario == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncomiendasTomadasView(idToken: usuario.idToken),
      ),
    );
  }

  void _seleccionarPestana(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  void _mostrarAviso(String mensaje, {ShapeBorder? forma}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: forma,
      ),
    );
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

    if (_modoSeleccionado == ModoUsuario.remitente &&
        !_encomiendasSolicitadas) {
      _encomiendasSolicitadas = true;
      _cargarEncomiendas();
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
        listenable: Listenable.merge([
          _viajesController,
          _encomiendasController,
        ]),
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
                  onVerViajes: () => _seleccionarPestana(1),
                  onVerEncomiendasTomadas: _verEncomiendasTomadas,
                ),
                MisViajesView(
                  viajes: _viajesController.viajes,
                  onRegistrarViaje: _registrarViaje,
                  onCompletarViaje: _completarViaje,
                ),
              ] else ...[
                InicioRemitenteView(
                  onPublicarEncomienda: _publicarEncomienda,
                  onVerEncomiendas: () => _seleccionarPestana(1),
                  onBuscarViajeros: _buscarViajeros,
                ),
                MisEncomiendasView(
                  encomiendas: _encomiendasController.encomiendas,
                  cargando: _encomiendasController.cargando,
                  error: _encomiendasController.error,
                  onPublicarEncomienda: _publicarEncomienda,
                  onVerSeguimiento: _verSeguimiento,
                  onRecargar: _cargarEncomiendas,
                ),
              ],
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
        onDestinationSelected: _seleccionarPestana,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
            label: 'Inicio',
          ),
          if (esViajero)
            const NavigationDestination(
              icon: Icon(Icons.flight_outlined),
              selectedIcon: Icon(Icons.flight_rounded, color: AppTheme.primary),
              label: 'Viajes',
            )
          else
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.primary,
              ),
              label: 'Envíos',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

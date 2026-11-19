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
import 'buscar_encomiendas_view.dart';
import 'home_view.dart';
import 'inicio_remitente_view.dart';
import 'mis_encomiendas_view.dart';
import 'mis_viajes_view.dart';
import 'perfil_view.dart';
import 'registrar_encomienda_view.dart';
import 'registrar_viaje_view.dart';
import 'seguimiento_encomienda_view.dart';
import 'seleccion_modo_view.dart';
import 'widgets/dialogo_confirmacion.dart';
import 'widgets/estilo_modo.dart';

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
  ModoUsuario? _modoActivo;
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
    return mostrarDialogoConfirmacion(
      context,
      titulo: 'Completar viaje',
      mensaje: '¿Deseas marcar el viaje ${viaje.numeroVuelo} como completado?',
      accion: 'Completar',
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

  void _buscarEncomiendasDisponibles() {
    final usuario = widget.authController.usuario;
    if (usuario == null) {
      _mostrarAviso('Debes iniciar sesión para buscar encomiendas.');
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => BuscarEncomiendasView(idToken: usuario.idToken),
      ),
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

  void _activarModo(ModoUsuario modo) {
    if (_modoActivo == modo) return;

    setState(() {
      _modoActivo = modo;
      _modoSeleccionado = null;
      _indiceSeleccionado = 0;
    });

    if (modo == ModoUsuario.viajero && !_viajesSolicitados) {
      _viajesSolicitados = true;
      _cargarViajes();
    }

    if (modo == ModoUsuario.remitente && !_encomiendasSolicitadas) {
      _encomiendasSolicitadas = true;
      _cargarEncomiendas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final modo = _modoActivo;
    if (modo == null) {
      return SeleccionModoView(
        modoSeleccionado: _modoSeleccionado,
        onSeleccionar: (modo) => setState(() => _modoSeleccionado = modo),
        onContinuar: () {
          if (_modoSeleccionado case final elegido?) _activarModo(elegido);
        },
        onCerrarSesion: widget.authController.cerrarSesion,
      );
    }

    return LayoutBuilder(
      builder: (context, restricciones) => _pantallaPrincipal(
        modo,
        _CabeceraPrincipal.necesitaSegundaFila(context, restricciones.maxWidth),
      ),
    );
  }

  Widget _pantallaPrincipal(ModoUsuario modo, bool cabeceraCompacta) {
    final esViajero = modo == ModoUsuario.viajero;

    return Scaffold(
      appBar: _CabeceraPrincipal(
        modo: modo,
        onCambiarModo: _activarModo,
        compacta: cabeceraCompacta,
      ),
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
                  onRegistrarViaje: _registrarViaje,
                  onVerEncomiendasTomadas: _verEncomiendasTomadas,
                  onBuscarEncomiendas: _buscarEncomiendasDisponibles,
                ),
                MisViajesView(
                  viajes: _viajesController.viajes,
                  onRegistrarViaje: _registrarViaje,
                  onCompletarViaje: _completarViaje,
                ),
              ] else ...[
                InicioRemitenteView(
                  onPublicarEncomienda: _publicarEncomienda,
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
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        backgroundColor: Colors.white,
        indicatorColor: modo.fondo,
        elevation: 1,
        height: 68,
        onDestinationSelected: _seleccionarPestana,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: modo.acento),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(modo.icono),
            selectedIcon: Icon(modo.icono, color: modo.acento),
            label: esViajero ? 'Mis viajes' : 'Mis encomiendas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: modo.acento),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _CabeceraPrincipal extends StatelessWidget
    implements PreferredSizeWidget {
  const _CabeceraPrincipal({
    required this.modo,
    required this.onCambiarModo,
    required this.compacta,
  });

  static const double _altoBarra = 60;
  static const double _altoSelector = 52;
  static const double _margen = 16;
  static const double _anchoLogo = 34;
  static const double _separacionMarca = 8;
  static const double _rellenoOpcion = 9;
  static const double _tamIconoRol = 16;
  static const double _separacionRol = 6;
  static const _estiloMarca = TextStyle(
    color: AppTheme.primary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const _estiloRol = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  final ModoUsuario modo;
  final ValueChanged<ModoUsuario> onCambiarModo;
  final bool compacta;

  static bool necesitaSegundaFila(BuildContext context, double ancho) {
    double medir(String texto, TextStyle estilo) => TextPainter.computeWidth(
      text: TextSpan(text: texto, style: estilo),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );

    final anchoMarca =
        _anchoLogo + _separacionMarca + medir('Lapticon', _estiloMarca);
    final anchoEtiqueta = ModoUsuario.values
        .map((rol) => medir(rol.titulo, _estiloRol))
        .reduce((a, b) => a > b ? a : b);
    final anchoOpcion =
        anchoEtiqueta + _tamIconoRol + _separacionRol + 2 * _rellenoOpcion;
    return ancho <
        anchoMarca + anchoOpcion * ModoUsuario.values.length + 3 * _margen;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(_altoBarra + (compacta ? _altoSelector : 0));

  @override
  Widget build(BuildContext context) {
    final selector = SegmentedButton<ModoUsuario>(
      segments: [
        for (final opcion in ModoUsuario.values)
          ButtonSegment(
            value: opcion,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: _separacionRol,
              children: [
                Icon(opcion.icono, size: _tamIconoRol),
                Flexible(child: Text(opcion.titulo)),
              ],
            ),
          ),
      ],
      selected: {modo},
      onSelectionChanged: (seleccion) => onCambiarModo(seleccion.single),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        backgroundColor: const Color(0xFFF0F4F9),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: modo.acento,
        side: BorderSide.none,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: _rellenoOpcion),
        textStyle: _estiloRol,
      ),
    );

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shape: const Border(bottom: BorderSide(color: Color(0xFFE4E7EC))),
      toolbarHeight: _altoBarra,
      titleSpacing: _margen,
      title: Row(
        children: [
          Container(
            width: _anchoLogo,
            height: _anchoLogo,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flight_rounded,
              size: 21,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: _separacionMarca),
          const Flexible(
            child: Text(
              'Lapticon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _estiloMarca,
            ),
          ),
        ],
      ),
      actions: compacta
          ? null
          : [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: _margen),
                child: Center(widthFactor: 1, child: selector),
              ),
            ],
      bottom: compacta
          ? PreferredSize(
              preferredSize: const Size.fromHeight(_altoSelector),
              child: SizedBox(
                height: _altoSelector,
                child: Center(child: selector),
              ),
            )
          : null,
    );
  }
}

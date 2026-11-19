import 'package:flutter/material.dart';

import '../controllers/registrar_viaje_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formato_fecha.dart';
import 'widgets/busqueda_por_ruta.dart';
import 'widgets/campos_formulario.dart';

/// Formulario de registro de un viaje.
///
/// Recibe el ID Token de Firebase para poder registrar el viaje
/// mediante el endpoint protegido del backend.
class RegistrarViajeView extends StatefulWidget {
  const RegistrarViajeView({super.key, required this.idToken});

  /// Token de Firebase del usuario autenticado.
  final String idToken;

  @override
  State<RegistrarViajeView> createState() => _RegistrarViajeViewState();
}

class _RegistrarViajeViewState extends State<RegistrarViajeView> {
  /// Llave utilizada para ejecutar las validaciones del formulario.
  final _formKey = GlobalKey<FormState>();

  /// Controlador del campo número de vuelo.
  final _numeroVueloController = TextEditingController();

  /// Controlador MVC del registro de viajes.
  final RegistrarViajeController _controller = RegistrarViajeController();

  @override
  void initState() {
    super.initState();
    _controller.cargarCiudades();
  }

  @override
  void dispose() {
    _numeroVueloController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Abre el calendario para seleccionar la fecha del viaje.
  Future<void> _seleccionarFecha() async {
    final fechaElegida = await showDatePicker(
      context: context,
      initialDate: _controller.fecha ?? _controller.fechaMinima,
      firstDate: _controller.fechaMinima,
      lastDate: _controller.fechaMaxima,
    );

    if (fechaElegida == null) {
      return;
    }

    _controller.seleccionarFecha(fechaElegida);
  }

  /// Valida el formulario y registra el viaje realmente
  /// en el backend de Lapticon.
  Future<void> _guardarViaje() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final problema = _controller.validarSeleccion();

    if (problema != null) {
      _mostrarAviso(problema);
      return;
    }

    final viaje = await _controller.registrarViaje(
      numeroVuelo: _numeroVueloController.text,
      idToken: widget.idToken,
    );

    if (!mounted) {
      return;
    }

    if (viaje == null) {
      _mostrarAviso(_controller.error ?? 'No fue posible registrar el viaje.');
      return;
    }

    /// Devuelve a MainNavigationView el viaje que realmente
    /// creó el backend.
    Navigator.pop(context, viaje);
  }

  /// Muestra errores o validaciones al usuario.
  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar viaje',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Encabezado.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.flight_takeoff, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuevo viaje',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa la información de tu vuelo.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// Número de vuelo.
              const Text(
                'Número de vuelo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _numeroVueloController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: AA123',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: _controller.validarNumeroVuelo,
              ),

              const SizedBox(height: 22),

              /// Los campos dependientes del controlador
              /// se actualizan cuando ChangeNotifier llama
              /// a notifyListeners().
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_controller.cargandoCiudades)
                        const Center(child: CircularProgressIndicator())
                      else if (_controller.errorCiudades case final mensaje?)
                        ErrorCatalogoCiudades(
                          mensaje: mensaje,
                          onReintentar: _controller.cargarCiudades,
                        )
                      else ...[
                        SelectorCiudad(
                          etiqueta: 'Ciudad de origen',
                          icono: Icons.flight_takeoff,
                          ciudades: _controller.ciudades,
                          seleccionar: _controller.seleccionarOrigen,
                          validar: _controller.validarOrigen,
                        ),
                        const SizedBox(height: 22),
                        SelectorCiudad(
                          etiqueta: 'Ciudad de destino',
                          icono: Icons.flight_land,
                          ciudades: _controller.ciudades,
                          seleccionar: _controller.seleccionarDestino,
                          validar: _controller.validarDestino,
                        ),
                      ],

                      const SizedBox(height: 22),

                      SelectorFecha(
                        etiqueta: 'Fecha del viaje',
                        fecha: _controller.fecha,
                        onTap: _seleccionarFecha,
                        formatearFecha: formatearFechaVisible,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              /// Este ListenableBuilder controla el estado
              /// de carga mientras se espera al backend.
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _controller.cargando ? null : _guardarViaje,
                      icon: _controller.cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.flight_takeoff),
                      label: Text(
                        _controller.cargando
                            ? 'Registrando...'
                            : 'Registrar viaje',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

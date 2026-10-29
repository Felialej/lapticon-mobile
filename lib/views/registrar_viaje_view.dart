import 'package:flutter/material.dart';

import '../controllers/registrar_viaje_controller.dart';
import '../models/viaje.dart';
import '../theme/app_theme.dart';
import '../utils/formato_fecha.dart';

/// Formulario de registro de un viaje.
///
/// Se abre como pantalla propia y devuelve el [Viaje] construido al cerrarse,
/// de modo que quien la abrió decide qué hacer con él.
class RegistrarViajeView extends StatefulWidget {
  const RegistrarViajeView({super.key});

  @override
  State<RegistrarViajeView> createState() =>
      _RegistrarViajeViewState();
}

class _RegistrarViajeViewState
    extends State<RegistrarViajeView> {
  /// Llave del formulario, necesaria para disparar los validadores.
  final _formKey = GlobalKey<FormState>();

  /// Controlador del campo de número de vuelo.
  final _numeroVueloController = TextEditingController();

  /// Controlador del formulario. Se crea aquí porque su información solo tiene
  /// sentido mientras esta pantalla está abierta.
  final RegistrarViajeController _controller =
      RegistrarViajeController();

  @override
  void dispose() {
    _numeroVueloController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Abre el calendario y entrega la fecha elegida al controlador.
  ///
  /// El calendario se queda en la vista porque necesita el contexto de la
  /// interfaz; los límites de fechas los define el controlador.
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

  /// Valida el formulario y devuelve el viaje a la pantalla anterior.
  void _guardarViaje() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Reglas que no pertenecen a un campo concreto: fecha elegida y ciudades
    // distintas entre sí.
    final problema = _controller.validarSeleccion();

    if (problema != null) {
      _mostrarAviso(problema);
      return;
    }

    final viaje = _controller.construirViaje(
      _numeroVueloController.text,
    );

    Navigator.pop(context, viaje);
  }

  /// Muestra un aviso con el problema detectado en el formulario.
  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar viaje',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado descriptivo del formulario.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primary,
                      child: Icon(
                        Icons.flight_takeoff,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuevo viaje',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa la información de tu vuelo.',
                            style: TextStyle(
                              color: AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Número de vuelo. Se escribe en mayúsculas porque es el formato
              // con el que se identifican los vuelos.
              const Text(
                'Número de vuelo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _numeroVueloController,
                textCapitalization:
                    TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: AA123',
                  prefixIcon: Icon(
                    Icons.confirmation_number_outlined,
                  ),
                ),
                validator: _controller.validarNumeroVuelo,
              ),

              const SizedBox(height: 22),

              // Selectores de ruta y calendario. El ListenableBuilder los
              // redibuja cuando el controlador registra una nueva selección.
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ciudad de origen',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: _controller.origen,
                        decoration:
                            const InputDecoration(
                          hintText:
                              'Selecciona el origen',
                          prefixIcon: Icon(
                            Icons.flight_takeoff,
                          ),
                        ),
                        items: _opcionesDeCiudad(),
                        onChanged:
                            _controller.seleccionarOrigen,
                        validator:
                            _controller.validarCiudad,
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Ciudad de destino',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: _controller.destino,
                        decoration:
                            const InputDecoration(
                          hintText:
                              'Selecciona el destino',
                          prefixIcon: Icon(
                            Icons.flight_land,
                          ),
                        ),
                        items: _opcionesDeCiudad(),
                        onChanged: _controller
                            .seleccionarDestino,
                        validator:
                            _controller.validarCiudad,
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Fecha del viaje',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _SelectorFecha(
                        fecha: _controller.fecha,
                        onTap: _seleccionarFecha,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _guardarViaje,
                icon: const Icon(Icons.flight_takeoff),
                label: const Text(
                  'Registrar viaje',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye las opciones de los dos selectores de ciudad.
  List<DropdownMenuItem<String>> _opcionesDeCiudad() {
    return RegistrarViajeController.ciudadesDisponibles
        .map(
          (ciudad) => DropdownMenuItem(
            value: ciudad,
            child: Text(ciudad),
          ),
        )
        .toList();
  }
}

/// Campo con apariencia de selector que abre el calendario al pulsarlo.
class _SelectorFecha extends StatelessWidget {
  const _SelectorFecha({
    required this.fecha,
    required this.onTap,
  });

  /// Fecha elegida, o nulo mientras no se elige ninguna.
  final DateTime? fecha;

  /// Acción que abre el calendario.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sinFecha = fecha == null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  sinFecha
                      ? 'Seleccionar fecha'
                      : formatearFechaVisible(fecha!),
                  style: TextStyle(
                    color: sinFecha
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

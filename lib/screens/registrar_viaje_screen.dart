import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../theme/app_theme.dart';

class RegistrarViajeScreen extends StatefulWidget {
  const RegistrarViajeScreen({super.key});

  @override
  State<RegistrarViajeScreen> createState() =>
      _RegistrarViajeScreenState();
}

class _RegistrarViajeScreenState
    extends State<RegistrarViajeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroVueloController = TextEditingController();

  final List<String> _ciudades = [
    'Bogota',
    'Medellin',
    'Cali',
    'Madrid',
    'Paris',
    'Miami',
  ];

  String? _origen;
  String? _destino;
  DateTime? _fecha;

  @override
  void dispose() {
    _numeroVueloController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: ahora,
      lastDate: DateTime(ahora.year + 2),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fecha = fechaSeleccionada;
      });
    }
  }

  void _guardarViaje() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona la fecha del viaje',
          ),
        ),
      );
      return;
    }

    if (_origen == _destino) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Origen y destino deben ser diferentes',
          ),
        ),
      );
      return;
    }

    final nuevoViaje = Viaje(
      numeroVuelo:
          _numeroVueloController.text.trim().toUpperCase(),
      ciudadOrigen: _origen!,
      ciudadDestino: _destino!,
      fechaViaje: _fecha!,
    );

    Navigator.pop(context, nuevoViaje);
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
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
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa la información de tu vuelo.',
                            style: TextStyle(
                              color:
                                  AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

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
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ingresa el número de vuelo';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'Ciudad de origen',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Selecciona el origen',
                  prefixIcon:
                      Icon(Icons.flight_takeoff),
                ),
                items: _ciudades
                    .map(
                      (ciudad) => DropdownMenuItem(
                        value: ciudad,
                        child: Text(ciudad),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _origen = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una ciudad';
                  }
                  return null;
                },
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
                decoration: const InputDecoration(
                  hintText: 'Selecciona el destino',
                  prefixIcon: Icon(Icons.flight_land),
                ),
                items: _ciudades
                    .map(
                      (ciudad) => DropdownMenuItem(
                        value: ciudad,
                        child: Text(ciudad),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _destino = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una ciudad';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'Fecha del viaje',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _seleccionarFecha,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE4E7EC),
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
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
                            _fecha == null
                                ? 'Seleccionar fecha'
                                : _formatearFecha(
                                    _fecha!,
                                  ),
                            style: TextStyle(
                              color: _fecha == null
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
}
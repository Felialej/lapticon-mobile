import 'package:flutter/material.dart';

import '../controllers/encomiendas_tomadas_controller.dart';
import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import '../utils/telefono_simulado.dart';
import 'widgets/dialogo_confirmacion.dart';
import 'widgets/etiqueta_estado.dart';

class ContactoRemitenteView extends StatefulWidget {
  const ContactoRemitenteView({
    super.key,
    required this.encomienda,
    required this.controlador,
  });

  final Encomienda encomienda;
  final EncomiendasTomadasController controlador;

  @override
  State<ContactoRemitenteView> createState() => _ContactoRemitenteViewState();
}

class _ContactoRemitenteViewState extends State<ContactoRemitenteView> {
  final _telefono = generarTelefonoSimulado();
  bool _confirmando = false;

  Future<void> _confirmarEntrega() async {
    if (_confirmando) return;
    setState(() => _confirmando = true);

    try {
      final aceptado = await mostrarDialogoConfirmacion(
        context,
        titulo: 'Confirmar entrega',
        mensaje:
            '¿Confirmas que entregaste la encomienda? '
            'Su estado se actualizará a recibida.',
        accion: 'Sí, confirmar entrega',
      );
      if (!mounted || aceptado != true) return;

      final exito = await widget.controlador.confirmarEntrega(
        widget.encomienda,
      );
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (exito) {
        Navigator.of(context).pop(true);
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              widget.controlador.errorEntrega ??
                  'No fue posible confirmar la entrega.',
            ),
          ),
        );
    } finally {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        setState(() => _confirmando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final encomienda = widget.encomienda;
    final nombre = encomienda.remitenteNombre?.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Contactar al remitente')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del remitente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nombre == null || nombre.isEmpty
                          ? 'Nombre del remitente no disponible'
                          : nombre,
                    ),
                    const SizedBox(height: 16),
                    const Text('Teléfono'),
                    Text(
                      _telefono,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Divider(height: 28),
                    Text(encomienda.ruta),
                    const SizedBox(height: 8),
                    EtiquetaEstado(estado: encomienda.estado),
                  ],
                ),
              ),
            ),
            if (encomienda.estado == EstadoEncomienda.tomada) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _confirmando ? null : _confirmarEntrega,
                child: Text(
                  _confirmando ? 'Confirmando...' : 'Confirmar entrega',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/tomar_encomienda_controller.dart';
import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import 'encomiendas_tomadas_view.dart';
import 'widgets/etiqueta_estado.dart';

/// HU-13: detalle y aceptación de una encomienda disponible.
class DetalleEncomiendaView extends StatefulWidget {
  const DetalleEncomiendaView({
    super.key,
    required this.encomienda,
    required this.idToken,
  });

  final Encomienda encomienda;
  final String idToken;

  @override
  State<DetalleEncomiendaView> createState() => _DetalleEncomiendaViewState();
}

class _DetalleEncomiendaViewState extends State<DetalleEncomiendaView> {
  late final TomarEncomiendaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TomarEncomiendaController(idToken: widget.idToken);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tomar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tomar encomienda'),
        content: Text(
          '¿Deseas aceptar la encomienda de ${widget.encomienda.ruta}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final exito = await _controller.aceptar(widget.encomienda);
    if (!mounted) return;
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encomienda tomada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enc = widget.encomienda;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de encomienda')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                enc.ruta,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              EtiquetaEstado(
                estado: _controller.tomada
                    ? EstadoEncomienda.tomada
                    : enc.estado,
              ),
              const SizedBox(height: 20),
              _dato('Origen', enc.ciudadOrigen),
              _dato('Destino', enc.ciudadDestino),
              _dato('Valor declarado', enc.valorConMoneda),
              _dato('Moneda', enc.moneda),
              _dato(
                'Observaciones',
                enc.observaciones.isEmpty
                    ? 'Sin observaciones'
                    : enc.observaciones,
              ),
              if (_controller.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _controller.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_controller.procesando)
                const Center(child: CircularProgressIndicator())
              else if (_controller.tomada) ...[
                const Text('La asignación fue confirmada por el servidor.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          EncomiendasTomadasView(idToken: widget.idToken),
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Ver encomiendas tomadas'),
                ),
              ] else if (enc.estado == EstadoEncomienda.disponible)
                FilledButton.icon(
                  onPressed: _tomar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Tomar encomienda'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(valor),
      ],
    ),
  );
}

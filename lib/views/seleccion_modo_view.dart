import 'package:flutter/material.dart';

import '../models/modo_usuario.dart';
import 'selector_funcion_view.dart';
import 'widgets/marco_autenticacion.dart';

/// Pantalla para elegir y confirmar cómo usar Lapticon en la sesión actual.
class SeleccionModoView extends StatelessWidget {
  const SeleccionModoView({
    super.key,
    required this.modoSeleccionado,
    required this.onSeleccionar,
    required this.onContinuar,
    required this.onCerrarSesion,
  });

  final ModoUsuario? modoSeleccionado;
  final ValueChanged<ModoUsuario> onSeleccionar;
  final VoidCallback onContinuar;
  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return MarcoAutenticacion(
      titulo: '¿Cómo usarás Lapticon?',
      subtitulo: 'Selecciona qué quieres hacer hoy.',
      separacionTarjeta: 11,
      accionEncabezado: PopupMenuButton<bool>(
        tooltip: 'Opciones de sesión',
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (_) => onCerrarSesion(),
        itemBuilder: (context) => const [
          PopupMenuItem(value: true, child: Text('Cerrar sesión')),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OpcionesFuncion(
            modoSeleccionado: modoSeleccionado,
            onSeleccionar: onSeleccionar,
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: modoSeleccionado == null ? null : onContinuar,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/modo_usuario.dart';
import '../theme/app_theme.dart';
import 'widgets/estilo_modo.dart';

/// Opciones de función accesibles mediante toque o teclado.
class OpcionesFuncion extends StatelessWidget {
  const OpcionesFuncion({
    super.key,
    required this.modoSeleccionado,
    required this.onSeleccionar,
  });

  final ModoUsuario? modoSeleccionado;
  final ValueChanged<ModoUsuario> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<ModoUsuario>(
      groupValue: modoSeleccionado,
      onChanged: (valor) {
        if (valor != null) onSeleccionar(valor);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _opcion(ModoUsuario.remitente),
          const SizedBox(height: 14),
          _opcion(ModoUsuario.viajero),
        ],
      ),
    );
  }

  Widget _opcion(ModoUsuario modo) {
    final seleccionada = modo == modoSeleccionado;
    return RadioListTile<ModoUsuario>(
      value: modo,
      selected: seleccionada,
      activeColor: modo.acento,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      minTileHeight: 139,
      selectedTileColor: modo.fondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: seleccionada
            ? BorderSide(color: modo.acento, width: 1.8)
            : const BorderSide(color: Color(0xFFD8E0EB)),
      ),
      secondary: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: seleccionada ? Colors.white : modo.fondo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(modo.icono, color: modo.acento, size: 29),
      ),
      title: Text(
        modo.titulo,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        modo.descripcion,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
      ),
    );
  }
}

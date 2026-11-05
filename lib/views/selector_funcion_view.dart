import 'package:flutter/material.dart';

import '../models/modo_usuario.dart';
import '../theme/app_theme.dart';

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
          _opcion(ModoUsuario.remitente, Icons.inventory_2_outlined),
          const SizedBox(height: 14),
          _opcion(ModoUsuario.viajero, Icons.send_outlined),
        ],
      ),
    );
  }

  Widget _opcion(ModoUsuario modo, IconData icono) {
    final seleccionada = modo == modoSeleccionado;
    return RadioListTile<ModoUsuario>(
      value: modo,
      selected: seleccionada,
      activeColor: AppTheme.secondary,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      minTileHeight: 139,
      selectedTileColor: const Color(0xFFEDF5FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: seleccionada
            ? const BorderSide(color: AppTheme.secondary, width: 1.8)
            : const BorderSide(color: Color(0xFFD8E0EB)),
      ),
      secondary: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: seleccionada
              ? const Color(0xFFD8EBFF)
              : const Color(0xFFF2F6FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icono, color: AppTheme.primary, size: 29),
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

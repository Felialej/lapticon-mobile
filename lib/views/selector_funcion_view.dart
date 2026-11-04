import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'widgets/marco_autenticacion.dart';

enum Funcion { viajero, remitente }

class SelectorFuncionView extends StatelessWidget {
  const SelectorFuncionView({
    super.key,
    required this.funcion,
    required this.onSeleccionar,
    required this.onContinuar,
  });

  final Funcion funcion;
  final ValueChanged<Funcion> onSeleccionar;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    return MarcoAutenticacion(
      titulo: '¿Cómo usarás Lapticon?',
      subtitulo: 'Selecciona qué quieres hacer hoy.',
      separacionTarjeta: 11,
      nota: 'Selecciona un modo para ver sus funciones.',
      child: RadioGroup<Funcion>(
        groupValue: funcion,
        onChanged: (valor) {
          if (valor != null) onSeleccionar(valor);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _opcion(
              Funcion.remitente,
              Icons.inventory_2_outlined,
              'Remitente',
              'Publicación y seguimiento de encomiendas próximamente.',
            ),
            const SizedBox(height: 14),
            _opcion(
              Funcion.viajero,
              Icons.send_outlined,
              'Viajero',
              'Registra vuelos y consulta tus viajes.',
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onContinuar,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    Funcion valor,
    IconData icono,
    String titulo,
    String descripcion,
  ) {
    final seleccionada = valor == funcion;
    return RadioListTile<Funcion>(
      value: valor,
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
        titulo,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        descripcion,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
      ),
    );
  }
}

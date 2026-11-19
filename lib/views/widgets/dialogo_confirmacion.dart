import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

const _estiloAccion = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size(0, 48)),
  padding: WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 8, vertical: 12),
  ),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
);

Future<bool?> mostrarDialogoConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BotonCancelarDialogo(
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: _estiloAccion,
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(accion, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class BotonCancelarDialogo extends StatelessWidget {
  const BotonCancelarDialogo({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: _estiloAccion.copyWith(
        foregroundColor: const WidgetStatePropertyAll(AppTheme.primary),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0xFFD0D5DD)),
        ),
      ),
      onPressed: onPressed,
      child: const Text('Cancelar', textAlign: TextAlign.center),
    );
  }
}

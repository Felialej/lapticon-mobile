import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../utils/formato_fecha.dart';

/// Campo de texto con su etiqueta encima.
///
/// Reúne la etiqueta, el espacio y el campo en un solo widget para que los
/// formularios no repitan esa combinación en cada dato que piden.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.hintText,
    required this.icono,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  /// Texto que describe el dato pedido.
  final String etiqueta;

  /// Controlador con el contenido escrito en el campo.
  final TextEditingController controller;

  /// Ejemplo que se muestra mientras el campo está vacío.
  final String hintText;

  /// Icono que acompaña al campo.
  final IconData icono;

  /// Regla que decide si el valor escrito es válido.
  final String? Function(String?)? validator;

  /// Tipo de teclado que conviene al dato, por ejemplo el numérico.
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// Mayúsculas automáticas, útil en nombres y apellidos.
  final TextCapitalization textCapitalization;

  /// Acción del teclado: avanzar al campo siguiente o terminar.
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icono),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Selector de fecha con su etiqueta encima.
///
/// Usa el formato `AAAA/MM/DD` por defecto y delega la apertura del calendario
/// en la pantalla que lo usa.
class SelectorFecha extends StatelessWidget {
  const SelectorFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.onTap,
    this.textoVacio = 'Seleccionar fecha',
    this.icono = Icons.calendar_month_outlined,
    this.usarTemaDeEntrada = false,
    this.formatearFecha = formatearFechaAnioMesDia,
  });

  /// Texto que describe la fecha pedida.
  final String etiqueta;

  /// Fecha elegida, o nulo mientras no se elige ninguna.
  final DateTime? fecha;

  /// Acción que abre el calendario.
  final VoidCallback onTap;

  /// Texto que se muestra mientras no hay fecha elegida.
  final String textoVacio;

  /// Icono que acompaña al selector.
  final IconData icono;
  final bool usarTemaDeEntrada;
  final String Function(DateTime fecha) formatearFecha;

  @override
  Widget build(BuildContext context) {
    final sinFecha = fecha == null;
    final texto = sinFecha ? textoVacio : formatearFecha(fecha!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (usarTemaDeEntrada)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: Icon(icono),
                suffixIcon: const Icon(Icons.chevron_right),
              ),
              child: Text(
                texto,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: sinFecha
                      ? Theme.of(context).inputDecorationTheme.hintStyle?.color
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          )
        else
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(icono, color: AppTheme.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        texto,
                        style: TextStyle(
                          color: sinFecha
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

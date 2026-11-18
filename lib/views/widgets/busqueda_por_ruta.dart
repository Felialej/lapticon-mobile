import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Campo que sugiere ciudades del catálogo y comunica la selección a la vista.
class SelectorCiudad extends StatelessWidget {
  const SelectorCiudad({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.ciudades,
    required this.seleccionar,
    required this.validar,
  });

  final String etiqueta;
  final IconData icono;
  final List<String> ciudades;
  final ValueChanged<String?> seleccionar;
  final String? Function() validar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (valor) {
            final consulta = valor.text.trim().toLowerCase();
            if (consulta.length < 2) {
              return const Iterable<String>.empty();
            }
            return ciudades
                .where((ciudad) => ciudad.toLowerCase().contains(consulta))
                .take(12);
          },
          onSelected: seleccionar,
          fieldViewBuilder: (context, texto, foco, _) {
            return TextFormField(
              controller: texto,
              focusNode: foco,
              onChanged: (_) => seleccionar(null),
              validator: (_) => validar(),
              decoration: InputDecoration(
                hintText: 'Escribe al menos 2 letras',
                prefixIcon: Icon(icono),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ErrorCatalogoCiudades extends StatelessWidget {
  const ErrorCatalogoCiudades({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class MensajeBusquedaRuta extends StatelessWidget {
  const MensajeBusquedaRuta({
    super.key,
    required this.icono,
    required this.mensaje,
  });

  final IconData icono;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppTheme.textSecondary, size: 30),
          const SizedBox(height: 8),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

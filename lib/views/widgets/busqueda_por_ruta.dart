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
          optionsViewOpenDirection: OptionsViewOpenDirection.mostSpace,
          optionsBuilder: (valor) => _buscarCiudades(valor.text),
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
              ),
            );
          },
        ),
      ],
    );
  }

  Iterable<String> _buscarCiudades(String texto) {
    final consulta = _normalizar(texto);
    if (consulta.length < 2) return const [];

    final coincidencias = <({String ciudad, String nombre, int prioridad})>[];
    for (final ciudad in ciudades) {
      final nombre = _normalizar(ciudad);
      if (!nombre.contains(consulta)) continue;
      final prioridad = nombre == consulta
          ? 0
          : (nombre.startsWith(consulta) ? 1 : 2);
      coincidencias.add((ciudad: ciudad, nombre: nombre, prioridad: prioridad));
    }
    coincidencias.sort((a, b) {
      final prioridad = a.prioridad.compareTo(b.prioridad);
      return prioridad == 0 ? a.nombre.compareTo(b.nombre) : prioridad;
    });
    return coincidencias.map((opcion) => opcion.ciudad);
  }

  static final _variantes = {
    RegExp(r'[\u0300-\u036f]'): '',
    RegExp('[áàâäãå]'): 'a',
    RegExp('[éèêë]'): 'e',
    RegExp('[íìîï]'): 'i',
    RegExp('[óòôöõ]'): 'o',
    RegExp('[úùûü]'): 'u',
    RegExp('ñ'): 'n',
    RegExp('ç'): 'c',
  };

  static String _normalizar(String texto) {
    var nombre = texto.trim().toLowerCase();
    for (final variante in _variantes.entries) {
      nombre = nombre.replaceAll(variante.key, variante.value);
    }
    return nombre;
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

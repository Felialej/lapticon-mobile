import 'package:flutter/material.dart';

import '../../controllers/catalogo_paises_controller.dart';
import 'dialogo_confirmacion.dart';

class SelectorPais extends StatelessWidget {
  const SelectorPais({
    super.key,
    required this.catalogo,
    required this.seleccion,
    required this.onSeleccionar,
    this.valorGuardado,
    this.validar,
  });

  final CatalogoPaisesController catalogo;
  final String? seleccion;
  final String? valorGuardado;
  final ValueChanged<String> onSeleccionar;
  final String? Function()? validar;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catalogo,
      builder: (context, _) {
        final guardado = valorGuardado;
        final etiquetaGuardado = catalogo.paises.isEmpty
            ? 'Dato guardado'
            : 'Dato anterior';
        final pais =
            seleccion ?? (catalogo.contiene(guardado) ? guardado : null);
        final habilitado =
            !catalogo.cargando &&
            catalogo.error == null &&
            catalogo.paises.isNotEmpty;

        return FormField<String>(
          validator: (_) => validar?.call(),
          builder: (campo) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'País de nacimiento',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: habilitado
                    ? () async {
                        final pais = await showDialog<String>(
                          context: context,
                          builder: (_) =>
                              _BusquedaPais(paises: catalogo.paises),
                        );
                        if (pais == null || !campo.mounted) return;
                        onSeleccionar(pais);
                        campo.didChange(pais);
                      }
                    : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    enabled: habilitado,
                    errorText: campo.errorText,
                    prefixIcon: const Icon(Icons.public_outlined),
                    suffixIcon: catalogo.cargando
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                  child: Text(pais ?? 'Selecciona un país'),
                ),
              ),
              if (seleccion == null &&
                  guardado != null &&
                  guardado.isNotEmpty &&
                  pais == null) ...[
                const SizedBox(height: 8),
                Text('$etiquetaGuardado: $guardado. Puedes actualizarlo aquí.'),
              ],
              if (catalogo.error case final error?) ...[
                const SizedBox(height: 8),
                Text(error),
                TextButton(
                  onPressed: () => catalogo.cargar(actualizar: true),
                  child: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BusquedaPais extends StatefulWidget {
  const _BusquedaPais({required this.paises});

  final List<String> paises;

  @override
  State<_BusquedaPais> createState() => _BusquedaPaisState();
}

class _BusquedaPaisState extends State<_BusquedaPais> {
  String _consulta = '';

  @override
  Widget build(BuildContext context) {
    final resultados = widget.paises
        .where((pais) => pais.toLowerCase().contains(_consulta))
        .toList();

    return AlertDialog(
      title: const Text('País de nacimiento'),
      content: SizedBox(
        width: 360,
        height: 340,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar país',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (texto) =>
                  setState(() => _consulta = texto.trim().toLowerCase()),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultados.isEmpty
                  ? const Center(child: Text('No encontramos ese país.'))
                  : ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, indice) {
                        final pais = resultados[indice];
                        return ListTile(
                          title: Text(pais),
                          onTap: () => Navigator.pop(context, pais),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [BotonCancelarDialogo(onPressed: () => Navigator.pop(context))],
    );
  }
}

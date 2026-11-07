import 'package:flutter/material.dart';

import '../models/encomienda.dart';
import '../theme/app_theme.dart';
import 'widgets/etiqueta_estado.dart';

class MisEncomiendasView extends StatelessWidget {
  const MisEncomiendasView({
    super.key,
    required this.encomiendas,
    required this.cargando,
    required this.error,
    required this.onPublicarEncomienda,
    required this.onVerSeguimiento,
    required this.onRecargar,
  });

  final List<Encomienda> encomiendas;
  final bool cargando;
  final String? error;
  final VoidCallback onPublicarEncomienda;
  final void Function(Encomienda encomienda) onVerSeguimiento;
  final Future<void> Function() onRecargar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Mis encomiendas',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Consulta el estado de tus publicaciones.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: onRecargar,
              child: _contenido(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPublicarEncomienda,
                child: const Text(
                  'Publicar otra encomienda',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (cargando && encomiendas.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null && encomiendas.isEmpty) {
      return _Mensaje(
        icono: Icons.cloud_off_outlined,
        titulo: 'No pudimos cargar tus encomiendas',
        detalle: error!,
      );
    }

    if (encomiendas.isEmpty) {
      return const _Mensaje(
        icono: Icons.inventory_2_outlined,
        titulo: 'Todavía no tienes encomiendas',
        detalle:
            'Publica tu primera encomienda para verla aquí.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      itemCount: encomiendas.length + 1,
      separatorBuilder: (context, indice) =>
          const SizedBox(height: 14),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return const Text(
            'Encomiendas registradas',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          );
        }

        final encomienda = encomiendas[indice - 1];

        return _TarjetaEncomienda(
          encomienda: encomienda,
          onVerSeguimiento: () =>
              onVerSeguimiento(encomienda),
        );
      },
    );
  }
}

class _TarjetaEncomienda extends StatelessWidget {
  const _TarjetaEncomienda({
    required this.encomienda,
    required this.onVerSeguimiento,
  });

  final Encomienda encomienda;
  final VoidCallback onVerSeguimiento;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  encomienda.ruta,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              EtiquetaEstado(estado: encomienda.estado),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          const Text(
            'Valor',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            encomienda.valorConMoneda,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Estado: ${encomienda.estado.descripcion}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEAF2FF),
                foregroundColor: AppTheme.primary,
                minimumSize: const Size(0, 46),
              ),
              onPressed: onVerSeguimiento,
              child: const Text('Ver seguimiento'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 20),
      children: [
        Icon(
          icono,
          size: 56,
          color: const Color(0xFF98A2B3),
        ),
        const SizedBox(height: 18),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

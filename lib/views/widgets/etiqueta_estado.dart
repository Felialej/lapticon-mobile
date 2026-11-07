import 'package:flutter/material.dart';

import '../../models/encomienda.dart';

class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({
    super.key,
    required this.estado,
  });

  final EstadoEncomienda estado;

  static Color colorDeFondo(EstadoEncomienda estado) {
    switch (estado) {
      case EstadoEncomienda.disponible:
        return const Color(0xFFEAF2FF);
      case EstadoEncomienda.tomada:
        return const Color(0xFFFDF3E2);
      case EstadoEncomienda.recibida:
        return const Color(0xFFE7F6EF);
      case EstadoEncomienda.vencida:
        return const Color(0xFFF2F4F7);
    }
  }

  static Color colorDeTexto(EstadoEncomienda estado) {
    switch (estado) {
      case EstadoEncomienda.disponible:
        return const Color(0xFF2F80ED);
      case EstadoEncomienda.tomada:
        return const Color(0xFFB54708);
      case EstadoEncomienda.recibida:
        return const Color(0xFF067647);
      case EstadoEncomienda.vencida:
        return const Color(0xFF667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorDeFondo(estado),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: colorDeTexto(estado),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

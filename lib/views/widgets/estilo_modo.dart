import 'package:flutter/material.dart';

import '../../models/modo_usuario.dart';
import '../../theme/app_theme.dart';

extension EstiloModo on ModoUsuario {
  IconData get icono => switch (this) {
    ModoUsuario.viajero => Icons.flight_takeoff_rounded,
    ModoUsuario.remitente => Icons.inventory_2_outlined,
  };

  Color get acento => switch (this) {
    ModoUsuario.viajero => AppTheme.primary,
    ModoUsuario.remitente => const Color(0xFF146453),
  };

  Color get fondo => switch (this) {
    ModoUsuario.viajero => const Color(0xFFEAF2FF),
    ModoUsuario.remitente => const Color(0xFFE4F3ED),
  };
}

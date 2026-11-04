import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'theme/app_theme.dart';
import 'views/login_view.dart';
import 'views/seleccion_modo_view.dart';

void main() {
  runApp(const LapticonApp());
}

/// Raíz de la aplicación.
///
/// Crea el [AuthController] una sola vez y lo mantiene vivo mientras la
/// aplicación esté abierta, para que todas las vistas consulten la misma
/// sesión.
class LapticonApp extends StatefulWidget {
  const LapticonApp({super.key});

  @override
  State<LapticonApp> createState() => _LapticonAppState();
}

class _LapticonAppState extends State<LapticonApp> {
  /// Única instancia del controlador de autenticación de la aplicación.
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lapticon',
      theme: AppTheme.lightTheme,
      // La pantalla inicial depende de la sesión: el ListenableBuilder se
      // redibuja cuando el controlador abre o cierra sesión, así que ninguna
      // vista necesita navegar por su cuenta al entrar o al salir.
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          if (_authController.haySesion) {
            return SeleccionModoView(
              authController: _authController,
            );
          }

          return LoginView(
            authController: _authController,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'registro_view.dart';
import 'widgets/campos_formulario.dart';
import 'widgets/marco_autenticacion.dart';

/// Pantalla de inicio de sesión.
///
/// Dibuja el formulario y delega la validación y la llamada a Firebase en
/// [AuthController]. No decide qué pantalla sigue tras un acceso correcto: al
/// quedar la sesión abierta, la raíz de la aplicación reemplaza esta vista.
class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.authController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// Llave del formulario, necesaria para disparar los validadores.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de los campos de texto. Pertenecen a la vista porque
  /// representan el contenido escrito, no el estado de la sesión.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Indica si la contraseña se muestra oculta. Es estado puramente visual.
  bool _ocultarPassword = true;

  /// Atajo de lectura hacia el controlador recibido.
  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valida el formulario y pide al controlador autenticar las credenciales.
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final exito = await _auth.iniciarSesion(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // `mounted` se comprueba porque entre la llamada y la respuesta el usuario
    // pudo salir de la pantalla.
    if (!exito && mounted) {
      _mostrarError();
    }
  }

  /// Muestra el mensaje de error que preparó el controlador.
  void _mostrarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _auth.error ?? 'No fue posible iniciar sesión.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Abre la pantalla de registro sobre la actual.
  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroView(
          authController: _auth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarcoAutenticacion(
      titulo: 'Iniciar sesión',
      subtitulo: 'Accede a tu cuenta para continuar',
      child: ListenableBuilder(
        listenable: _auth,
        builder: (context, _) {
          final cargando = _auth.cargando;

          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controller: _emailController,
                  hintText: 'correo@ejemplo.com',
                  icono: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _auth.validarCorreo,
                ),
                const SizedBox(height: 23),
                CampoTexto(
                  etiqueta: 'Contraseña',
                  controller: _passwordController,
                  hintText: 'Tu contraseña',
                  icono: Icons.lock_outline,
                  obscureText: _ocultarPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!cargando) {
                      _iniciarSesion();
                    }
                  },
                  suffixIcon: IconButton(
                    tooltip: _ocultarPassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    onPressed: () {
                      setState(() {
                        _ocultarPassword = !_ocultarPassword;
                      });
                    },
                    icon: Icon(
                      _ocultarPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: _auth.validarPassword,
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: cargando ? null : _iniciarSesion,
                  child: cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 36),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: cargando ? null : _irARegistro,
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

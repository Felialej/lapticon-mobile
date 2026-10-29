import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'registro_view.dart';

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
    return Scaffold(
      body: SafeArea(
        // El ListenableBuilder vuelve a construir el formulario cada vez que el
        // controlador notifica un cambio, por ejemplo al activar la carga.
        child: ListenableBuilder(
          listenable: _auth,
          builder: (context, _) {
            final cargando = _auth.cargando;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                30,
                24,
                30,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),

                    // Encabezado con el logotipo de la aplicación.
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.flight_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Ingresa a Lapticon para gestionar tus viajes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Campo de correo. La regla de formato vive en el
                    // controlador para que login y registro usen la misma.
                    const Text(
                      'Correo electrónico',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'correo@ejemplo.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                      validator: _auth.validarCorreo,
                    ),

                    const SizedBox(height: 22),

                    // Campo de contraseña. Al iniciar sesión basta con que no
                    // esté vacía: la longitud la verifica Firebase.
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!cargando) {
                          _iniciarSesion();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _ocultarPassword =
                                  !_ocultarPassword;
                            });
                          },
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons
                                      .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: _auth.validarPassword,
                    ),

                    const SizedBox(height: 32),

                    // Durante la carga el botón se deshabilita y muestra el
                    // indicador de progreso.
                    FilledButton(
                      onPressed:
                          cargando ? null : _iniciarSesion,
                      child: cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                            )
                          : const Text(
                              'Iniciar sesión',
                            ),
                    ),

                    const SizedBox(height: 18),

                    // Acceso a la pantalla de registro.
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: cargando
                              ? null
                              : _irARegistro,
                          child: const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

/// Pantalla de creación de cuenta.
///
/// Comparte el mismo [AuthController] que el inicio de sesión, porque ambas
/// pantallas operan sobre la misma sesión y reutilizan sus validaciones.
class RegistroView extends StatefulWidget {
  const RegistroView({
    super.key,
    required this.authController,
  });

  /// Controlador compartido que gestiona la sesión.
  final AuthController authController;

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  /// Llave del formulario, necesaria para disparar los validadores.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de los campos de texto.
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

  /// Valida el formulario, pide crear la cuenta y confirma el resultado.
  ///
  /// Al completarse el registro la sesión queda abierta, así que la raíz de la
  /// aplicación ya muestra la navegación principal debajo de esta pantalla y
  /// basta con cerrarla.
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final exito = await _auth.registrar(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!exito) {
      _mostrarError();
      return;
    }

    await _mostrarConfirmacion();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  /// Muestra el mensaje de error que preparó el controlador.
  void _mostrarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _auth.error ?? 'No fue posible crear la cuenta.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Avisa que la cuenta quedó creada antes de entrar a la aplicación.
  Future<void> _mostrarConfirmacion() {
    final correo = _auth.usuario?.email ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 52,
          ),
          title: const Text(
            'Cuenta creada',
          ),
          content: Text(
            'La cuenta $correo fue registrada correctamente.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Continuar',
              ),
            ),
          ],
        );
      },
    );
  }

  /// Regresa al inicio de sesión cerrando esta pantalla.
  void _irALogin() {
    Navigator.pop(context);
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
                      'Crear cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Regístrate en Lapticon para comenzar a gestionar tus viajes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Campo de correo, con la misma regla de formato que usa
                    // el inicio de sesión.
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

                    // Campo de contraseña. A diferencia del login, aquí se
                    // exige la longitud mínima antes de llamar a Firebase.
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
                          _registrar();
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Mínimo '
                            '${AuthController.minimoCaracteresPassword}'
                            ' caracteres',
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
                      validator: (valor) =>
                          _auth.validarPassword(
                            valor,
                            exigirLongitudMinima: true,
                          ),
                    ),

                    const SizedBox(height: 12),

                    // Aclaración del requisito de la contraseña.
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 17,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Tu contraseña debe tener como mínimo '
                            '${AuthController.minimoCaracteresPassword}'
                            ' caracteres.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Durante la carga el botón se deshabilita y muestra el
                    // indicador de progreso.
                    FilledButton(
                      onPressed: cargando ? null : _registrar,
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
                              'Crear cuenta',
                            ),
                    ),

                    const SizedBox(height: 18),

                    // Regreso al inicio de sesión.
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: cargando
                              ? null
                              : _irALogin,
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Al crear una cuenta podrás acceder a las funcionalidades de Lapticon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
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

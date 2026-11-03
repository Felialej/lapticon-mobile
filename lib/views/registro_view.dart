import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../utils/validadores.dart';
import 'widgets/campos_formulario.dart';

/// Pantalla de creación de cuenta.
///
/// Pide los datos personales que guarda el backend y las credenciales que
/// crea Firebase. Comparte el mismo [AuthController] que el inicio de sesión,
/// porque ambas pantallas operan sobre la misma sesión.
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

  /// Controladores de los campos de texto, uno por dato pedido.
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Fecha de nacimiento elegida en el calendario.
  ///
  /// Se guarda aquí, junto a los controladores de texto, porque es el
  /// contenido de un campo más del formulario.
  DateTime? _fechaNacimiento;

  /// Indica si la contraseña se muestra oculta. Es estado puramente visual.
  bool _ocultarPassword = true;

  /// Atajo de lectura hacia el controlador recibido.
  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _nacionalidadController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Abre el calendario para elegir la fecha de nacimiento.
  ///
  /// El rango va desde 1900 hasta hoy, de modo que no se puedan elegir fechas
  /// futuras.
  Future<void> _seleccionarFechaNacimiento() async {
    final hoy = DateTime.now();

    final fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(hoy.year - 20),
      firstDate: DateTime(1900),
      lastDate: hoy,
    );

    if (fechaElegida == null) {
      return;
    }

    setState(() {
      _fechaNacimiento = fechaElegida;
    });
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

    // La fecha se revisa aparte porque se elige en un calendario y no en un
    // campo del formulario.
    if (_fechaNacimiento == null) {
      _mostrarMensaje('Selecciona tu fecha de nacimiento');
      return;
    }

    final exito = await _auth.registrarConPerfil(
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      telefono: _telefonoController.text,
      fechaNacimiento: _fechaNacimiento!,
      nacionalidad: _nacionalidadController.text,
    );

    if (!mounted) {
      return;
    }

    if (!exito) {
      _mostrarMensaje(
        _auth.error ?? 'No fue posible crear la cuenta.',
      );
      return;
    }

    await _mostrarConfirmacion();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  /// Muestra un aviso en la parte inferior de la pantalla.
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Encabezado con el logotipo de la aplicación.
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(22),
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

                    const SizedBox(height: 32),

                    // Datos personales que se guardan en el backend.
                    const _TituloSeccion(
                      titulo: 'Datos personales',
                    ),

                    const SizedBox(height: 16),

                    CampoTexto(
                      etiqueta: 'Nombre',
                      controller: _nombreController,
                      hintText: 'Ejemplo: Ana',
                      icono: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (valor) =>
                          validarTextoObligatorio(valor, 'nombre'),
                    ),

                    const SizedBox(height: 20),

                    CampoTexto(
                      etiqueta: 'Apellido',
                      controller: _apellidoController,
                      hintText: 'Ejemplo: Gómez',
                      icono: Icons.badge_outlined,
                      textCapitalization: TextCapitalization.words,
                      validator: (valor) =>
                          validarTextoObligatorio(valor, 'apellido'),
                    ),

                    const SizedBox(height: 20),

                    CampoTexto(
                      etiqueta: 'Teléfono',
                      controller: _telefonoController,
                      hintText: 'Ejemplo: 3001234567',
                      icono: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: validarTelefono,
                    ),

                    const SizedBox(height: 20),

                    SelectorFecha(
                      etiqueta: 'Fecha de nacimiento',
                      fecha: _fechaNacimiento,
                      onTap: _seleccionarFechaNacimiento,
                      textoVacio: 'AAAA/MM/DD',
                      icono: Icons.cake_outlined,
                    ),

                    const SizedBox(height: 20),

                    CampoTexto(
                      etiqueta: 'Nacionalidad',
                      controller: _nacionalidadController,
                      hintText: 'Ejemplo: Colombia',
                      icono: Icons.public_outlined,
                      textCapitalization: TextCapitalization.words,
                      validator: (valor) =>
                          validarTextoObligatorio(valor, 'nacionalidad'),
                    ),

                    const SizedBox(height: 32),

                    // Credenciales con las que se inicia sesión.
                    const _TituloSeccion(
                      titulo: 'Datos de acceso',
                    ),

                    const SizedBox(height: 16),

                    CampoTexto(
                      etiqueta: 'Correo electrónico',
                      controller: _emailController,
                      hintText: 'correo@ejemplo.com',
                      icono: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _auth.validarCorreo,
                    ),

                    const SizedBox(height: 20),

                    // La contraseña no usa CampoTexto porque necesita el botón
                    // que alterna entre mostrarla y ocultarla.
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
                              _ocultarPassword = !_ocultarPassword;
                            });
                          },
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (valor) => _auth.validarPassword(
                        valor,
                        exigirLongitudMinima: true,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Durante la carga el botón se deshabilita y muestra el
                    // indicador de progreso.
                    FilledButton(
                      onPressed: cargando ? null : _registrar,
                      child: cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: cargando ? null : _irALogin,
                          child: const Text(
                            'Iniciar sesión',
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

/// Título que separa los bloques del formulario.
class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({
    required this.titulo,
  });

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

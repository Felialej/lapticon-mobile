import 'package:flutter/material.dart';

import '../controllers/perfil_controller.dart';
import '../models/perfil_usuario.dart';
import '../theme/app_theme.dart';
import '../utils/validadores.dart';
import 'widgets/campos_formulario.dart';
import 'widgets/formateadores_entrada.dart';
import 'widgets/selector_pais.dart';

/// Formulario de actualización de los datos personales.
///
/// Los campos llegan rellenos con los datos actuales y se envían con
/// `PUT /api/users/{uid}`. Al cerrarse devuelve `true` si la actualización
/// funcionó, para que la pestaña de perfil avise del resultado.
class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({
    super.key,
    required this.perfilController,
    required this.perfil,
    required this.idToken,
  });

  /// Controlador que realiza la actualización.
  final PerfilController perfilController;

  /// Datos actuales, usados para rellenar el formulario.
  final PerfilUsuario perfil;

  /// Token de la sesión, exigido por el backend.
  final String idToken;

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  /// Llave del formulario, necesaria para disparar los validadores.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de los campos editables, rellenos en [initState].
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _telefonoController;
  String? _paisElegido;

  /// Fecha de nacimiento elegida, inicializada con la que ya está guardada.
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();

    final perfil = widget.perfil;

    _nombreController = TextEditingController(text: perfil.nombre);
    _apellidoController = TextEditingController(text: perfil.apellido);
    _telefonoController = TextEditingController(text: perfil.telefono);
    _fechaNacimiento = perfil.fechaNacimiento;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.perfilController.catalogoPaises.cargar(actualizar: true);
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  /// Abre el calendario para cambiar la fecha de nacimiento.
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

  /// Valida el formulario y envía los cambios al backend.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaNacimiento == null) {
      _mostrarMensaje('Selecciona tu fecha de nacimiento');
      return;
    }

    // El uid y el correo se conservan tal cual: el backend no permite
    // modificarlos y responde 400 si llegan en el cuerpo de la petición.
    final perfilEditado = PerfilUsuario(
      uid: widget.perfil.uid,
      email: widget.perfil.email,
      correo: widget.perfil.correo,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      nacionalidad: _paisElegido ?? widget.perfil.nacionalidad,
      fechaNacimiento: _fechaNacimiento,
    );

    final exito = await widget.perfilController.actualizarPerfil(
      perfil: perfilEditado,
      idToken: widget.idToken,
    );

    if (!mounted) {
      return;
    }

    if (!exito) {
      _mostrarMensaje(
        widget.perfilController.error ??
            'No fue posible actualizar tus datos.',
      );
      return;
    }

    Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actualizar datos',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // El ListenableBuilder redibuja el botón mientras se guarda.
      body: ListenableBuilder(
        listenable: widget.perfilController,
        builder: (context, _) {
          final guardando = widget.perfilController.guardando;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El correo (${widget.perfil.correo}) no se puede modificar.',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

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
                    inputFormatters: const [FormateadorTelefono()],
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

                  SelectorPais(
                    catalogo: widget.perfilController.catalogoPaises,
                    seleccion: _paisElegido,
                    valorGuardado: widget.perfil.nacionalidad,
                    onSeleccionar: (pais) => setState(() => _paisElegido = pais),
                  ),

                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: guardando ? null : _guardar,
                    child: guardando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Guardar cambios',
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

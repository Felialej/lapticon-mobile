// Validaciones de los campos del perfil.
//
// Se escriben como funciones sueltas porque las comparten dos pantallas (el
// registro de la cuenta y la edición del perfil) y no dependen de ningún
// estado. Devuelven el mensaje de error, o nulo si el valor es correcto, que
// es el contrato que esperan los `TextFormField`.

/// Comprueba que un campo de texto obligatorio tenga contenido.
///
/// El nombre del campo se recibe para armar el mensaje, por ejemplo
/// `validarTextoObligatorio(valor, 'nombre')`.
String? validarTextoObligatorio(String? valor, String nombreCampo) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Ingresa tu $nombreCampo';
  }

  return null;
}

const maximoDigitosTelefono = 10;

/// Comprueba que el teléfono contenga entre 7 y 10 dígitos.
String? validarTelefono(String? valor) {
  final telefono = valor ?? '';

  if (telefono.trim().isEmpty) {
    return 'Ingresa tu teléfono';
  }

  if (!_soloNumeros.hasMatch(telefono)) {
    return 'El teléfono solo puede tener números';
  }

  if (telefono.length < 7) {
    return 'El teléfono es demasiado corto';
  }

  if (telefono.length > maximoDigitosTelefono) {
    return 'El teléfono puede tener máximo $maximoDigitosTelefono dígitos';
  }

  return null;
}

/// Expresión que acepta únicamente dígitos del 0 al 9.
final RegExp _soloNumeros = RegExp(r'^[0-9]+$');

const maximoDigitosValorDeclarado = 13;
const mensajeMaximoValorDeclarado =
    'Máximo $maximoDigitosValorDeclarado dígitos, incluidos los decimales.';

bool superaMaximoValorDeclarado(String texto) =>
    texto.replaceAll('.', '').replaceAll(',', '').length >
    maximoDigitosValorDeclarado;

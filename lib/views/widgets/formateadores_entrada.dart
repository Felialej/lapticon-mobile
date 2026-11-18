import 'package:flutter/services.dart';

import '../../utils/validadores.dart';

class FormateadorTelefono extends TextInputFormatter {
  const FormateadorTelefono();

  static final _limite = LengthLimitingTextInputFormatter(
    maximoDigitosTelefono,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final filtrado = FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
      anterior,
      nuevo,
    );
    if (anterior.text.length > maximoDigitosTelefono &&
        filtrado.text.length > maximoDigitosTelefono) {
      // Un teléfono guardado permite borrar dígitos sin truncar el resto.
      final eliminados = anterior.text.length - nuevo.text.length;
      final cursor = nuevo.selection.start;
      if (eliminados > 0 &&
          cursor >= 0 &&
          cursor <= nuevo.text.length &&
          anterior.text.replaceRange(cursor, cursor + eliminados, '') ==
              nuevo.text) {
        return filtrado;
      }
      return anterior;
    }
    return _limite.formatEditUpdate(anterior, filtrado);
  }
}

/// Agrupa los miles con puntos y conserva la coma como separador decimal.
class FormateadorValorColombiano extends TextInputFormatter {
  const FormateadorValorColombiano();

  static final _entrada = RegExp(r'^[0-9.]*(?:,[0-9]*)?$');
  static final _milesAgrupados = RegExp(r'^[0-9]{1,3}(?:\.[0-9]{3})+$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final texto = nuevo.text;
    if (!nuevo.composing.isCollapsed || texto == anterior.text) return nuevo;
    if (!_entrada.hasMatch(texto)) return anterior;

    final partes = texto.split(',');
    final entero = partes.first.replaceAll('.', '');
    final agregaCero = entero.isEmpty && partes.length == 2;
    if (superaMaximoValorDeclarado(agregaCero ? '0$texto' : texto)) {
      return anterior;
    }

    final puntos = partes.first.length - entero.length;
    if (puntos > 0 && !_milesAgrupados.hasMatch(partes.first)) {
      // Al editar en medio, los puntos que ya estaban pueden quedar
      // desplazados. Los puntos pegados sí deben venir agrupados.
      final insertado = _textoInsertado(anterior, texto);
      if (insertado != null) {
        final grupo = insertado.split(',').first;
        if (grupo.contains('.') && !_milesAgrupados.hasMatch(grupo)) {
          return anterior;
        }
      } else if (puntos > '.'.allMatches(anterior.text).length) {
        return anterior;
      }
    }

    final agrupado = StringBuffer();
    if (agregaCero) agrupado.write('0');
    for (var i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) agrupado.write('.');
      agrupado.write(entero[i]);
    }
    if (partes.length == 2) agrupado.write(',${partes.last}');

    final formateado = agrupado.toString();
    if (texto == formateado) return nuevo;

    final borroSoloPuntos =
        texto.replaceAll('.', '') == anterior.text.replaceAll('.', '');
    final borroHaciaAdelante =
        borroSoloPuntos &&
        anterior.selection.isCollapsed &&
        anterior.selection.extentOffset == nuevo.selection.extentOffset;

    // Contar dígitos y coma permite ubicar el cursor aunque cambien los puntos.
    int posicionEnTextoFormateado(int offset) {
      if (offset < 0) return formateado.length;
      final antes = texto.substring(0, offset).replaceAll('.', '').length;
      final caracteres = agregaCero && antes > 0 ? antes + 1 : antes;
      var posicion = 0;
      var leidos = 0;
      while (leidos < caracteres) {
        if (formateado[posicion] != '.') leidos++;
        posicion++;
      }
      final despuesDePunto = offset > 0 && texto[offset - 1] == '.';
      if ((despuesDePunto || borroHaciaAdelante) &&
          posicion < formateado.length &&
          formateado[posicion] == '.') {
        posicion++;
      }
      return posicion;
    }

    return TextEditingValue(
      text: formateado,
      selection: nuevo.selection.copyWith(
        baseOffset: posicionEnTextoFormateado(nuevo.selection.baseOffset),
        extentOffset: posicionEnTextoFormateado(nuevo.selection.extentOffset),
      ),
    );
  }

  String? _textoInsertado(TextEditingValue anterior, String texto) {
    final inicio = anterior.selection.start;
    final fin = anterior.selection.end;
    if (inicio < 0) return null;

    final sufijo = anterior.text.substring(fin);
    final finInsertado = texto.length - sufijo.length;
    if (finInsertado < inicio ||
        !texto.startsWith(anterior.text.substring(0, inicio)) ||
        !texto.endsWith(sufijo)) {
      return null;
    }
    return texto.substring(inicio, finInsertado);
  }
}

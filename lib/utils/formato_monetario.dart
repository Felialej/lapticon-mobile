final _gruposDeMiles = RegExp(r'(\d)(?=(?:\d{3})+$)');

String agruparMiles(String entero) =>
    entero.replaceAllMapped(_gruposDeMiles, (grupo) => '${grupo[1]}.');

String formatearValorColombiano(double valor) {
  if (!valor.isFinite) return valor.toString();

  // A partir de esta magnitud, toStringAsFixed usa notación científica.
  if (valor.abs() >= 1e21) return agruparMiles(BigInt.from(valor).toString());

  final [entero, decimales] = valor.toStringAsFixed(2).split('.');
  final agrupado = agruparMiles(entero);
  return decimales == '00' ? agrupado : '$agrupado,$decimales';
}

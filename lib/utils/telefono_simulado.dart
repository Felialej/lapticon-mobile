import 'dart:math';

String generarTelefonoSimulado() {
  final resto = Random().nextInt(10000000).toString().padLeft(7, '0');
  return '320 ${resto.substring(0, 3)} ${resto.substring(3)}';
}

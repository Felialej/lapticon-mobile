import 'package:flutter_test/flutter_test.dart';
import 'package:lapticon_mobile/models/encomienda.dart';

void main() {
  const casos = [
    (60000.0, 'COP', '60.000'),
    (100000.0, 'COP', '100.000'),
    (1000000.0, 'COP', '1.000.000'),
    (1500.5, 'USD', '1.500,50'),
    (2500000.75, 'EUR', '2.500.000,75'),
  ];

  for (final (valor, moneda, formato) in casos) {
    test('Muestra $moneda $formato y serializa el valor numérico original', () {
      final encomienda = Encomienda.desdeJson({
        'valor': valor,
        'moneda': moneda,
      });

      expect(encomienda.valorConMoneda, '$moneda $formato');
      expect(encomienda.valor, valor);
      expect(encomienda.toJson()['valor'], valor);
      expect(encomienda.toJson()['moneda'], moneda);
    });
  }
}

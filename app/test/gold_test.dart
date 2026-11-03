import 'package:flutter_test/flutter_test.dart';
import 'package:uae_gold_calculator/core/gold.dart';

void main() {
  test('karat table at 461.11', () {
    final t = priceTable(461.11);
    expect(t.map((r) => r.perGram), [461.11, 422.68, 403.47, 345.83, 268.98]);
    expect(t.first.perOunce, 14342.12);
  });
  test('item price with making and VAT', () {
    final r = itemPrice(price24: 461.11, weight: 10, karat: 21, making: 30);
    expect(
      [r.metal, r.making, r.vat, r.total],
      [4034.71, 300, 216.74, 4551.45],
    );
  });
  test('zakat', () {
    final z = zakat(461.11, const [GoldItem(100, karat: 21)]);
    expect(z.pureGrams, 87.5);
    expect(z.due, isTrue);
    expect(z.zakat, 1008.68);
    expect(zakat(461.11, const [GoldItem(90, karat: 18)]).zakat, 0);
  });
  test('Arabic digits parse', () {
    expect(parseNumber('٤٦١٫١١'), 461.11);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uae_gold_calculator/core/gold.dart';

void main() {
  test('karat table at 461.11', () {
    final t = priceTable(461.11);
    expect(t.map((r) => r.perGram), [461.11, 421.88, 403.41, 345.72, 269.10]);
    expect(t.first.perOunce, 14342.12);
  });
  test('item price with making and VAT', () {
    final r = itemPrice(price24: 461.11, weight: 10, karat: 21, making: 30);
    expect(
      [r.metal, r.making, r.vat, r.total],
      [4034.14, 300, 216.71, 4550.84],
    );
  });
  test('zakat', () {
    final z = zakat(461.11, const [GoldItem(100, karat: 21)]);
    expect(z.pureGrams, 87.4875);
    expect(z.due, isTrue);
    expect(z.zakat, 1008.53);
    expect(zakat(461.11, const [GoldItem(90, karat: 18)]).zakat, 0);
  });
  test('Arabic digits parse', () {
    expect(parseNumber('٤٦١٫١١'), 461.11);
  });
  test('matches the UAE board fineness', () {
    expect(priceTable(461.74).map((r) => r.perGram).toList(), [461.74, 422.45, 403.96, 346.19, 269.46]);
    expect(purity(16), 666 / 999);
    expect(purity(9), 9 / 24);
  });
}

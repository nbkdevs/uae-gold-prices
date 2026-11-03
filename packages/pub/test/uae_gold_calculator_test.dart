import 'package:test/test.dart';
import 'package:uae_gold_calculator/uae_gold_calculator.dart';

void main() {
  test('karat table', () {
    final t = priceTable(461.11);
    expect(t.map((r) => r.perGram).toList(), [461.11, 421.88, 403.41, 345.72, 269.10]);
    expect(t.first.perOunce, 14342.12);
  });
  test('conversions', () {
    expect(roundTo(convert(1, 'tola', 'g'), 7), 11.6638038);
    expect(roundTo(convert(10, 'مثقال', 'g')), 42.5);
    expect(() => convert(1, 'stone', 'g'), throwsArgumentError);
  });
  test('item price', () {
    final r = itemPrice(price24: 461.11, weight: 10, karat: 21, making: 30);
    expect([r.metal, r.making, r.vat, r.total], [4034.14, 300, 216.71, 4550.84]);
    expect(itemPrice(price24: 400, weight: 1, unit: 'oz', vatRate: 0).total, 12441.39);
    expect(itemPrice(price24: 400, weight: 5, karat: 18, making: 10, makingType: MakingType.percent, vatRate: 0).total, 1649.45);
    expect(itemPrice(price24: 400, weight: 5, karat: 18, making: 99, makingType: MakingType.fixed, vatRate: 0).total, 1598.5);
  });
  test('zakat', () {
    final z = zakat(461.11, [const GoldItem(100, karat: 21)]);
    expect([z.pureGrams, z.due, z.zakat], [87.4875, true, 1008.53]);
    final n = zakat(461.11, [const GoldItem(90, karat: 18)]);
    expect([n.due, n.zakat], [false, 0]);
  });
  test('parsing', () {
    expect(parseNumber('٤٦١٫١١'), 461.11);
    expect(parseNumber('461,11'), 461.11);
    expect(parseNumber('14,342.21'), 14342.21);
    expect(() => karatPrice(-1, 22), throwsArgumentError);
  });
  test('matches the UAE board fineness', () {
    expect(priceTable(461.74).map((r) => r.perGram).toList(), [461.74, 422.45, 403.96, 346.19, 269.46]);
    expect(purity(16), 666 / 999);
    expect(purity(9), 9 / 24);
  });
}

import 'package:uae_gold_calculator/uae_gold_calculator.dart';

void main() {
  // 24K price per gram today (see https://uaegoldprices.ae/)
  for (final r in priceTable(461.11)) {
    print('${r.karat}K: ${r.perGram} AED/g');
  }
  final ring = itemPrice(price24: 461.11, weight: 10, karat: 21, making: 30);
  print('10 g 21K ring with 30 AED/g making + 5% VAT: ${ring.total} AED');
  print('Zakat on 100 g 21K: ${zakat(461.11, [const GoldItem(100, karat: 21)]).zakat} AED');
}

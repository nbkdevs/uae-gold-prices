import 'dart:io';

import 'package:uae_gold_calculator/uae_gold_calculator.dart';

const _help = '''uae_gold_calculator 1.0.0: gold karat prices, making charges, VAT and zakat

  dart run uae_gold_calculator table --price <24K AED/g> [--lang ar]
  dart run uae_gold_calculator item --price <24K> --weight <n> [--unit g] [--karat 21] [--making 30] [--making-type per_gram|percent|fixed] [--vat 0.05] [--lang ar]
  dart run uae_gold_calculator convert <value> <from> <to>
  dart run uae_gold_calculator zakat --price <24K> --weight <n> [--karat 21] [--lang ar]

Today's 24K price: https://uaegoldprices.ae/''';

void main(List<String> args) {
  final pos = <String>[];
  final opt = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    if (args[i].startsWith('--')) {
      opt[args[i].substring(2)] = i + 1 < args.length ? args[++i] : '';
    } else {
      pos.add(args[i]);
    }
  }
  final ar = opt['lang'] == 'ar';
  final cur = ar ? 'د.إ' : 'AED';
  double n(String k, [double? d]) {
    final v = opt[k];
    if (v == null) {
      if (d == null) throw ArgumentError('--$k is required');
      return d;
    }
    return parseNumber(v);
  }

  try {
    switch (pos.isEmpty ? '' : pos.first) {
      case 'convert':
        stdout.writeln(roundTo(convert(parseNumber(pos[1]), pos[2], pos[3]), 4));
      case 'table':
        stdout.writeln(ar ? 'العيار\tسعر الجرام\tسعر التولة\tسعر الأونصة' : 'Karat\tPer gram\tPer tola\tPer ounce');
        for (final r in priceTable(n('price'))) {
          stdout.writeln('${r.karat}K (${r.hallmark})\t${r.perGram.toStringAsFixed(2)}\t'
              '${r.perTola.toStringAsFixed(2)}\t${r.perOunce.toStringAsFixed(2)}');
        }
      case 'item':
        final type = switch (opt['making-type'] ?? 'per_gram') {
          'percent' => MakingType.percent,
          'fixed' => MakingType.fixed,
          _ => MakingType.perGram,
        };
        final r = itemPrice(
          price24: n('price'),
          weight: n('weight'),
          unit: opt['unit'] ?? 'g',
          karat: n('karat', 24),
          making: n('making', 0),
          makingType: type,
          vatRate: n('vat', uaeVatRate),
        );
        stdout.writeln('${ar ? 'قيمة الذهب' : 'Gold value'}: ${r.metal.toStringAsFixed(2)} $cur');
        stdout.writeln('${ar ? 'المصنعية' : 'Making charge'}: ${r.making.toStringAsFixed(2)} $cur');
        stdout.writeln('${ar ? 'ضريبة القيمة المضافة' : 'VAT'}: ${r.vat.toStringAsFixed(2)} $cur');
        stdout.writeln('${ar ? 'الإجمالي' : 'Total'}: ${r.total.toStringAsFixed(2)} $cur');
      case 'zakat':
        final z = zakat(n('price'), [GoldItem(n('weight'), unit: opt['unit'] ?? 'g', karat: n('karat', 24))]);
        stdout.writeln(z.due
            ? '${ar ? 'الزكاة المستحقة' : 'Zakat due'}: ${z.zakat.toStringAsFixed(2)} $cur'
            : (ar ? 'أقل من النصاب: لا زكاة' : 'Below nisab: no zakat due'));
      default:
        stdout.writeln(_help);
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    exitCode = 1;
  }
}

/// Gold value maths for the UAE market: karat prices, unit conversion,
/// making charges, VAT and zakat. Pure Dart, no network. Pass today's 24K
/// price per gram (for example from https://uaegoldprices.ae/).
library;

/// Karats in the default table.
const List<int> karats = [24, 22, 21, 18, 14];

/// Fineness per mille used by UAE gold price boards (and uaegoldprices.ae).
/// A karat's price = 24K price x fineness / 999; other karats use karat / 24.
const Map<int, int> hallmarks = {24: 999, 22: 914, 21: 874, 18: 749, 16: 666, 14: 583};

/// Grams in one unit.
const Map<String, double> units = {
  'g': 1,
  'kg': 1000,
  'oz': 31.1034768,
  'tola': 11.6638038,
  'mithqal': 4.25,
};

const Map<String, String> _aliases = {
  'gram': 'g', 'grams': 'g', 'gr': 'g', 'جرام': 'g', 'غرام': 'g',
  'kilogram': 'kg', 'kilo': 'kg', 'كيلو': 'kg',
  'ounce': 'oz', 'ozt': 'oz', 'troy_ounce': 'oz', 'troy-ounce': 'oz', 'أونصة': 'oz', 'اونصة': 'oz',
  'tolas': 'tola', 'تولة': 'tola',
  'mithqals': 'mithqal', 'misqal': 'mithqal', 'مثقال': 'mithqal',
};

/// UAE standard VAT rate.
const double uaeVatRate = 0.05;

/// Zakat nisab in grams of pure gold.
const double nisabGrams = 85;

/// Zakat rate.
const double zakatRate = 0.025;

/// Round half away from zero to [dp] decimals.
double roundTo(double x, [int dp = 2]) {
  var f = 1.0;
  for (var i = 0; i < dp; i++) {
    f *= 10;
  }
  final v = (x.abs() * f + 1e-9).roundToDouble() / f;
  return x < 0 ? -v : v;
}

/// Parse "461.11", "461,11", "14,342.21" or Arabic-Indic "٤٦١٫١١".
double parseNumber(Object value) {
  if (value is num) return value.toDouble();
  final b = StringBuffer();
  for (final r in value.toString().trim().runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      b.write(r - 0x0660);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      b.write(r - 0x06F0);
    } else if (r == 0x066B) {
      b.write('.');
    } else if (r == 0x066C || String.fromCharCode(r).trim().isEmpty) {
      continue;
    } else {
      b.writeCharCode(r);
    }
  }
  var s = b.toString();
  if (RegExp(r'^\d{1,3}(,\d{3})+(\.\d+)?$').hasMatch(s)) {
    s = s.replaceAll(',', '');
  } else {
    s = s.replaceFirst(',', '.');
  }
  final v = double.tryParse(s);
  if (v == null) throw FormatException('Not a number: $value');
  return v;
}

/// Normalise a unit name (English or Arabic) to g, kg, oz, tola or mithqal.
String normalizeUnit(String unit) {
  final u = unit.trim().toLowerCase();
  final k = _aliases[u] ?? u;
  if (!units.containsKey(k)) {
    throw ArgumentError('Unknown unit: $unit. Use g, kg, oz, tola or mithqal');
  }
  return k;
}

double _check(String name, double v, {bool allowZero = false}) {
  if (!v.isFinite || v < 0 || (!allowZero && v == 0)) {
    throw ArgumentError('$name must be ${allowZero ? 'non-negative' : 'positive'}');
  }
  return v;
}

/// Price ratio to 24K: fineness / 999 for the board karats, otherwise karat / 24.
double purity(num karat) {
  if (!(karat > 0 && karat <= 24)) {
    throw ArgumentError('karat must be between 0 and 24');
  }
  if (karat == 24) return 1.0;
  final f = karat == karat.roundToDouble() ? hallmarks[karat.toInt()] : null;
  return f == null ? karat / 24 : f / 999;
}

/// Convert a weight between units. Not rounded.
double convert(num value, String from, String to) =>
    _check('value', value.toDouble(), allowZero: true) *
    units[normalizeUnit(from)]! /
    units[normalizeUnit(to)]!;

/// Price per gram for a karat (unrounded).
double karatPrice(num price24, num karat) =>
    _check('price24', price24.toDouble()) * purity(karat);

/// One row of the karat table.
class PriceRow {
  const PriceRow(this.karat, this.hallmark, this.perGram, this.perTola, this.perOunce);
  final int karat;
  final int hallmark;
  final double perGram;
  final double perTola;
  final double perOunce;
}

/// Price table for 24/22/21/18/14K.
List<PriceRow> priceTable(num price24) => [
      for (final k in karats)
        PriceRow(
          k,
          hallmarks[k]!,
          roundTo(karatPrice(price24, k)),
          roundTo(karatPrice(price24, k) * units['tola']!),
          roundTo(karatPrice(price24, k) * units['oz']!),
        ),
    ];

/// How the making charge is expressed.
enum MakingType { perGram, percent, fixed }

/// Result of pricing a piece.
class ItemPrice {
  const ItemPrice({
    required this.grams,
    required this.pricePerGram,
    required this.metal,
    required this.making,
    required this.subtotal,
    required this.vatRate,
    required this.vat,
    required this.total,
  });
  final double grams, pricePerGram, metal, making, subtotal, vatRate, vat, total;
}

/// Price a piece: metal + making charge + VAT on both (default 5 %).
ItemPrice itemPrice({
  required num price24,
  required num weight,
  String unit = 'g',
  num karat = 24,
  num making = 0,
  MakingType makingType = MakingType.perGram,
  num vatRate = uaeVatRate,
}) {
  final grams = _check('weight', weight.toDouble()) * units[normalizeUnit(unit)]!;
  final perGram = karatPrice(price24, karat);
  final metal = grams * perGram;
  final m = _check('making', making.toDouble(), allowZero: true);
  final mk = switch (makingType) {
    MakingType.perGram => m * grams,
    MakingType.percent => metal * m / 100,
    MakingType.fixed => m,
  };
  final rate = _check('vatRate', vatRate.toDouble(), allowZero: true);
  final sub = metal + mk;
  return ItemPrice(
    grams: roundTo(grams, 4),
    pricePerGram: roundTo(perGram),
    metal: roundTo(metal),
    making: roundTo(mk),
    subtotal: roundTo(sub),
    vatRate: rate,
    vat: roundTo(sub * rate),
    total: roundTo(sub + sub * rate),
  );
}

/// A gold holding for zakat.
class GoldItem {
  const GoldItem(this.weight, {this.unit = 'g', this.karat = 24});
  final num weight;
  final String unit;
  final num karat;
}

/// Zakat result.
class ZakatResult {
  const ZakatResult(this.pureGrams, this.value, this.nisabValue, this.due, this.zakat);
  final double pureGrams, value, nisabValue, zakat;
  final bool due;
}

/// Zakat on gold: due when pure gold ≥ 85 g; 2.5 % of its value.
ZakatResult zakat(num price24, List<GoldItem> items) {
  final p = _check('price24', price24.toDouble());
  var pure = 0.0;
  for (final it in items) {
    pure += _check('weight', it.weight.toDouble(), allowZero: true) *
        units[normalizeUnit(it.unit)]! *
        purity(it.karat);
  }
  final value = pure * p;
  final due = pure + 1e-9 >= nisabGrams;
  return ZakatResult(roundTo(pure, 4), roundTo(value), roundTo(nisabGrams * p), due,
      due ? roundTo(value * zakatRate) : 0);
}

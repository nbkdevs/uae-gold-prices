import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/gold.dart';

/// App-wide settings: language and today's 24K price. Stored locally only.
class AppState extends ChangeNotifier {
  AppState(this._prefs)
    : ar = _prefs?.getBool('ar') ?? true,
      priceText = _prefs?.getString('price') ?? '',
      perOunce = _prefs?.getBool('perOunce') ?? false;

  final SharedPreferences? _prefs;
  bool ar;
  String priceText;
  bool perOunce;

  /// 24K price per gram, or null when not entered / invalid.
  double? get price24 {
    if (priceText.trim().isEmpty) return null;
    try {
      final v = parseNumber(priceText);
      if (v <= 0) return null;
      return perOunce ? v / units['oz']! : v;
    } catch (_) {
      return null;
    }
  }

  void toggleLang() {
    ar = !ar;
    _prefs?.setBool('ar', ar);
    notifyListeners();
  }

  void setPrice(String s) {
    priceText = s;
    _prefs?.setString('price', s);
    notifyListeners();
  }

  void setPerOunce(bool v) {
    perOunce = v;
    _prefs?.setBool('perOunce', v);
    notifyListeners();
  }
}

/// Parses a user-entered number; null if empty or invalid.
double? tryNum(String s) {
  if (s.trim().isEmpty) return null;
  try {
    return parseNumber(s);
  } catch (_) {
    return null;
  }
}

String money(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final buf = StringBuffer();
  final digits = parts[0].replaceFirst('-', '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${v < 0 ? '-' : ''}$buf.${parts[1]}';
}

String num4(double v) {
  var s = v.toStringAsFixed(4);
  s = s.replaceFirst(RegExp(r'0+$'), '');
  return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
}

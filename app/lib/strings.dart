/// Arabic (default) and English UI strings.
class S {
  S(this.ar);
  final bool ar;
  String _(String a, String e) => ar ? a : e;

  String get title => _('حاسبة قيمة الذهب', 'Gold Value Calculator');
  String get toggle => _('English', 'العربية');
  String get price => _('سعر الذهب عيار 24 اليوم', "Today's 24K gold price");
  String get perGramOpt => _('لكل جرام', 'per gram');
  String get perOzOpt => _('لكل أونصة', 'per ounce');
  String get priceHint => _(
    'أدخل سعر اليوم بالدرهم. يُحفظ على جهازك فقط.',
    "Enter today's price in AED. Saved on this device only.",
  );
  String get needPrice =>
      _('أدخل سعر جرام الذهب عيار 24 أولاً.', 'Enter the 24K price first.');
  String get tTable => _('العيارات', 'Karats');
  String get tItem => _('سعر القطعة', 'Item price');
  String get tZakat => _('الزكاة', 'Zakat');
  String get tConv => _('الوحدات', 'Units');
  String get karat => _('العيار', 'Karat');
  String get perGram => _('الجرام', 'Gram');
  String get perTola => _('التولة', 'Tola');
  String get perOunce => _('الأونصة', 'Ounce');
  String get weight => _('الوزن', 'Weight');
  String get unit => _('الوحدة', 'Unit');
  String get making => _('المصنعية', 'Making charge');
  String get mPerGram => _('درهم/جرام', 'AED/gram');
  String get mPercent => _('نسبة %', 'Percent');
  String get mFixed => _('مبلغ ثابت', 'Fixed');
  String get vatOn => _('إضافة ضريبة القيمة المضافة 5%', 'Add 5% VAT');
  String get vatHint => _(
    'ذهب الاستثمار (99% فأكثر) معفى عادةً',
    'Investment gold (99%+) is usually zero-rated',
  );
  String get metal => _('قيمة الذهب', 'Gold value');
  String get vat => _('ضريبة القيمة المضافة', 'VAT');
  String get total => _('الإجمالي', 'Total');
  String get addItem => _('إضافة قطعة', 'Add item');
  String get pure => _('الذهب الخالص', 'Pure gold');
  String get value => _('قيمة الذهب الخالص', 'Pure gold value');
  String get nisab => _('قيمة النصاب (85 جرام)', 'Nisab value (85 g)');
  String get due => _('تجب الزكاة', 'Zakat is due');
  String get notDue => _('أقل من النصاب: لا زكاة', 'Below nisab: no zakat due');
  String get zakatOut => _('الزكاة المستحقة (2.5%)', 'Zakat due (2.5%)');
  String get value2 => _('القيمة', 'Value');
  String get from => _('من', 'From');
  String get to => _('إلى', 'To');
  String get result => _('النتيجة', 'Result');
  String get cur => _('د.إ', 'AED');
  String get gUnit => _('جم', 'g');
  String get note => _(
    'النتائج تقديرية. تختلف أسعار المحلات وأحكام الضريبة على ذهب الاستثمار وآراء الفقهاء في الزكاة.',
    'Estimates only. Shop prices, VAT on investment gold and zakat rulings vary.',
  );
  String get about => _('حول التطبيق', 'About');
  String get aboutText => _(
    'حاسبة مجانية تعمل دون إنترنت: أسعار العيارات بالجرام والتولة والأونصة، وسعر القطعة مع المصنعية والضريبة، وزكاة الذهب، وتحويل الوحدات. لا يجمع التطبيق أي بيانات.',
    'A free offline calculator: karat prices per gram, tola and ounce, item price with making charge and VAT, zakat on gold and unit conversion. The app collects no data.',
  );
  String get liveRates =>
      _('أسعار الذهب المباشرة في الإمارات:', 'Live UAE gold rates:');
  String get privacy => _('سياسة الخصوصية', 'Privacy policy');
  String get source => _('الشيفرة المصدرية', 'Source code');
  String get version => _('الإصدار', 'Version');
  String get invalid => _('قيمة غير صالحة', 'Invalid value');
  String unitShort(String u) => switch (u) {
    'g' => _('جم', 'g'),
    'kg' => _('كجم', 'kg'),
    'oz' => _('أونصة', 'oz'),
    'tola' => _('تولة', 'tola'),
    _ => _('مثقال', 'mithqal'),
  };
  String unitName(String u) => switch (u) {
    'g' => _('جرام', 'gram'),
    'kg' => _('كيلوجرام', 'kilogram'),
    'oz' => _('أونصة', 'troy ounce'),
    'tola' => _('تولة', 'tola'),
    _ => _('مثقال', 'mithqal'),
  };
}

# frozen_string_literal: true

# Gold value maths for the UAE market: karat prices, unit conversion, making
# charges, VAT and zakat. Pure Ruby, no network. Pass today's 24K price per
# gram (for example from https://uaegoldprices.ae/).
module UaeGoldCalculator
  VERSION = "1.0.0"
  KARATS = [24, 22, 21, 18, 14].freeze
  # Fineness per mille used by UAE gold price boards (and uaegoldprices.ae).
  # A karat's price = 24K price x fineness / 999; other karats use karat / 24.
  HALLMARKS = { 24 => 999, 22 => 914, 21 => 874, 18 => 749, 16 => 666, 14 => 583 }.freeze
  UNITS = { "g" => 1.0, "kg" => 1000.0, "oz" => 31.1034768, "tola" => 11.6638038, "mithqal" => 4.25 }.freeze
  ALIASES = {
    "gram" => "g", "grams" => "g", "gr" => "g", "جرام" => "g", "غرام" => "g",
    "kilogram" => "kg", "kilo" => "kg", "كيلو" => "kg",
    "ounce" => "oz", "ozt" => "oz", "troy_ounce" => "oz", "troy-ounce" => "oz", "أونصة" => "oz", "اونصة" => "oz",
    "tolas" => "tola", "تولة" => "tola", "mithqals" => "mithqal", "misqal" => "mithqal", "مثقال" => "mithqal"
  }.freeze
  UAE_VAT_RATE = 0.05
  NISAB_GRAMS = 85.0
  ZAKAT_RATE = 0.025

  module_function

  # Round half away from zero.
  def round_money(x, dp = 2)
    f = 10.0**dp
    v = ((x.abs * f) + 1e-9).round / f
    x.negative? ? -v : v
  end

  # Parse "461.11", "461,11", "14,342.21" or Arabic-Indic "٤٦١٫١١".
  def parse_number(value)
    return value.to_f if value.is_a?(Numeric)

    s = value.to_s.strip.tr("٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹٫", "01234567890123456789.").delete("٬").gsub(/\s/, "")
    s = s.match?(/\A\d{1,3}(,\d{3})+(\.\d+)?\z/) ? s.delete(",") : s.sub(",", ".")
    Float(s)
  rescue ArgumentError, TypeError
    raise ArgumentError, "not a number: #{value}"
  end

  def normalize_unit(unit)
    u = (unit || "g").to_s.strip.downcase
    k = ALIASES.fetch(u, u)
    raise ArgumentError, "unknown unit: #{unit}. Use g, kg, oz, tola or mithqal" unless UNITS.key?(k)

    k
  end

  def check(name, v, allow_zero: false)
    if !v.finite? || v.negative? || (!allow_zero && v.zero?)
      raise ArgumentError, "#{name} must be #{allow_zero ? 'non-negative' : 'positive'}"
    end

    v
  end

  def purity(karat)
    k = karat.to_f
    raise ArgumentError, "karat must be between 0 and 24" unless k.positive? && k <= 24
    return 1.0 if k == 24

    f = k == k.floor ? HALLMARKS[k.to_i] : nil
    f ? f / 999.0 : k / 24
  end

  def convert(value, from, to)
    check("value", parse_number(value), allow_zero: true) * UNITS[normalize_unit(from)] / UNITS[normalize_unit(to)]
  end

  def karat_price(price24, karat)
    check("price24", parse_number(price24)) * purity(karat)
  end

  def price_table(price24)
    KARATS.map do |k|
      g = karat_price(price24, k)
      { karat: k, hallmark: HALLMARKS[k], per_gram: round_money(g),
        per_tola: round_money(g * UNITS["tola"]), per_ounce: round_money(g * UNITS["oz"]) }
    end
  end

  def item_price(price24:, weight:, unit: "g", karat: 24, making: 0, making_type: :per_gram, vat_rate: UAE_VAT_RATE)
    grams = check("weight", parse_number(weight)) * UNITS[normalize_unit(unit)]
    per_gram = karat_price(price24, karat)
    metal = grams * per_gram
    m = check("making", parse_number(making), allow_zero: true)
    mk = case making_type.to_sym
         when :per_gram then m * grams
         when :percent then metal * m / 100
         when :fixed then m
         else raise ArgumentError, "making_type must be per_gram, percent or fixed"
         end
    rate = check("vat_rate", parse_number(vat_rate), allow_zero: true)
    sub = metal + mk
    { grams: round_money(grams, 4), price_per_gram: round_money(per_gram), metal: round_money(metal),
      making: round_money(mk), subtotal: round_money(sub), vat_rate: rate, vat: round_money(sub * rate),
      total: round_money(sub + (sub * rate)) }
  end

  # items: [{ weight: 100, karat: 21, unit: "g" }]
  def zakat(price24, items)
    p = check("price24", parse_number(price24))
    pure = items.sum do |it|
      check("weight", parse_number(it[:weight]), allow_zero: true) * UNITS[normalize_unit(it[:unit])] * purity(it.fetch(:karat, 24))
    end
    value = pure * p
    due = pure + 1e-9 >= NISAB_GRAMS
    { pure_grams: round_money(pure, 4), value: round_money(value), nisab_value: round_money(NISAB_GRAMS * p),
      due: due, zakat: due ? round_money(value * ZAKAT_RATE) : 0.0 }
  end
end

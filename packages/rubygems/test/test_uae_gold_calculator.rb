# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/uae_gold_calculator"

class TestUaeGoldCalculator < Minitest::Test
  G = UaeGoldCalculator

  def test_table
    t = G.price_table(461.11)
    assert_equal [461.11, 422.68, 403.47, 345.83, 268.98], t.map { |r| r[:per_gram] }
    assert_equal 14_342.12, t.first[:per_ounce]
  end

  def test_convert
    assert_equal 11.6638038, G.round_money(G.convert(1, "tola", "g"), 7)
    assert_equal 42.5, G.round_money(G.convert(10, "مثقال", "g"))
    assert_raises(ArgumentError) { G.convert(1, "stone", "g") }
  end

  def test_item
    r = G.item_price(price24: 461.11, weight: 10, karat: 21, making: 30)
    assert_equal [4034.71, 300.0, 216.74, 4551.45], r.values_at(:metal, :making, :vat, :total)
    assert_equal 12_441.39, G.item_price(price24: 400, weight: 1, unit: "oz", vat_rate: 0)[:total]
    assert_equal 1650.0, G.item_price(price24: 400, weight: 5, karat: 18, making: 10, making_type: :percent, vat_rate: 0)[:total]
    assert_equal 1599.0, G.item_price(price24: 400, weight: 5, karat: 18, making: 99, making_type: :fixed, vat_rate: 0)[:total]
  end

  def test_zakat
    z = G.zakat(461.11, [{ weight: 100, karat: 21 }])
    assert z[:due]
    assert_equal 87.5, z[:pure_grams]
    assert_equal 1008.68, z[:zakat]
    n = G.zakat(461.11, [{ weight: 90, karat: 18 }])
    refute n[:due]
    assert_equal 0.0, n[:zakat]
  end

  def test_parse
    assert_equal 461.11, G.parse_number("٤٦١٫١١")
    assert_equal 461.11, G.parse_number("461,11")
    assert_equal 14_342.21, G.parse_number("14,342.21")
    assert_raises(ArgumentError) { G.karat_price(-1, 22) }
  end
end

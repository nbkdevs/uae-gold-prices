# frozen_string_literal: true

require_relative "lib/uae_gold_calculator"

Gem::Specification.new do |s|
  s.name        = "uae-gold-calculator"
  s.version     = UaeGoldCalculator::VERSION
  s.summary     = "Gold value calculator for the UAE: karat prices, making charges, 5% VAT and zakat."
  s.description = "Price gold in AED from today's 24K rate: 24/22/21/18/14K per gram, tola and troy ounce, " \
                  "making charges (per gram, percent or fixed), 5% VAT and zakat against the 85 g nisab. " \
                  "Accepts Arabic-Indic digits and Arabic unit names. Library + CLI, no dependencies."
  s.authors     = ["UAE Gold Prices"]
  s.license     = "MIT"
  s.homepage    = "https://uaegoldprices.ae/"
  s.files       = Dir["lib/**/*.rb", "exe/*", "README.md", "LICENSE"]
  s.bindir      = "exe"
  s.executables = ["uae-gold-calculator"]
  s.required_ruby_version = ">= 2.7"
  s.metadata = {
    "homepage_uri" => "https://uaegoldprices.ae/",
    "source_code_uri" => "https://github.com/nbkdevs/uae-gold-prices",
    "bug_tracker_uri" => "https://github.com/nbkdevs/uae-gold-prices/issues",
    "rubygems_mfa_required" => "true"
  }
end

<?php

declare(strict_types=1);

namespace UaeGoldPrices\GoldCalculator;

/**
 * Gold value maths for the UAE market: karat prices, unit conversion, making
 * charges, VAT and zakat. No network. Pass today's 24K price per gram
 * (for example from https://uaegoldprices.ae/).
 */
final class Gold
{
    public const VERSION = '1.0.0';
    public const KARATS = [24, 22, 21, 18, 14];
    public const HALLMARKS = [24 => 999, 22 => 916, 21 => 875, 18 => 750, 14 => 585];
    public const UNITS = ['g' => 1.0, 'kg' => 1000.0, 'oz' => 31.1034768, 'tola' => 11.6638038, 'mithqal' => 4.25];
    public const ALIASES = [
        'gram' => 'g', 'grams' => 'g', 'gr' => 'g', 'جرام' => 'g', 'غرام' => 'g',
        'kilogram' => 'kg', 'kilo' => 'kg', 'كيلو' => 'kg',
        'ounce' => 'oz', 'ozt' => 'oz', 'troy_ounce' => 'oz', 'troy-ounce' => 'oz', 'أونصة' => 'oz', 'اونصة' => 'oz',
        'tolas' => 'tola', 'تولة' => 'tola', 'mithqals' => 'mithqal', 'misqal' => 'mithqal', 'مثقال' => 'mithqal',
    ];
    public const UAE_VAT_RATE = 0.05;
    public const NISAB_GRAMS = 85.0;
    public const ZAKAT_RATE = 0.025;

    /** Round half away from zero. */
    public static function round(float $x, int $dp = 2): float
    {
        $f = 10 ** $dp;
        $v = \round(\abs($x) * $f + 1e-9, 0, PHP_ROUND_HALF_UP) / $f;
        return $x < 0 ? -$v : $v;
    }

    /** Parse "461.11", "461,11", "14,342.21" or Arabic-Indic "٤٦١٫١١". */
    public static function parseNumber(string|int|float $value): float
    {
        if (\is_int($value) || \is_float($value)) {
            return (float) $value;
        }
        $map = ['٫' => '.', '٬' => ''];
        foreach (['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'] as $i => $d) { $map[$d] = (string) $i; }
        foreach (['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'] as $i => $d) { $map[$d] = (string) $i; }
        $s = (string) \preg_replace('/\s+/u', '', \strtr(\trim($value), $map));
        $s = \preg_match('/^\d{1,3}(,\d{3})+(\.\d+)?$/', $s) ? \str_replace(',', '', $s) : (string) \preg_replace('/,/', '.', $s, 1);
        if (!\is_numeric($s)) {
            throw new \InvalidArgumentException("Not a number: $value");
        }
        return (float) $s;
    }

    public static function normalizeUnit(string $unit): string
    {
        $u = \mb_strtolower(\trim($unit));
        $k = self::ALIASES[$u] ?? $u;
        if (!isset(self::UNITS[$k])) {
            throw new \InvalidArgumentException("Unknown unit: $unit. Use g, kg, oz, tola or mithqal");
        }
        return $k;
    }

    private static function check(string $name, float $v, bool $allowZero = false): float
    {
        if (!\is_finite($v) || $v < 0 || (!$allowZero && $v == 0.0)) {
            throw new \InvalidArgumentException("$name must be " . ($allowZero ? 'non-negative' : 'positive'));
        }
        return $v;
    }

    public static function purity(float $karat): float
    {
        if (!($karat > 0 && $karat <= 24)) {
            throw new \InvalidArgumentException('karat must be between 0 and 24');
        }
        return $karat / 24;
    }

    public static function convert(float $value, string $from, string $to): float
    {
        return self::check('value', $value, true) * self::UNITS[self::normalizeUnit($from)] / self::UNITS[self::normalizeUnit($to)];
    }

    public static function karatPrice(float $price24, float $karat): float
    {
        return self::check('price24', $price24) * self::purity($karat);
    }

    /** @return list<array{karat:int,hallmark:int,perGram:float,perTola:float,perOunce:float}> */
    public static function priceTable(float $price24): array
    {
        $rows = [];
        foreach (self::KARATS as $k) {
            $g = self::karatPrice($price24, $k);
            $rows[] = ['karat' => $k, 'hallmark' => self::HALLMARKS[$k], 'perGram' => self::round($g),
                'perTola' => self::round($g * self::UNITS['tola']), 'perOunce' => self::round($g * self::UNITS['oz'])];
        }
        return $rows;
    }

    /** @return array<string,float> */
    public static function itemPrice(float $price24, float $weight, string $unit = 'g', float $karat = 24,
        float $making = 0, string $makingType = 'per_gram', float $vatRate = self::UAE_VAT_RATE): array
    {
        $grams = self::check('weight', $weight) * self::UNITS[self::normalizeUnit($unit)];
        $perGram = self::karatPrice($price24, $karat);
        $metal = $grams * $perGram;
        $m = self::check('making', $making, true);
        $mk = match ($makingType) {
            'per_gram' => $m * $grams,
            'percent' => $metal * $m / 100,
            'fixed' => $m,
            default => throw new \InvalidArgumentException('makingType must be per_gram, percent or fixed'),
        };
        $rate = self::check('vatRate', $vatRate, true);
        $sub = $metal + $mk;
        return ['grams' => self::round($grams, 4), 'pricePerGram' => self::round($perGram), 'metal' => self::round($metal),
            'making' => self::round($mk), 'subtotal' => self::round($sub), 'vatRate' => $rate,
            'vat' => self::round($sub * $rate), 'total' => self::round($sub + $sub * $rate)];
    }

    /**
     * @param list<array{weight:float|int,unit?:string,karat?:float|int}> $items
     * @return array{pureGrams:float,value:float,nisabValue:float,due:bool,zakat:float}
     */
    public static function zakat(float $price24, array $items): array
    {
        $p = self::check('price24', $price24);
        $pure = 0.0;
        foreach ($items as $it) {
            $pure += self::check('weight', (float) $it['weight'], true) * self::UNITS[self::normalizeUnit($it['unit'] ?? 'g')]
                * self::purity((float) ($it['karat'] ?? 24));
        }
        $value = $pure * $p;
        $due = $pure + 1e-9 >= self::NISAB_GRAMS;
        return ['pureGrams' => self::round($pure, 4), 'value' => self::round($value),
            'nisabValue' => self::round(self::NISAB_GRAMS * $p), 'due' => $due,
            'zakat' => $due ? self::round($value * self::ZAKAT_RATE) : 0.0];
    }
}

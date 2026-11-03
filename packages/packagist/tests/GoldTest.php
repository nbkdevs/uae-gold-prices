<?php

declare(strict_types=1);

namespace UaeGoldPrices\GoldCalculator\Tests;

use PHPUnit\Framework\TestCase;
use UaeGoldPrices\GoldCalculator\Gold;

final class GoldTest extends TestCase
{
    public function testTable(): void
    {
        $t = Gold::priceTable(461.11);
        $this->assertSame([461.11, 421.88, 403.41, 345.72, 269.10], array_column($t, 'perGram'));
        $this->assertSame(14342.12, $t[0]['perOunce']);
    }

    public function testConvert(): void
    {
        $this->assertSame(11.6638038, Gold::round(Gold::convert(1, 'tola', 'g'), 7));
        $this->assertSame(42.5, Gold::round(Gold::convert(10, 'مثقال', 'g')));
        $this->expectException(\InvalidArgumentException::class);
        Gold::convert(1, 'stone', 'g');
    }

    public function testItem(): void
    {
        $r = Gold::itemPrice(461.11, 10, 'g', 21, 30);
        $this->assertSame([4034.14, 300.0, 216.71, 4550.84], [$r['metal'], $r['making'], $r['vat'], $r['total']]);
        $this->assertSame(12441.39, Gold::itemPrice(400, 1, 'oz', 24, 0, 'per_gram', 0)['total']);
        $this->assertSame(1649.45, Gold::itemPrice(400, 5, 'g', 18, 10, 'percent', 0)['total']);
        $this->assertSame(1598.5, Gold::itemPrice(400, 5, 'g', 18, 99, 'fixed', 0)['total']);
    }

    public function testZakat(): void
    {
        $z = Gold::zakat(461.11, [['weight' => 100, 'karat' => 21]]);
        $this->assertTrue($z['due']);
        $this->assertSame(87.4875, $z['pureGrams']);
        $this->assertSame(1008.53, $z['zakat']);
        $n = Gold::zakat(461.11, [['weight' => 90, 'karat' => 18]]);
        $this->assertFalse($n['due']);
        $this->assertSame(0.0, $n['zakat']);
    }

    public function testParse(): void
    {
        $this->assertSame(461.11, Gold::parseNumber('٤٦١٫١١'));
        $this->assertSame(461.11, Gold::parseNumber('461,11'));
        $this->assertSame(14342.21, Gold::parseNumber('14,342.21'));
        $this->expectException(\InvalidArgumentException::class);
        Gold::karatPrice(-1, 22);
    }

    public function testBoardFineness(): void
    {
        $this->assertSame([461.74, 422.45, 403.96, 346.19, 269.46], array_column(Gold::priceTable(461.74), 'perGram'));
        $this->assertSame(666 / 999, Gold::purity(16));
        $this->assertSame(9 / 24, Gold::purity(9));
    }
}

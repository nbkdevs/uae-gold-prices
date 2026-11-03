using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace UaeGoldPrices.GoldCalculator;

/// <summary>How the making charge is expressed.</summary>
public enum MakingType { PerGram, Percent, Fixed }

/// <summary>One row of the karat price table.</summary>
public sealed record PriceRow(int Karat, int Hallmark, double PerGram, double PerTola, double PerOunce);

/// <summary>Price of a piece of gold.</summary>
public sealed record ItemPrice(double Grams, double PricePerGram, double Metal, double Making,
    double Subtotal, double VatRate, double Vat, double Total);

/// <summary>A gold holding for zakat.</summary>
public sealed record GoldItem(double Weight, string Unit = "g", double Karat = 24);

/// <summary>Zakat result.</summary>
public sealed record ZakatResult(double PureGrams, double Value, double NisabValue, bool Due, double Zakat);

/// <summary>
/// Gold maths for the UAE market. Pass today's 24K price per gram
/// (for example from https://uaegoldprices.ae/).
/// </summary>
public static class Gold
{
    public static readonly int[] Karats = { 24, 22, 21, 18, 14 };
    public static readonly IReadOnlyDictionary<int, int> Hallmarks =
        new Dictionary<int, int> { [24] = 999, [22] = 914, [21] = 874, [18] = 749, [16] = 666, [14] = 583 };
    public static readonly IReadOnlyDictionary<string, double> Units = new Dictionary<string, double>
    { ["g"] = 1, ["kg"] = 1000, ["oz"] = 31.1034768, ["tola"] = 11.6638038, ["mithqal"] = 4.25 };
    private static readonly Dictionary<string, string> Aliases = new()
    {
        ["gram"] = "g", ["grams"] = "g", ["gr"] = "g", ["جرام"] = "g", ["غرام"] = "g",
        ["kilogram"] = "kg", ["kilo"] = "kg", ["كيلو"] = "kg",
        ["ounce"] = "oz", ["ozt"] = "oz", ["troy_ounce"] = "oz", ["troy-ounce"] = "oz", ["أونصة"] = "oz", ["اونصة"] = "oz",
        ["tolas"] = "tola", ["تولة"] = "tola", ["mithqals"] = "mithqal", ["misqal"] = "mithqal", ["مثقال"] = "mithqal",
    };
    public const double UaeVatRate = 0.05;
    public const double NisabGrams = 85;
    public const double ZakatRate = 0.025;

    /// <summary>Round half away from zero.</summary>
    public static double Round(double x, int dp = 2)
    {
        var f = Math.Pow(10, dp);
        var v = Math.Round(Math.Abs(x) * f + 1e-9, MidpointRounding.AwayFromZero) / f;
        return x < 0 ? -v : v;
    }

    /// <summary>Parse "461.11", "461,11", "14,342.21" or Arabic-Indic digits.</summary>
    public static double ParseNumber(string s)
    {
        var b = new StringBuilder();
        foreach (var c in s.Trim())
        {
            if (c >= '\u0660' && c <= '\u0669') b.Append((char)('0' + (c - '\u0660')));
            else if (c >= '\u06F0' && c <= '\u06F9') b.Append((char)('0' + (c - '\u06F0')));
            else if (c == '\u066B') b.Append('.');
            else if (c == '\u066C' || char.IsWhiteSpace(c)) continue;
            else b.Append(c);
        }
        var t = b.ToString();
        t = Regex.IsMatch(t, @"^\d{1,3}(,\d{3})+(\.\d+)?$") ? t.Replace(",", "") : new Regex(",").Replace(t, ".", 1);
        if (!double.TryParse(t, NumberStyles.Float, CultureInfo.InvariantCulture, out var v))
            throw new FormatException($"Not a number: {s}");
        return v;
    }

    public static string NormalizeUnit(string unit)
    {
        var u = unit.Trim().ToLowerInvariant();
        var k = Aliases.TryGetValue(u, out var a) ? a : u;
        if (!Units.ContainsKey(k)) throw new ArgumentException($"Unknown unit: {unit}. Use g, kg, oz, tola or mithqal");
        return k;
    }

    private static double Check(string name, double v, bool allowZero = false)
    {
        if (double.IsNaN(v) || double.IsInfinity(v) || v < 0 || (!allowZero && v == 0))
            throw new ArgumentOutOfRangeException(name, $"{name} must be {(allowZero ? "non-negative" : "positive")}");
        return v;
    }

    public static double Purity(double karat)
    {
        if (!(karat > 0 && karat <= 24)) throw new ArgumentOutOfRangeException(nameof(karat), "karat must be between 0 and 24");
        if (karat == 24) return 1.0;
        // UAE board fineness (24K 999, 22K 914, 21K 874, 18K 749, 16K 666, 14K 583): price = 24K x fineness / 999.
        if (karat == Math.Floor(karat) && Hallmarks.TryGetValue((int)karat, out var f)) return f / 999.0;
        return karat / 24;
    }

    public static double Convert(double value, string from, string to) =>
        Check("value", value, true) * Units[NormalizeUnit(from)] / Units[NormalizeUnit(to)];

    public static double KaratPrice(double price24, double karat) => Check("price24", price24) * Purity(karat);

    public static IReadOnlyList<PriceRow> PriceTable(double price24) => Karats.Select(k =>
    {
        var g = KaratPrice(price24, k);
        return new PriceRow(k, Hallmarks[k], Round(g), Round(g * Units["tola"]), Round(g * Units["oz"]));
    }).ToList();

    public static ItemPrice Item(double price24, double weight, string unit = "g", double karat = 24,
        double making = 0, MakingType makingType = MakingType.PerGram, double vatRate = UaeVatRate)
    {
        var grams = Check("weight", weight) * Units[NormalizeUnit(unit)];
        var perGram = KaratPrice(price24, karat);
        var metal = grams * perGram;
        var m = Check("making", making, true);
        var mk = makingType switch { MakingType.PerGram => m * grams, MakingType.Percent => metal * m / 100, _ => m };
        var rate = Check("vatRate", vatRate, true);
        var sub = metal + mk;
        return new ItemPrice(Round(grams, 4), Round(perGram), Round(metal), Round(mk), Round(sub), rate,
            Round(sub * rate), Round(sub + sub * rate));
    }

    public static ZakatResult Zakat(double price24, IEnumerable<GoldItem> items)
    {
        var p = Check("price24", price24);
        var pure = items.Sum(i => Check("weight", i.Weight, true) * Units[NormalizeUnit(i.Unit)] * Purity(i.Karat));
        var value = pure * p;
        var due = pure + 1e-9 >= NisabGrams;
        return new ZakatResult(Round(pure, 4), Round(value), Round(NisabGrams * p), due, due ? Round(value * ZakatRate) : 0);
    }
}

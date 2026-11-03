using UaeGoldPrices.GoldCalculator;

var pos = new List<string>();
var opt = new Dictionary<string, string>();
for (var i = 0; i < args.Length; i++)
{
    if (args[i].StartsWith("--")) opt[args[i][2..]] = i + 1 < args.Length ? args[++i] : "";
    else pos.Add(args[i]);
}
var ar = opt.GetValueOrDefault("lang") == "ar";
var cur = ar ? "د.إ" : "AED";
double N(string k, double? d = null) => opt.TryGetValue(k, out var v) ? Gold.ParseNumber(v) : d ?? throw new ArgumentException($"--{k} is required");
Console.OutputEncoding = System.Text.Encoding.UTF8;
try
{
    switch (pos.FirstOrDefault())
    {
        case "convert":
            Console.WriteLine(Gold.Round(Gold.Convert(Gold.ParseNumber(pos[1]), pos[2], pos[3]), 4));
            break;
        case "table":
            Console.WriteLine(ar ? "العيار\tسعر الجرام\tسعر التولة\tسعر الأونصة" : "Karat\tPer gram\tPer tola\tPer ounce");
            foreach (var r in Gold.PriceTable(N("price"))) Console.WriteLine($"{r.Karat}K ({r.Hallmark})\t{r.PerGram:F2}\t{r.PerTola:F2}\t{r.PerOunce:F2}");
            break;
        case "item":
            var mt = opt.GetValueOrDefault("making-type") switch { "percent" => MakingType.Percent, "fixed" => MakingType.Fixed, _ => MakingType.PerGram };
            var it = Gold.Item(N("price"), N("weight"), opt.GetValueOrDefault("unit") ?? "g", N("karat", 24), N("making", 0), mt, N("vat", Gold.UaeVatRate));
            Console.WriteLine($"{(ar ? "قيمة الذهب" : "Gold value")}: {it.Metal:F2} {cur}");
            Console.WriteLine($"{(ar ? "المصنعية" : "Making charge")}: {it.Making:F2} {cur}");
            Console.WriteLine($"{(ar ? "ضريبة القيمة المضافة" : "VAT")}: {it.Vat:F2} {cur}");
            Console.WriteLine($"{(ar ? "الإجمالي" : "Total")}: {it.Total:F2} {cur}");
            break;
        case "zakat":
            var z = Gold.Zakat(N("price"), new[] { new GoldItem(N("weight"), opt.GetValueOrDefault("unit") ?? "g", N("karat", 24)) });
            Console.WriteLine(z.Due ? $"{(ar ? "الزكاة المستحقة" : "Zakat due")}: {z.Zakat:F2} {cur}" : (ar ? "أقل من النصاب: لا زكاة" : "Below nisab: no zakat due"));
            break;
        default:
            Console.WriteLine("uae-gold-calculator 1.0.0: table | item | convert | zakat (see README). Today's 24K price: https://uaegoldprices.ae/");
            break;
    }
    return 0;
}
catch (Exception e)
{
    Console.Error.WriteLine($"Error: {e.Message}");
    return 1;
}

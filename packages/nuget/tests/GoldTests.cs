using UaeGoldPrices.GoldCalculator;
using Xunit;

public class GoldTests
{
    [Fact]
    public void Table() {
        var t = Gold.PriceTable(461.11);
        Assert.Equal(new[] { 461.11, 421.88, 403.41, 345.72, 269.10 }, t.Select(r => r.PerGram).ToArray());
        Assert.Equal(14342.12, t[0].PerOunce);
    }
    [Fact]
    public void Conversions() {
        Assert.Equal(11.6638038, Gold.Round(Gold.Convert(1, "tola", "g"), 7));
        Assert.Equal(42.5, Gold.Round(Gold.Convert(10, "مثقال", "g")));
        Assert.Throws<ArgumentException>(() => Gold.Convert(1, "stone", "g"));
    }
    [Fact]
    public void Items() {
        var r = Gold.Item(461.11, 10, karat: 21, making: 30);
        Assert.Equal((4034.14, 300.0, 216.71, 4550.84), (r.Metal, r.Making, r.Vat, r.Total));
        Assert.Equal(12441.39, Gold.Item(400, 1, "oz", vatRate: 0).Total);
        Assert.Equal(1649.45, Gold.Item(400, 5, karat: 18, making: 10, makingType: MakingType.Percent, vatRate: 0).Total);
        Assert.Equal(1598.5, Gold.Item(400, 5, karat: 18, making: 99, makingType: MakingType.Fixed, vatRate: 0).Total);
    }
    [Fact]
    public void Zakat() {
        var z = Gold.Zakat(461.11, new[] { new GoldItem(100, Karat: 21) });
        Assert.True(z.Due); Assert.Equal(87.4875, z.PureGrams); Assert.Equal(1008.53, z.Zakat);
        var n = Gold.Zakat(461.11, new[] { new GoldItem(90, Karat: 18) });
        Assert.False(n.Due); Assert.Equal(0, n.Zakat);
    }
    [Fact]
    public void Parsing() {
        Assert.Equal(461.11, Gold.ParseNumber("٤٦١٫١١"));
        Assert.Equal(461.11, Gold.ParseNumber("461,11"));
        Assert.Equal(14342.21, Gold.ParseNumber("14,342.21"));
        Assert.Throws<ArgumentOutOfRangeException>(() => Gold.KaratPrice(-1, 22));
    }

    [Fact]
    public void BoardFineness()
    {
        Assert.Equal(new[] { 461.74, 422.45, 403.96, 346.19, 269.46 }, Gold.PriceTable(461.74).Select(r => r.PerGram).ToArray());
        Assert.Equal(666 / 999.0, Gold.Purity(16));
        Assert.Equal(9 / 24.0, Gold.Purity(9));
    }
}

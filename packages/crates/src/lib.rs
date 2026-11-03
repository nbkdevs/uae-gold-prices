//! Gold value maths for the UAE market: karat prices, unit conversion, making
//! charges, VAT and zakat. Pure functions, no network. Pass today's 24K price
//! per gram (for example from <https://uaegoldprices.ae/>).
//!
//! ```
//! use uae_gold_calculator::{item_price, MakingType};
//! let r = item_price(461.11, 10.0, "g", 21.0, 30.0, MakingType::PerGram, 0.05).unwrap();
//! assert_eq!(r.total, 4550.84);
//! ```

/// Karats in the default table.
pub const KARATS: [f64; 5] = [24.0, 22.0, 21.0, 18.0, 14.0];
/// UAE standard VAT rate.
pub const UAE_VAT_RATE: f64 = 0.05;
/// Zakat nisab in grams of pure gold.
pub const NISAB_GRAMS: f64 = 85.0;
/// Zakat rate.
pub const ZAKAT_RATE: f64 = 0.025;

/// Error type.
#[derive(Debug, Clone, PartialEq)]
pub struct GoldError(pub String);
impl std::fmt::Display for GoldError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result { f.write_str(&self.0) }
}
impl std::error::Error for GoldError {}
type R<T> = Result<T, GoldError>;
fn err<T>(m: &str) -> R<T> { Err(GoldError(m.to_string())) }

/// Round half away from zero to `dp` decimals.
pub fn round(x: f64, dp: i32) -> f64 {
    let f = 10f64.powi(dp);
    let v = ((x.abs() * f) + 1e-9).round() / f;
    if x < 0.0 { -v } else { v }
}

/// Grams in one unit (g, kg, oz = troy ounce, tola, mithqal; Arabic names accepted).
pub fn unit_grams(unit: &str) -> R<f64> {
    match unit.trim().to_lowercase().as_str() {
        "g" | "gram" | "grams" | "gr" | "جرام" | "غرام" => Ok(1.0),
        "kg" | "kilogram" | "kilo" | "كيلو" => Ok(1000.0),
        "oz" | "ounce" | "ozt" | "troy_ounce" | "troy-ounce" | "أونصة" | "اونصة" => Ok(31.1034768),
        "tola" | "tolas" | "تولة" => Ok(11.6638038),
        "mithqal" | "misqal" | "مثقال" => Ok(4.25),
        _ => err("unknown unit: use g, kg, oz, tola or mithqal"),
    }
}

/// Fineness per mille used by UAE gold price boards (and uaegoldprices.ae):
/// 24K 999, 22K 914, 21K 874, 18K 749, 16K 666, 14K 583.
pub fn fineness(karat: f64) -> Option<u32> {
    if karat.fract() != 0.0 { return None; }
    match karat as u32 {
        24 => Some(999), 22 => Some(914), 21 => Some(874), 18 => Some(749), 16 => Some(666), 14 => Some(583),
        _ => None,
    }
}

/// Hallmark (fineness per mille) for display.
pub fn hallmark(karat: f64) -> u32 {
    fineness(karat).unwrap_or_else(|| (karat / 24.0 * 1000.0).round() as u32)
}

/// Price ratio to 24K: fineness / 999 for the board karats, otherwise karat / 24.
pub fn purity(karat: f64) -> R<f64> {
    if !(karat > 0.0 && karat <= 24.0) { return err("karat must be between 0 and 24"); }
    if karat == 24.0 { return Ok(1.0); }
    Ok(match fineness(karat) { Some(f) => f as f64 / 999.0, None => karat / 24.0 })
}

fn positive(name: &str, v: f64, allow_zero: bool) -> R<f64> {
    if !v.is_finite() || v < 0.0 || (!allow_zero && v == 0.0) {
        return Err(GoldError(format!("{name} must be {}", if allow_zero { "non-negative" } else { "positive" })));
    }
    Ok(v)
}

/// Parse "461.11", "461,11", "14,342.21" or Arabic-Indic "٤٦١٫١١".
pub fn parse_number(s: &str) -> R<f64> {
    let mut t = String::new();
    for c in s.trim().chars() {
        match c {
            '\u{0660}'..='\u{0669}' => t.push(char::from(b'0' + (c as u32 - 0x0660) as u8)),
            '\u{06F0}'..='\u{06F9}' => t.push(char::from(b'0' + (c as u32 - 0x06F0) as u8)),
            '\u{066B}' => t.push('.'),
            '\u{066C}' => {}
            c if c.is_whitespace() => {}
            c => t.push(c),
        }
    }
    let thousands = t.contains(',') && t.contains('.') && t.find(',') < t.find('.');
    let t = if thousands || t.matches(',').count() > 1 { t.replace(',', "") } else { t.replacen(',', ".", 1) };
    t.parse::<f64>().map_err(|_| GoldError(format!("not a number: {s}")))
}

/// Convert a weight between units. Not rounded.
pub fn convert(value: f64, from: &str, to: &str) -> R<f64> {
    Ok(positive("value", value, true)? * unit_grams(from)? / unit_grams(to)?)
}

/// Price per gram for a karat (unrounded).
pub fn karat_price(price24: f64, karat: f64) -> R<f64> {
    Ok(positive("price24", price24, false)? * purity(karat)?)
}

/// One row of the karat table.
#[derive(Debug, Clone, PartialEq)]
pub struct Row { pub karat: f64, pub hallmark: u32, pub per_gram: f64, pub per_tola: f64, pub per_ounce: f64 }

/// Price table for 24/22/21/18/14K.
pub fn price_table(price24: f64) -> R<Vec<Row>> {
    KARATS.iter().map(|&k| {
        let g = karat_price(price24, k)?;
        Ok(Row { karat: k, hallmark: hallmark(k), per_gram: round(g, 2),
                 per_tola: round(g * 11.6638038, 2), per_ounce: round(g * 31.1034768, 2) })
    }).collect()
}

/// How the making charge is expressed.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum MakingType { PerGram, Percent, Fixed }

impl std::str::FromStr for MakingType {
    type Err = GoldError;
    fn from_str(s: &str) -> R<Self> {
        match s { "per_gram" => Ok(Self::PerGram), "percent" => Ok(Self::Percent), "fixed" => Ok(Self::Fixed),
                  _ => err("making type must be per_gram, percent or fixed") }
    }
}

/// Result of pricing a piece.
#[derive(Debug, Clone, PartialEq)]
pub struct ItemPrice { pub grams: f64, pub price_per_gram: f64, pub metal: f64, pub making: f64,
                       pub subtotal: f64, pub vat_rate: f64, pub vat: f64, pub total: f64 }

/// Price a piece: metal + making + VAT on both.
pub fn item_price(price24: f64, weight: f64, unit: &str, karat: f64, making: f64,
                  making_type: MakingType, vat_rate: f64) -> R<ItemPrice> {
    let grams = positive("weight", weight, false)? * unit_grams(unit)?;
    let per_gram = karat_price(price24, karat)?;
    let metal = grams * per_gram;
    let m = positive("making", making, true)?;
    let mk = match making_type { MakingType::PerGram => m * grams, MakingType::Percent => metal * m / 100.0, MakingType::Fixed => m };
    let rate = positive("vat_rate", vat_rate, true)?;
    let sub = metal + mk;
    Ok(ItemPrice { grams: round(grams, 4), price_per_gram: round(per_gram, 2), metal: round(metal, 2),
                   making: round(mk, 2), subtotal: round(sub, 2), vat_rate: rate, vat: round(sub * rate, 2),
                   total: round(sub * (1.0 + rate), 2) })
}

/// Zakat result.
#[derive(Debug, Clone, PartialEq)]
pub struct Zakat { pub pure_grams: f64, pub value: f64, pub nisab_value: f64, pub due: bool, pub zakat: f64 }

/// Zakat on gold items given as (weight, unit, karat).
pub fn zakat(price24: f64, items: &[(f64, &str, f64)]) -> R<Zakat> {
    let p = positive("price24", price24, false)?;
    let mut pure = 0.0;
    for &(w, u, k) in items { pure += positive("weight", w, true)? * unit_grams(u)? * purity(k)?; }
    let value = pure * p;
    let due = pure + 1e-9 >= NISAB_GRAMS;
    Ok(Zakat { pure_grams: round(pure, 4), value: round(value, 2), nisab_value: round(NISAB_GRAMS * p, 2),
               due, zakat: if due { round(value * ZAKAT_RATE, 2) } else { 0.0 } })
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn table() {
        let t = price_table(461.11).unwrap();
        let g: Vec<f64> = t.iter().map(|r| r.per_gram).collect();
        assert_eq!(g, vec![461.11, 421.88, 403.41, 345.72, 269.10]);
        assert_eq!(t[0].per_ounce, 14342.12);
    }
    #[test]
    fn conversions() {
        assert_eq!(round(convert(1.0, "tola", "g").unwrap(), 7), 11.6638038);
        assert_eq!(round(convert(10.0, "مثقال", "g").unwrap(), 2), 42.5);
        assert!(convert(1.0, "stone", "g").is_err());
    }
    #[test]
    fn items() {
        let r = item_price(461.11, 10.0, "g", 21.0, 30.0, MakingType::PerGram, 0.05).unwrap();
        assert_eq!((r.metal, r.making, r.vat, r.total), (4034.14, 300.0, 216.71, 4550.84));
        assert_eq!(item_price(400.0, 1.0, "oz", 24.0, 0.0, MakingType::PerGram, 0.0).unwrap().total, 12441.39);
        assert_eq!(item_price(400.0, 5.0, "g", 18.0, 10.0, MakingType::Percent, 0.0).unwrap().total, 1649.45);
        assert_eq!(item_price(400.0, 5.0, "g", 18.0, 99.0, MakingType::Fixed, 0.0).unwrap().total, 1598.5);
    }
    #[test]
    fn zakat_nisab() {
        let z = zakat(461.11, &[(100.0, "g", 21.0)]).unwrap();
        assert!(z.due); assert_eq!(z.pure_grams, 87.4875); assert_eq!(z.zakat, 1008.53);
        let n = zakat(461.11, &[(90.0, "g", 18.0)]).unwrap();
        assert!(!n.due); assert_eq!(n.zakat, 0.0);
    }
    #[test]
    fn parsing() {
        assert_eq!(parse_number("٤٦١٫١١").unwrap(), 461.11);
        assert_eq!(parse_number("461,11").unwrap(), 461.11);
        assert_eq!(parse_number("14,342.21").unwrap(), 14342.21);
        assert!(karat_price(-1.0, 22.0).is_err());
    }
    #[test]
    fn board_fineness() {
        let g: Vec<f64> = price_table(461.74).unwrap().iter().map(|r| r.per_gram).collect();
        assert_eq!(g, vec![461.74, 422.45, 403.96, 346.19, 269.46]);
        assert_eq!(purity(16.0).unwrap(), 666.0 / 999.0);
        assert_eq!(purity(9.0).unwrap(), 9.0 / 24.0);
    }
}

use std::collections::HashMap;
use uae_gold_calculator::*;

const HELP: &str = "uae-gold-calculator 1.0.0: gold karat prices, making charges, VAT and zakat

  uae-gold-calculator table --price <24K AED/g> [--lang ar]
  uae-gold-calculator item  --price <24K> --weight <n> [--unit g] [--karat 21] [--making 30] [--making-type per_gram|percent|fixed] [--vat 0.05] [--lang ar]
  uae-gold-calculator convert <value> <from> <to>
  uae-gold-calculator zakat --price <24K> --weight <n> [--karat 21] [--unit g] [--lang ar]

Today's 24K price: https://uaegoldprices.ae/";

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mut pos = Vec::new();
    let mut opt: HashMap<String, String> = HashMap::new();
    let mut i = 0;
    while i < args.len() {
        if let Some(k) = args[i].strip_prefix("--") {
            if k == "help" { println!("{HELP}"); return Ok(()); }
            opt.insert(k.to_string(), args.get(i + 1).cloned().unwrap_or_default());
            i += 2;
        } else { pos.push(args[i].clone()); i += 1; }
    }
    let ar = opt.get("lang").map(|s| s == "ar").unwrap_or(false);
    let num = |k: &str, d: f64| -> Result<f64, GoldError> { opt.get(k).map(|s| parse_number(s)).unwrap_or(Ok(d)) };
    let cur = if ar { "د.إ" } else { "AED" };
    match pos.first().map(|s| s.as_str()) {
        Some("convert") if pos.len() == 4 => {
            println!("{}", round(convert(parse_number(&pos[1])?, &pos[2], &pos[3])?, 4));
        }
        Some("table") => {
            println!("{}", if ar { "العيار\tسعر الجرام\tسعر التولة\tسعر الأونصة" } else { "Karat\tPer gram\tPer tola\tPer ounce" });
            for r in price_table(num("price", f64::NAN)?)? {
                println!("{}K ({})\t{:.2}\t{:.2}\t{:.2}", r.karat, r.hallmark, r.per_gram, r.per_tola, r.per_ounce);
            }
        }
        Some("item") => {
            let mt: MakingType = opt.get("making-type").map(|s| s.as_str()).unwrap_or("per_gram").parse()?;
            let unit = opt.get("unit").cloned().unwrap_or_else(|| "g".into());
            let r = item_price(num("price", f64::NAN)?, num("weight", f64::NAN)?, &unit, num("karat", 24.0)?,
                               num("making", 0.0)?, mt, num("vat", UAE_VAT_RATE)?)?;
            println!("{}: {:.2} {cur}", if ar { "قيمة الذهب" } else { "Gold value" }, r.metal);
            println!("{}: {:.2} {cur}", if ar { "المصنعية" } else { "Making charge" }, r.making);
            println!("{} ({:.0}%): {:.2} {cur}", if ar { "ضريبة القيمة المضافة" } else { "VAT" }, r.vat_rate * 100.0, r.vat);
            println!("{}: {:.2} {cur}", if ar { "الإجمالي" } else { "Total" }, r.total);
        }
        Some("zakat") => {
            let unit = opt.get("unit").cloned().unwrap_or_else(|| "g".into());
            let z = zakat(num("price", f64::NAN)?, &[(num("weight", f64::NAN)?, unit.as_str(), num("karat", 24.0)?)])?;
            if z.due { println!("{}: {:.2} {cur}", if ar { "الزكاة المستحقة" } else { "Zakat due" }, z.zakat); }
            else { println!("{}", if ar { "أقل من النصاب: لا زكاة" } else { "Below nisab: no zakat due" }); }
        }
        _ => println!("{HELP}"),
    }
    Ok(())
}

fn main() {
    if let Err(e) = run() { eprintln!("Error: {e}"); std::process::exit(1); }
}

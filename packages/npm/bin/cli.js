#!/usr/bin/env node
'use strict';
const g = require('../lib/index.js');

const HELP = `uae-gold-calculator 1.0.0: gold karat prices, making charges, VAT and zakat

Usage:
  uae-gold-calculator table   --price <24K AED/g> [--lang ar|en] [--json]
  uae-gold-calculator item    --price <24K> --weight <n> [--unit g|kg|oz|tola|mithqal]
                              [--karat 21] [--making 30] [--making-type per_gram|percent|fixed]
                              [--vat 0.05] [--lang ar|en] [--json]
  uae-gold-calculator convert <value> <from> <to>
  uae-gold-calculator zakat   --price <24K> --weight <n> [--karat 21] [--unit g] [--json]

Today's 24K price: https://uaegoldprices.ae/`;

function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      if (key === 'json' || key === 'help') out[key] = true;
      else out[key] = argv[++i];
    } else out._.push(a);
  }
  return out;
}

function main(argv) {
  const args = parseArgs(argv);
  const cmd = args._[0];
  const L = g.LABELS[args.lang === 'ar' ? 'ar' : 'en'];
  if (!cmd || args.help || cmd === 'help') { console.log(HELP); return 0; }
  if (cmd === 'convert') {
    const [, v, from, to] = args._;
    console.log(g.round(g.convert(v, from, to), 4));
    return 0;
  }
  if (args.price === undefined) throw new Error('--price (24K price per gram) is required');
  if (cmd === 'table') {
    const rows = g.priceTable(args.price);
    if (args.json) { console.log(JSON.stringify(rows, null, 2)); return 0; }
    console.log([L.karat, L.perGram, L.perTola, L.perOunce].join('\t'));
    for (const r of rows) console.log(`${r.karat}K (${r.hallmark})\t${r.perGram.toFixed(2)}\t${r.perTola.toFixed(2)}\t${r.perOunce.toFixed(2)}`);
    return 0;
  }
  if (cmd === 'item') {
    const r = g.itemPrice({
      price24: args.price, weight: args.weight, unit: args.unit, karat: args.karat,
      making: args.making, makingType: args['making-type'], vatRate: args.vat,
    });
    if (args.json) { console.log(JSON.stringify(r, null, 2)); return 0; }
    console.log(`${L.metal}: ${r.metal.toFixed(2)} ${L.currency}`);
    console.log(`${L.making}: ${r.making.toFixed(2)} ${L.currency}`);
    console.log(`${L.vat} (${(r.vatRate * 100).toFixed(0)}%): ${r.vat.toFixed(2)} ${L.currency}`);
    console.log(`${L.total}: ${r.total.toFixed(2)} ${L.currency}`);
    return 0;
  }
  if (cmd === 'zakat') {
    const r = g.zakat(args.price, [{ weight: args.weight, unit: args.unit, karat: args.karat }]);
    if (args.json) { console.log(JSON.stringify(r, null, 2)); return 0; }
    console.log(r.due ? `${L.zakatDue}: ${r.zakat.toFixed(2)} ${L.currency}` : L.notDue);
    return 0;
  }
  throw new Error(`Unknown command: ${cmd}`);
}

if (require.main === module) {
  try { process.exitCode = main(process.argv.slice(2)); } catch (e) { console.error(`Error: ${e.message}`); process.exitCode = 1; }
}
module.exports = { main };

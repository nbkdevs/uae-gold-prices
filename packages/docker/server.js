'use strict';
// Gold value API + Arabic/English calculator page. No dependencies, no outbound requests.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
let gold;
try { gold = require('uae-gold-calculator'); } catch { gold = require('../npm/lib'); } // repo checkout fallback

const PUBLIC = path.join(__dirname, 'public');
const TYPES = { '.html': 'text/html; charset=utf-8', '.css': 'text/css; charset=utf-8', '.js': 'text/javascript; charset=utf-8' };
const HELP = 'Try /api/table?price=461.11, /api/item?price=461.11&weight=10&karat=21&making=30, '
  + '/api/convert?value=2&from=tola&to=g or /api/zakat?price=461.11&items=100:21,25:18';

function staticFile(p) {
  const rel = p === '/' ? 'index.html' : p.slice(1);
  const full = path.normalize(path.join(PUBLIC, rel));
  if (!full.startsWith(PUBLIC + path.sep) || !TYPES[path.extname(full)] || !fs.existsSync(full)) return null;
  return { type: TYPES[path.extname(full)], body: fs.readFileSync(full) };
}

function parseItems(s) {
  // "100:21,25:18:tola" -> [{weight:100,karat:21},{weight:25,karat:18,unit:'tola'}]
  return String(s).split(',').filter(Boolean).map((part) => {
    const [weight, karat = '24', unit = 'g'] = part.split(':');
    return { weight, karat: Number(karat), unit };
  });
}

function handle(req, res) {
  const url = new URL(req.url, 'http://x');
  const q = (k) => url.searchParams.get(k);
  const send = (code, body) => {
    res.writeHead(code, { 'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*' });
    res.end(JSON.stringify(body, null, 2));
  };
  try {
    if (url.pathname === '/healthz') return send(200, { ok: true });
    if (!url.pathname.startsWith('/api/')) {
      const f = staticFile(url.pathname);
      if (!f) return send(404, { error: `Not found. ${HELP}` });
      res.writeHead(200, { 'content-type': f.type });
      return res.end(f.body);
    }
    if (url.pathname === '/api/convert') {
      if (q('value') === null) return send(400, { error: HELP });
      const value = gold.convert(q('value'), q('from') || 'g', q('to') || 'g');
      return send(200, { value: gold.round(value, 4), from: gold.normalizeUnit(q('from') || 'g'), to: gold.normalizeUnit(q('to') || 'g') });
    }
    if (q('price') === null) return send(400, { error: `price (24K AED per gram) is required. ${HELP}` });
    if (url.pathname === '/api/table') return send(200, gold.priceTable(q('price')));
    if (url.pathname === '/api/item') {
      if (q('weight') === null) return send(400, { error: HELP });
      return send(200, gold.itemPrice({
        price24: q('price'), weight: q('weight'), unit: q('unit') || 'g', karat: q('karat') === null ? 24 : Number(q('karat')),
        making: q('making') || 0, makingType: q('making_type') || 'per_gram', vatRate: q('vat') === null ? undefined : q('vat'),
      }));
    }
    if (url.pathname === '/api/zakat') {
      const items = q('items') !== null ? parseItems(q('items'))
        : q('weight') !== null ? [{ weight: q('weight'), karat: Number(q('karat') || 24), unit: q('unit') || 'g' }] : [];
      if (!items.length) return send(400, { error: HELP });
      return send(200, gold.zakat(q('price'), items));
    }
    return send(404, { error: `Not found. ${HELP}` });
  } catch (e) { return send(400, { error: e.message }); }
}

if (require.main === module) {
  const port = Number(process.env.PORT) || 8080;
  http.createServer(handle).listen(port, () => console.log(`uae-gold-calculator listening on :${port}`));
}

module.exports = { handle, parseItems };

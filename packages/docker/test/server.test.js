'use strict';
const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { handle } = require('../server');

function get(server, p) {
  return new Promise((resolve) => http.get({ port: server.address().port, path: p }, (res) => {
    let b = ''; res.on('data', (c) => (b += c)); res.on('end', () => resolve({ code: res.statusCode, body: b, type: res.headers['content-type'] }));
  }));
}

test('api', async () => {
  const s = http.createServer(handle).listen(0);
  try {
    const t = JSON.parse((await get(s, '/api/table?price=461.11')).body);
    assert.deepStrictEqual(t.map((r) => r.perGram), [461.11, 421.88, 403.41, 345.72, 269.10]);
    const it = JSON.parse((await get(s, '/api/item?price=461.11&weight=10&karat=21&making=30')).body);
    assert.strictEqual(it.total, 4550.84);
    const p = JSON.parse((await get(s, '/api/item?price=400&weight=5&karat=18&making=10&making_type=percent&vat=0')).body);
    assert.strictEqual(p.total, 1649.45);
    assert.strictEqual(JSON.parse((await get(s, '/api/convert?value=1&from=oz&to=g')).body).value, 31.1035);
    const z = JSON.parse((await get(s, '/api/zakat?price=461.11&items=100:21')).body);
    assert.strictEqual(z.zakat, 1008.53);
    assert.strictEqual(JSON.parse((await get(s, '/api/zakat?price=461.11&weight=90&karat=18')).body).due, false);
    assert.strictEqual((await get(s, '/api/item?price=-1&weight=1')).code, 400);
    assert.strictEqual((await get(s, '/api/table')).code, 400);
    assert.strictEqual((await get(s, '/healthz')).code, 200);
    const home = await get(s, '/');
    assert.strictEqual(home.code, 200);
    assert.match(home.body, /dir="rtl"/);
    assert.match(home.body, /href="https:\/\/uaegoldprices\.ae\/"/);
    assert.strictEqual((await get(s, '/js/gold.js')).code, 200);
    assert.strictEqual((await get(s, '/../server.js')).code, 404);
  } finally { s.close(); }
});

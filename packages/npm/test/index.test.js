'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const g = require('../lib/index.js');

test('karat prices from 24K', () => {
  const t = g.priceTable(461.11);
  assert.deepEqual(t.map((r) => r.perGram), [461.11, 422.68, 403.47, 345.83, 268.98]);
  assert.equal(t[0].perOunce, 14342.12);
  assert.equal(t[0].hallmark, 999);
});

test('unit conversion', () => {
  assert.equal(g.round(g.convert(1, 'tola', 'g'), 7), 11.6638038);
  assert.equal(g.round(g.convert(1, 'oz', 'g'), 7), 31.1034768);
  assert.equal(g.convert('1', 'kg', 'g'), 1000);
  assert.equal(g.round(g.convert(10, 'مثقال', 'g'), 2), 42.5);
  assert.throws(() => g.convert(1, 'stone', 'g'), RangeError);
});

test('item price: 10 g 21K, 30 AED/g making, 5% VAT', () => {
  const r = g.itemPrice({ price24: 461.11, weight: 10, karat: 21, making: 30 });
  assert.equal(r.metal, 4034.71);
  assert.equal(r.making, 300);
  assert.equal(r.vat, 216.74);
  assert.equal(r.total, 4551.45);
});

test('item price: percent and fixed making, zero VAT', () => {
  assert.equal(g.itemPrice({ price24: 400, weight: 1, unit: 'oz', karat: 24, vatRate: 0 }).total, 12441.39);
  assert.equal(g.itemPrice({ price24: 400, weight: 5, karat: 18, making: 10, makingType: 'percent', vatRate: 0 }).total, 1650);
  assert.equal(g.itemPrice({ price24: 400, weight: 5, karat: 18, making: 99, makingType: 'fixed', vatRate: 0 }).total, 1599);
});

test('zakat against 85 g nisab', () => {
  const due = g.zakat(461.11, [{ weight: 100, karat: 21 }]);
  assert.equal(due.pureGrams, 87.5);
  assert.equal(due.due, true);
  assert.equal(due.zakat, 1008.68);
  const notDue = g.zakat(461.11, [{ weight: 90, karat: 18 }]);
  assert.equal(notDue.due, false);
  assert.equal(notDue.zakat, 0);
});

test('parses Arabic-Indic digits and comma decimals', () => {
  assert.equal(g.parseNumber('٤٦١٫١١'), 461.11);
  assert.equal(g.parseNumber('461,11'), 461.11);
  assert.equal(g.parseNumber('14,342.21'), 14342.21);
  assert.throws(() => g.karatPrice(-1, 22), RangeError);
});

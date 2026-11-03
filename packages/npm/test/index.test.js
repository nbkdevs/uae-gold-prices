'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const g = require('../lib/index.js');

test('karat prices from 24K', () => {
  const t = g.priceTable(461.11);
  assert.deepEqual(t.map((r) => r.perGram), [461.11, 421.88, 403.41, 345.72, 269.10]);
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
  assert.equal(r.metal, 4034.14);
  assert.equal(r.making, 300);
  assert.equal(r.vat, 216.71);
  assert.equal(r.total, 4550.84);
});

test('item price: percent and fixed making, zero VAT', () => {
  assert.equal(g.itemPrice({ price24: 400, weight: 1, unit: 'oz', karat: 24, vatRate: 0 }).total, 12441.39);
  assert.equal(g.itemPrice({ price24: 400, weight: 5, karat: 18, making: 10, makingType: 'percent', vatRate: 0 }).total, 1649.45);
  assert.equal(g.itemPrice({ price24: 400, weight: 5, karat: 18, making: 99, makingType: 'fixed', vatRate: 0 }).total, 1598.5);
});

test('zakat against 85 g nisab', () => {
  const due = g.zakat(461.11, [{ weight: 100, karat: 21 }]);
  assert.equal(due.pureGrams, 87.4875);
  assert.equal(due.due, true);
  assert.equal(due.zakat, 1008.53);
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

test('matches the UAE board fineness (uaegoldprices.ae, 3 Nov 2026)', () => {
  assert.deepEqual(g.priceTable(461.74).map((r) => r.perGram), [461.74, 422.45, 403.96, 346.19, 269.46]);
  assert.deepEqual(g.priceTable(461.74).map((r) => r.hallmark), [999, 914, 874, 749, 583]);
  assert.equal(g.purity(16), 666 / 999);
  assert.equal(g.purity(9), 9 / 24);
});

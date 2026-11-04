/* Gold value calculator UI. Needs js/gold.js (window.GoldCalc). No network, no tracking. */
(function () {
  'use strict';
  var G = window.GoldCalc;
  var T = {
    ar: {
      title: 'حاسبة قيمة الذهب', sub: 'أسعار العيارات والمصنعية والضريبة والزكاة', toggle: 'English',
      price: 'سعر الذهب عيار 24 اليوم', basis: 'السعر المُدخل لكل', perGramOpt: 'جرام', perOzOpt: 'أونصة',
      priceHint: 'أدخل سعر اليوم بالدرهم. يُحفظ على جهازك فقط.',
      tTable: 'العيارات', tItem: 'سعر القطعة', tZakat: 'الزكاة', tConv: 'الوحدات',
      karat: 'العيار', perGram: 'الجرام', perTola: 'التولة', perOunce: 'الأونصة',
      weight: 'الوزن', unit: 'الوحدة', making: 'المصنعية', makingType: 'نوع المصنعية',
      mPerGram: 'درهم لكل جرام', mPercent: 'نسبة % من قيمة الذهب', mFixed: 'مبلغ ثابت', vatOn: 'إضافة ضريبة القيمة المضافة 5%',
      metal: 'قيمة الذهب', makingOut: 'المصنعية', vat: 'ضريبة القيمة المضافة', total: 'الإجمالي',
      addItem: '+ إضافة قطعة', pure: 'الذهب الخالص', value: 'قيمة الذهب الخالص', nisab: 'قيمة النصاب (85 جرام)',
      due: 'تجب الزكاة', notDue: 'أقل من النصاب: لا زكاة', zakatOut: 'الزكاة المستحقة (2.5%)',
      value2: 'القيمة', from: 'من', to: 'إلى', result: 'النتيجة',
      units: { g: 'جرام', kg: 'كيلوجرام', oz: 'أونصة', tola: 'تولة', mithqal: 'مثقال' },
      cur: 'د.إ', gUnit: 'جم',
      needPrice: 'أدخل سعر جرام الذهب عيار 24 أولاً.',
      note: 'النتائج تقديرية. تختلف أسعار المحلات وأحكام الضريبة على ذهب الاستثمار وآراء الفقهاء في الزكاة.',
    },
    en: {
      title: 'Gold Value Calculator', sub: 'Karat prices, making charge, VAT and zakat', toggle: 'العربية',
      price: "Today's 24K gold price", basis: 'Price entered per', perGramOpt: 'gram', perOzOpt: 'troy ounce',
      priceHint: "Enter today's price in AED. It is saved on this device only.",
      tTable: 'Karats', tItem: 'Item price', tZakat: 'Zakat', tConv: 'Units',
      karat: 'Karat', perGram: 'Gram', perTola: 'Tola', perOunce: 'Ounce',
      weight: 'Weight', unit: 'Unit', making: 'Making charge', makingType: 'Making type',
      mPerGram: 'AED per gram', mPercent: '% of gold value', mFixed: 'Fixed amount', vatOn: 'Add 5% VAT',
      metal: 'Gold value', makingOut: 'Making charge', vat: 'VAT', total: 'Total',
      addItem: '+ Add item', pure: 'Pure gold', value: 'Pure gold value', nisab: 'Nisab value (85 g)',
      due: 'Zakat is due', notDue: 'Below nisab: no zakat due', zakatOut: 'Zakat due (2.5%)',
      value2: 'Value', from: 'From', to: 'To', result: 'Result',
      units: { g: 'gram', kg: 'kilogram', oz: 'troy ounce', tola: 'tola', mithqal: 'mithqal' },
      cur: 'AED', gUnit: 'g',
      needPrice: 'Enter the 24K price per gram first.',
      note: 'Estimates only. Shop prices, VAT on investment gold and zakat rulings vary.',
    }
  };
  var store = {
    get: function (k, d) { try { var v = localStorage.getItem('gvc.' + k); return v === null ? d : v; } catch (e) { return d; } },
    set: function (k, v) { try { localStorage.setItem('gvc.' + k, v); } catch (e) { /* private mode */ } }
  };
  var lang = store.get('lang', document.documentElement.lang === 'en' ? 'en' : 'ar');
  var $ = function (id) { return document.getElementById(id); };
  var fmt = function (n) { return n.toLocaleString(lang === 'ar' ? 'ar-AE' : 'en-AE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); };
  var money = function (n) { return fmt(n) + ' ' + T[lang].cur; };
  var num = function (id) { var v = $(id).value; return v === '' ? NaN : G.parseNumber(v); };

  function el(tag, attrs, text) {
    var e = document.createElement(tag);
    if (attrs) Object.keys(attrs).forEach(function (k) { e.setAttribute(k, attrs[k]); });
    if (text !== undefined) e.textContent = text;
    return e;
  }
  function unitOptions(sel, value) {
    var cur = value || sel.value || 'g';
    sel.textContent = '';
    Object.keys(G.UNITS).forEach(function (u) { var o = el('option', { value: u }, T[lang].units[u]); if (u === cur) o.selected = true; sel.appendChild(o); });
  }
  function karatOptions(sel, value) {
    var cur = String(value || sel.value || 21);
    sel.textContent = '';
    G.KARATS.forEach(function (k) { var o = el('option', { value: String(k) }, k + 'K (' + G.HALLMARKS[k] + ')'); if (String(k) === cur) o.selected = true; sel.appendChild(o); });
  }
  function price24() {
    var p = num('price');
    if (!(p > 0)) return NaN;
    return $('basis').value === 'oz' ? p / G.UNITS.oz : p;
  }
  function line(parent, label, value, cls) {
    var d = el('div', { class: 'line' + (cls ? ' ' + cls : '') });
    d.appendChild(el('span', null, label)); d.appendChild(el('span', null, value)); parent.appendChild(d);
  }

  function renderTable(p) {
    var body = $('tableBody'); body.textContent = '';
    if (!(p > 0)) return;
    G.priceTable(p).forEach(function (r) {
      var tr = el('tr');
      var k = el('td', { class: 'k' }, r.karat + 'K '); k.appendChild(el('small', null, r.hallmark)); tr.appendChild(k);
      tr.appendChild(el('td', null, fmt(r.perGram))); tr.appendChild(el('td', null, fmt(r.perTola))); tr.appendChild(el('td', null, fmt(r.perOunce)));
      body.appendChild(tr);
    });
  }
  function renderItem(p) {
    var out = $('itemOut'); out.textContent = '';
    if (!(p > 0) || !(num('weight') > 0)) return;
    var r = G.itemPrice({ price24: p, weight: num('weight'), unit: $('unit').value, karat: Number($('karat').value),
      making: isNaN(num('making')) ? 0 : num('making'), makingType: $('makingType').value, vatRate: $('vatOn').checked ? G.VAT_RATE : 0 });
    var L = T[lang];
    line(out, L.metal + ' (' + fmt(r.grams) + ' ' + L.gUnit + ' × ' + fmt(r.pricePerGram) + ')', money(r.metal));
    line(out, L.makingOut, money(r.making));
    if (r.vatRate > 0) line(out, L.vat + ' (5%)', money(r.vat));
    line(out, L.total, money(r.total), 'total');
  }
  function zakatRow(w, k) {
    var wrap = el('div', { class: 'it' });
    var a = el('div'); a.appendChild(el('label', null, T[lang].weight)); var wi = el('input', { inputmode: 'decimal', class: 'zw' }); wi.value = w || ''; a.appendChild(wi);
    var b = el('div'); b.appendChild(el('label', null, T[lang].unit)); var us = el('select', { class: 'zu' }); unitOptions(us, 'g'); b.appendChild(us);
    var c = el('div'); c.appendChild(el('label', null, T[lang].karat)); var ks = el('select', { class: 'zk' }); karatOptions(ks, k || 21); c.appendChild(ks);
    var x = el('button', { class: 'btn x', type: 'button', 'aria-label': 'remove' }, '×');
    x.addEventListener('click', function () { wrap.remove(); update(); });
    [wi, us, ks].forEach(function (i) { i.addEventListener('input', update); i.addEventListener('change', update); });
    wrap.appendChild(a); wrap.appendChild(b); wrap.appendChild(c); wrap.appendChild(x);
    $('zItems').appendChild(wrap);
  }
  function renderZakat(p) {
    var out = $('zakatOut'); out.textContent = '';
    if (!(p > 0)) return;
    var items = [];
    Array.prototype.forEach.call(document.querySelectorAll('#zItems .it'), function (it) {
      var v = it.querySelector('.zw').value;
      if (v !== '') items.push({ weight: G.parseNumber(v), unit: it.querySelector('.zu').value, karat: Number(it.querySelector('.zk').value) });
    });
    if (!items.length) return;
    var z = G.zakat(p, items), L = T[lang];
    line(out, L.pure, fmt(z.pureGrams) + ' ' + L.gUnit);
    line(out, L.value, money(z.value));
    line(out, L.nisab, money(z.nisabValue));
    var st = el('div', { class: 'line' }); st.appendChild(el('span', { class: 'badge ' + (z.due ? 'ok' : 'no') }, z.due ? L.due : L.notDue)); out.appendChild(st);
    if (z.due) line(out, L.zakatOut, money(z.zakat), 'total');
  }
  function renderConv() {
    var v = num('cValue');
    $('cOut').textContent = isNaN(v) ? '' : (Math.round(G.convert(v, $('cFrom').value, $('cTo').value) * 10000) / 10000).toLocaleString(lang === 'ar' ? 'ar-AE' : 'en-AE', { maximumFractionDigits: 4 }) + ' ' + T[lang].units[$('cTo').value];
  }
  function update() {
    $('err').textContent = '';
    try {
      store.set('price', $('price').value); store.set('basis', $('basis').value);
      var p = price24();
      if (!(p > 0) && $('price').value !== '') throw new Error(T[lang].needPrice);
      renderTable(p); renderItem(p); renderZakat(p); renderConv();
      if (!(p > 0)) $('err').textContent = T[lang].needPrice;
    } catch (e) { $('err').textContent = e.message; }
  }
  function applyLang() {
    var L = T[lang];
    document.documentElement.lang = lang; document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    document.title = L.title;
    Array.prototype.forEach.call(document.querySelectorAll('[data-i18n]'), function (e) { e.textContent = L[e.getAttribute('data-i18n')]; });
    ['unit', 'cFrom', 'cTo'].forEach(function (id) { unitOptions($(id)); });
    Array.prototype.forEach.call(document.querySelectorAll('.zu'), function (s) { unitOptions(s); });
    Array.prototype.forEach.call(document.querySelectorAll('#zItems label'), function (l, i) { l.textContent = [L.weight, L.unit, L.karat][i % 3]; });
    update();
  }
  function selectTab(name) {
    Array.prototype.forEach.call(document.querySelectorAll('.tabs button'), function (b) { b.setAttribute('aria-selected', String(b.dataset.tab === name)); });
    Array.prototype.forEach.call(document.querySelectorAll('.panel'), function (p) { p.hidden = p.id !== 'p-' + name; });
    store.set('tab', name);
  }

  document.addEventListener('DOMContentLoaded', function () {
    $('price').value = store.get('price', '');
    $('basis').value = store.get('basis', 'g');
    karatOptions($('karat'), 21);
    unitOptions($('unit'), 'g'); unitOptions($('cFrom'), 'tola'); unitOptions($('cTo'), 'g');
    zakatRow('', 21);
    Array.prototype.forEach.call(document.querySelectorAll('input, select'), function (i) { i.addEventListener('input', update); i.addEventListener('change', update); });
    Array.prototype.forEach.call(document.querySelectorAll('.tabs button'), function (b) { b.addEventListener('click', function () { selectTab(b.dataset.tab); }); });
    $('addItem').addEventListener('click', function () { zakatRow('', 21); });
    $('lang').addEventListener('click', function () { lang = lang === 'ar' ? 'en' : 'ar'; store.set('lang', lang); applyLang(); });
    selectTab(store.get('tab', 'table'));
    applyLang();
  });
})();

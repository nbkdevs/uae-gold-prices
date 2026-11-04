#!/usr/bin/env python3
"""Render the extension popup to extension/raw/{tab}-{lang}.png (760x1200) with headless Chrome."""
import shutil, subprocess, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parent
SHARED = ROOT.parent / "extensions/shared"
SHELL = str(next(Path.home().glob(".cache/puppeteer/chrome-headless-shell/*/*/chrome-headless-shell")))
OUT = ROOT / "extension/raw"
SETUP = """document.addEventListener('DOMContentLoaded',function(){setTimeout(function(){
var $=function(i){return document.getElementById(i)};
function fire(e){e.dispatchEvent(new Event('input',{bubbles:true}));e.dispatchEvent(new Event('change',{bubbles:true}));}
$('price').value='461.11';fire($('price'));
$('weight').value='12.5';$('karat').value='21';$('making').value='35';fire($('making'));fire($('karat'));fire($('weight'));
var w=document.querySelector('#zItems .zw');w.value='40';fire(w);
$('addItem').click();var ws=document.querySelectorAll('#zItems .zw'),ks=document.querySelectorAll('#zItems .zk');ws[1].value='35';ks[1].value='18';fire(ws[1]);fire(ks[1]);
$('addItem').click();ws=document.querySelectorAll('#zItems .zw');ks=document.querySelectorAll('#zItems .zk');ws[2].value='30';ks[2].value='22';fire(ws[2]);fire(ks[2]);
$('cValue').value='3';fire($('cValue'));
document.querySelector('.tabs [data-tab=%s]').click();},0);});"""
for lang in ("ar", "en"):
    for tab in ("table", "item", "zakat", "conv"):
        with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as t:
            d = Path(t) / "p"; shutil.copytree(SHARED, d)
            (d / "js/shot.js").write_text(SETUP % tab)
            h = (d / "popup.html").read_text(encoding="utf-8").replace('lang="ar" dir="rtl"', f'lang="{lang}" dir="{"rtl" if lang=="ar" else "ltr"}"')
            h = h.replace("</body>", '<script src="js/shot.js"></script></body>')
            (d / "popup.html").write_text(h, encoding="utf-8")
            subprocess.run([SHELL, "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
                            f"--user-data-dir={t}/prof", f"--window-size=380,{830 if tab == 'zakat' else 600}", "--virtual-time-budget=1500", "--force-device-scale-factor=2",
                            f"--screenshot={OUT}/{tab}-{lang}.png", (d / "popup.html").as_uri() + ("#z" if tab == "zakat" else "")],
                           check=True, capture_output=True, timeout=60)
print("ok")

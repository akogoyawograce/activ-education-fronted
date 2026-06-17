#!/usr/bin/env python3
"""Télécharge les favicons/logos des écoles du Togo (stdlib only)."""

import re
import os
import socket
import urllib.request
import urllib.error
import html.parser
from pathlib import Path
from urllib.parse import urljoin

socket.setdefaulttimeout(6)

OUTPUT = Path("/tmp/universite_logos")
OUTPUT.mkdir(parents=True, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
}


class LogoFinder(html.parser.HTMLParser):
    """Parse HTML to find logo image candidates."""

    def __init__(self, base_url):
        super().__init__()
        self.base_url = base_url
        self.candidates = []
        self._in_header = False
        self._header_depth = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        # <link rel="icon" href="...">
        if tag == "link" and attrs.get("rel", "").lower() in (
            "icon", "shortcut icon",
        ):
            if attrs.get("href"):
                self.candidates.append(urljoin(self.base_url, attrs["href"]))
        # <meta property="og:image" content="...">
        if tag == "meta" and attrs.get("property") == "og:image":
            if attrs.get("content"):
                self.candidates.append(urljoin(self.base_url, attrs["content"]))
        # <img src="..." with "logo" in class/id/src
        if tag == "img" and attrs.get("src"):
            src = attrs["src"]
            classes = attrs.get("class", "")
            id_ = attrs.get("id", "")
            if any(kw in src.lower() + classes.lower() + id_.lower()
                   for kw in ["logo", "brand", "header-logo"]):
                self.candidates.append(urljoin(self.base_url, src))
        # Track header/nav for logo images
        if tag in ("header", "nav"):
            self._in_header = True
            self._header_depth += 1
        if self._in_header and tag == "img" and attrs.get("src"):
            self.candidates.append(urljoin(self.base_url, attrs["src"]))

    def handle_endtag(self, tag):
        if tag in ("header", "nav") and self._in_header:
            self._header_depth -= 1
            if self._header_depth <= 0:
                self._in_header = False


import ssl
ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE


def fetch(url, timeout=5):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=timeout, context=ssl_ctx) as r:
        return r.read()


def try_favicon(base_url):
    for path in ["/favicon.ico", "/favicon.png", "/apple-touch-icon.png"]:
        url = urljoin(base_url, path)
        try:
            data = fetch(url, timeout=5)
            if len(data) > 100:
                return url, data
        except Exception:
            continue
    return None, None


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


SCHOOLS = [
    ("UL", "Universite de Lome", "https://univ-lome.tg"),
    ("UK", "Universite de Kara", "https://univ-kara.tg"),
    ("ENS", "ENS Atakpame", "https://ensatakpame.com"),
    ("CIREL", "CIREL", "https://univ-lome.tg"),
    ("ESGIS", "ESGIS", "https://www.esgis.org"),
    ("ESAG_NDE", "ESAG-NDE", "https://esagnde.org"),
    ("ESA", "ESA", "https://www.esatogo.com"),
    ("UCAO_UUT", "UCAO-UUT", "https://ucao-uut.tg"),
    ("ESAM", "ESAM", "https://www.esamecole.fr"),
    ("DEFITECH", "DEFITECH", "https://defitech.tg"),
    ("ESPC", "ESPC", "http://espctogo.com"),
    ("ISM_Adonai", "ISM Adonai", "https://ismadonai.net"),
    ("ISAGES", "ISAGES", "https://www.isagestogo.com"),
    ("FIMAC", "FIMAC", "https://fimactogo.com"),
    ("IPBTP", "IPBTP", "http://ipbtp-togo.com"),
    ("ESMA", "ESMA", "https://esmatogo.com"),
    ("ESSEG", "ESSEG", "https://essegtogo.com"),
    ("ESIBA", "ESIBA Business School", "http://esiba-business.com"),
    ("LUCAS", "LUCAS University", "https://lucasuniversity.org"),
    ("LBS", "Lome Business School", "https://lomebusinesschool.com"),
    ("UST_TG", "UST-TG", "https://ust-tg.com"),
    ("ENAM", "ENAM", "https://enam-togo.com"),
    ("CIFOP", "CIFOP", "http://www.cifoptogo.net"),
    ("NIT", "NIT Dapaong", "https://nitedu.org"),
    ("CIB_INTA", "CIB-INTA", "http://cib-inta.com"),
    ("CPTEC", "CPTEC Universite", "https://cptecedu.org"),
    ("IHERIS", "IHERIS University", "https://iheris.com"),
    ("ISTM", "ISTM", "https://istmtogo.com"),
    ("IAEC", "IAEC University", "https://iaec-university.tg"),
]

for short, name, url in SCHOOLS:
    safe = slugify(short)
    print(f"\n=== {name} ({url}) ===")
    saved = False

    # 1. Favicon direct
    found_url, data = try_favicon(url)
    if data:
        ext = found_url.rsplit(".", 1)[-1] if "." in found_url else "ico"
        ext = ext.split("?")[0][:4]
        (OUTPUT / f"{safe}.{ext}").write_bytes(data)
        print(f"  [OK] Favicon ({len(data)} bytes)")
        saved = True

    # 2. Scrape HTML for better logo
    try:
        html_data = fetch(url, timeout=5)
        text = html_data.decode("utf-8", errors="replace")
        finder = LogoFinder(url)
        finder.feed(text)
        for logo_url in finder.candidates[:10]:
            try:
                img_data = fetch(logo_url, timeout=6)
                if len(img_data) > 500:
                    ext = logo_url.rsplit(".", 1)[-1].split("?")[0][:4] or "png"
                    (OUTPUT / f"{safe}_logo.{ext}").write_bytes(img_data)
                    print(f"  [OK] Logo -> {logo_url} ({len(img_data)} bytes)")
                    saved = True
                    break
            except Exception:
                continue
    except Exception as e:
        print(f"  Erreur: {e}")

    if not saved:
        print("  [--] Aucun logo trouve")


# Generate JSON map
import json
files = {}
for f in sorted(OUTPUT.iterdir()):
    if f.is_file():
        key = f.stem.replace("_logo", "")
        files.setdefault(key, []).append(f.name)

manifest = OUTPUT / "_manifest.json"
manifest.write_text(json.dumps(files, indent=2))
print(f"\nManifest: {manifest}")
print(f"Fichiers: {len(list(OUTPUT.iterdir()))}")
print(f"Dossier: {OUTPUT}")

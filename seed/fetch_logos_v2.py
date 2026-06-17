#!/usr/bin/env python3
"""Télécharge les favicons/logos des écoles du Togo — URLs vérifiées."""

import re
import os
import socket
import ssl
import urllib.request
import urllib.error
import html.parser
import json
from pathlib import Path
from urllib.parse import urljoin

socket.setdefaulttimeout(6)

ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

OUTPUT = Path("/tmp/universite_logos_v2")
OUTPUT.mkdir(parents=True, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
}


class LogoFinder(html.parser.HTMLParser):
    def __init__(self, base_url):
        super().__init__()
        self.base_url = base_url
        self.candidates = []
        self._in_header = False
        self._header_depth = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "link" and attrs.get("rel", "").lower() in ("icon", "shortcut icon"):
            if attrs.get("href"):
                self.candidates.append(urljoin(self.base_url, attrs["href"]))
        if tag == "meta" and attrs.get("property") == "og:image":
            if attrs.get("content"):
                self.candidates.append(urljoin(self.base_url, attrs["content"]))
        if tag == "img" and attrs.get("src"):
            src = attrs["src"]
            classes = attrs.get("class", "")
            id_ = attrs.get("id", "")
            if any(kw in src.lower() + classes.lower() + id_.lower()
                   for kw in ["logo", "brand", "header-logo"]):
                self.candidates.append(urljoin(self.base_url, src))
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


def fetch(url, timeout=5):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=timeout, context=ssl_ctx) as r:
        return r.read()


def try_favicon(base_url):
    for path in ["/favicon.ico", "/favicon.png", "/apple-touch-icon.png"]:
        url = urljoin(base_url, path)
        try:
            data = fetch(url, timeout=4)
            if len(data) > 100:
                return url, data
        except Exception:
            continue
    return None, None


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


SCHOOLS = [
    # Publics
    ("UL", "Universite de Lome", "https://univ-lome.tg"),
    ("UK", "Universite de Kara", "https://univkara.tg"),
    ("ENS", "ENS Atakpame", "https://ensatakpame.com"),
    ("CIREL", "CIREL", "https://univ-lome.tg"),
    ("ENA", "ENA Togo", "https://ena.tg"),
    ("ENI", "ENI Togo", ""),
    ("ENAM", "ENAM", ""),
    ("ENSF", "ENSF", ""),
    ("EAMAU", "EAMAU", "https://eamau.org"),

    # Grandes ecoles privees CAMES
    ("ESGIS", "ESGIS", "https://www.esgis.org"),
    ("ESAG_NDE", "ESAG-NDE", "https://esagnde.org"),
    ("ESA", "ESA", "https://www.esatogo.com"),
    ("UCAO_UUT", "UCAO-UUT", "https://ucao-uut.tg"),
    ("ESAM", "ESAM", "https://www.esamecole.fr"),
    ("DEFITECH", "DEFITECH", "https://defitech.tg"),
    ("ISM_Adonai", "ISM Adonai", "https://ismadonai.net"),
    ("IAEC", "IAEC University", "https://iaec-university.tg"),
    ("ESIBA", "ESIBA Business School", "https://esiba.tg"),
    ("AIC", "AIC University", "https://aic-uni.org"),

    # Prives
    ("ISAGES", "ISAGES", "https://www.isagestogo.com"),
    ("FIMAC", "FIMAC", "https://fimac.tg"),
    ("ESMA", "ESMA", "https://esmatogo.com"),
    ("ESSEG", "ESSEG", "https://essegtogo.com"),
    ("LBS", "Lome Business School", "https://lome-bs.com"),
    ("UST_TG", "UST-TG", "https://usttogo.com"),
    ("IHERIS", "IHERIS University", "https://iheris.net"),
    ("IAI", "IAI-Togo", "https://iai-togo.tg"),
    ("CIFOP", "CIFOP", "http://www.cifoptogo.net"),
    ("CPTEC", "CPTEC Universite", "https://cptecedu.org"),
    ("CFP_Ancilla", "CFP Ancilla", "https://cfbtogo.tg"),
    ("ESPC", "ESPC", ""),
    ("IPBTP", "IPBTP", ""),
    ("NIT", "NIT Dapaong", ""),
    ("CIB_INTA", "CIB-INTA", ""),
    ("ISTM", "ISTM", ""),
    ("LUCAS", "LUCAS University", ""),
    ("ESCA", "ESCA", ""),
    ("ESEC", "ESEC", ""),
    ("ESTECA", "ESTECA", "https://esteca.over-blog.com"),
    ("ESTEG", "ESTEG", ""),
    ("ESTABAT", "ESTABAT", ""),
    ("ESUP_IEG", "ESUP IEG", ""),
    ("ESIG_Global", "ESIG Global Success", ""),
    ("ISAC", "ISAC", ""),
    ("ISDI", "ISDI SA", ""),
    ("ISOR", "ISOR Togo", ""),
    ("ISMAD", "ISMAD", ""),
    ("ISSECK", "ISSECK", ""),
    ("ISPSH", "ISPSH", ""),
    ("IFTGI", "IFTGI", ""),
    ("IITM", "IITM", ""),
    ("ISDB", "ISDB", ""),
    ("IIHT", "IIHT", ""),
    ("IMS", "IMS", ""),
    ("FORMATEC", "FORMATEC", ""),
    ("CEFIP", "CEFIP", ""),
    ("CFBT", "CFBT", ""),
    ("HETML", "HETML", ""),
    ("HIUI", "HIUI", ""),
    ("GUST", "GUST", ""),
    ("JUMAU_ITA", "JUMAU-ITA", ""),
    ("UBLT", "UBLT", ""),
    ("IRFODEL", "IRFODEL", ""),
    ("ESCG", "ESCG", ""),
    ("HTIB_Atlantis", "HTIB Atlantis", ""),
    ("IADSS", "IADSS", ""),
    ("IUA", "IUA", ""),
    ("LANGCENTER", "LANGCENTER INT", ""),
    ("Hotel_Avenida", "Hotel Ecole Avenida", ""),
    ("Technocrate", "Le Technocrate", ""),
    ("Bakpessi", "Institut Bakpessi", ""),

    # Bonus Bloc D avec sites
    ("IAEC", "IAEC University", "https://iaec-university.tg"),
]

def process_school(short, name, url):
    safe = slugify(short)
    if not url:
        return False
    print(f"\n=== {name} ({url}) ===")

    # 1. Favicon
    found_url, data = try_favicon(url)
    if data:
        ext = found_url.rsplit(".", 1)[-1].split("?")[0][:4] if "." in found_url else "ico"
        (OUTPUT / f"{safe}.{ext}").write_bytes(data)
        print(f"  [OK] Favicon ({len(data)} bytes)")

    # 2. HTML scraping
    try:
        html_data = fetch(url, timeout=5)
        text = html_data.decode("utf-8", errors="replace")
        finder = LogoFinder(url)
        finder.feed(text)
        for logo_url in finder.candidates[:10]:
            try:
                img_data = fetch(logo_url, timeout=4)
                if len(img_data) > 500:
                    ext = logo_url.rsplit(".", 1)[-1].split("?")[0][:4] or "png"
                    (OUTPUT / f"{safe}_logo.{ext}").write_bytes(img_data)
                    print(f"  [OK] Logo -> {logo_url} ({len(img_data)} bytes)")
                    return True
            except Exception:
                continue
    except Exception as e:
        print(f"  Erreur: {e}")
        return False

    if data:
        return True
    print("  [--] Aucun logo")
    return False


for short, name, url in SCHOOLS:
    process_school(short, name, url)

# Manifest
files = {}
for f in sorted(OUTPUT.iterdir()):
    if f.is_file() and f.suffix != ".json":
        key = f.stem.replace("_logo", "")
        files.setdefault(key, []).append(f.name)

(OUTPUT / "_manifest.json").write_text(json.dumps(files, indent=2))
print(f"\n=== Termine ===")
print(f"Dossier: {OUTPUT}")
print(f"Fichiers: {len(list(OUTPUT.iterdir()))}")

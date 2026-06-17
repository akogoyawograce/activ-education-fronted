#!/usr/bin/env python3
"""Upload logos des écoles du Togo dans MinIO via l'API."""

import json
import os
import socket
import ssl
import mimetypes
import urllib.request
import urllib.error
import re
from pathlib import Path

socket.setdefaulttimeout(15)

ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

API = "http://4.233.145.112:8080/api/v1"

LOGO_DIR = Path("/home/grace/Projet-activ-education/activ-education/backoffice/public/images/universites")

# Map short names -> titres to search in API
SCHOOL_MAP = {
    "ul": "Université de Lomé",
    "uk": "Université de Kara",
    "cirel": "CIREL",
    "esgis": "ESGIS",
    "esag_nde": "ESAG",
    "esa": "École Supérieure des Affaires",
    "ucao_uut": "UCAO",
    "esam": "ESAM",
    "defitech": "DEFITECH",
    "ism_adonai": "ISM Adonaï",
    "isages": "ISAGES",
    "esma": "ESMA",
    "esseg": "ESSEG",
    "esteca": "ESTECA",
    "esiba": "ESIBA",
    "lbs": "LBS",
    "iheris": "IHERIS",
    "iai": "IAI-Togo",
    "iaec": "IAEC",
    "aic": "AIC",
}


def api_request(method, path, data=None, headers=None, multipart=None):
    url = f"{API}{path}"
    h = {"User-Agent": "opencode/1.0"}
    if headers:
        h.update(headers)

    if multipart:
        boundary = "----BOUNDARY" + os.urandom(8).hex()
        h["Content-Type"] = f"multipart/form-data; boundary={boundary}"
        body = []
        for field_name, filepath, filename in multipart:
            body.append(f"--{boundary}".encode())
            body.append(
                f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"'.encode()
            )
            content_type, _ = mimetypes.guess_type(filename)
            if content_type:
                body.append(f"Content-Type: {content_type}".encode())
            body.append(b"")
            body.append(open(filepath, "rb").read())
        body.append(f"--{boundary}--".encode())
        body_bytes = b"\r\n".join(body)
        req = urllib.request.Request(url, data=body_bytes, headers=h, method=method)
    elif data:
        body = json.dumps(data).encode()
        h.setdefault("Content-Type", "application/json")
        req = urllib.request.Request(url, data=body, headers=h, method=method)
    else:
        req = urllib.request.Request(url, headers=h, method=method)

    with urllib.request.urlopen(req, timeout=15, context=ssl_ctx) as r:
        return json.loads(r.read())


# 1. Login
print("=== Login ===")
resp = api_request("POST", "/auth/login", {"email": "admin@activeducation.tg", "motDePasse": "admin123!"})
token = resp["accessToken"]
print(f"Token: {token[:50]}...")

headers = {"Authorization": f"Bearer {token}"}

# 2. Get all etablissements
print("\n=== Fetching etablissements ===")
all_data = api_request("GET", "/bibliotheque/etablissements?size=500", headers=headers)
etabs = {e["titre"].lower(): e for e in all_data.get("content", [])}
print(f"Total: {len(etabs)} etablissements")

# 3. Map and upload
print("\n=== Upload logos ===")
logo_files = {}
for f in LOGO_DIR.iterdir():
    if f.is_file() and f.suffix.lower() in (".png", ".jpg", ".jpeg", ".ico", ".gif"):
        name = f.stem.replace("_logo", "").replace("_favicon", "")
        logo_files.setdefault(name, []).append(f)

uploaded = 0
not_found = 0
for short, search_name in SCHOOL_MAP.items():
    files = logo_files.get(short, [])
    if not files:
        print(f"  [--] {search_name}: aucun fichier logo")
        continue

    # Pick the largest file as logo
    best = max(files, key=lambda f: f.stat().st_size)
    # Skip .ico if we have a png/jpg
    for f in files:
        if f.suffix.lower() in (".png", ".jpg", ".jpeg") and f.stat().st_size > best.stat().st_size * 0.5:
            best = f
            break

    # Find matching etablissement
    matching_tracking_id = None
    # Exact match first
    key = search_name.lower()
    if key in etabs:
        matching_tracking_id = etabs[key]["trackingId"]
    else:
        # Fuzzy match
        for etab_key, etab in etabs.items():
            # Check if search_name is contained in titre or vice versa
            if (search_name.lower() in etab_key or
                etab_key in search_name.lower() or
                any(w in etab_key for w in search_name.lower().split() if len(w) > 3)):
                matching_tracking_id = etab["trackingId"]
                print(f"    -> Fuzzy match: '{etab['titre']}'")
                break

    if not matching_tracking_id:
        print(f"  [!!] {search_name}: etablissement non trouve dans l'API")
        not_found += 1
        continue

    # Upload
    try:
        filename = f"logo_{short}{best.suffix}"
        multipart = [("images", str(best), filename)]
        api_request("POST", f"/bibliotheque/etablissements/{matching_tracking_id}/medias",
                     headers=headers, multipart=multipart)
        print(f"  [OK] {search_name} -> {best.name} ({best.stat().st_size} bytes)")
        uploaded += 1
    except Exception as e:
        print(f"  [ERR] {search_name}: {e}")

print(f"\n=== Termine: {uploaded} uploades, {not_found} non trouves ===")

#!/usr/bin/env python3
"""Crée ESSEG dans l'API et upload son logo."""

import json
import os
import ssl
import mimetypes
import urllib.request
import urllib.error
import re
from pathlib import Path

ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

API = "http://4.233.145.112:8080/api/v1"


def req(method, path, data=None, headers=None, mp_files=None):
    url = f"{API}{path}"
    h = {"User-Agent": "opencode/1.0"}
    if headers:
        h.update(headers)
    if mp_files:
        boundary = "----BOUNDARY" + os.urandom(8).hex()
        h["Content-Type"] = f"multipart/form-data; boundary={boundary}"
        parts = []
        for name, fpath, fname in mp_files:
            parts.append(f"--{boundary}".encode())
            parts.append(f'Content-Disposition: form-data; name="{name}"; filename="{fname}"'.encode())
            ct, _ = mimetypes.guess_type(fname)
            if ct:
                parts.append(f"Content-Type: {ct}".encode())
            parts.append(b"")
            parts.append(open(fpath, "rb").read())
        parts.append(f"--{boundary}--".encode())
        body = b"\r\n".join(parts)
        req = urllib.request.Request(url, data=body, headers=h, method=method)
    elif data:
        body = json.dumps(data).encode()
        h["Content-Type"] = "application/json"
        req = urllib.request.Request(url, data=body, headers=h, method=method)
    else:
        req = urllib.request.Request(url, headers=h, method=method)
    with urllib.request.urlopen(req, timeout=15, context=ssl_ctx) as r:
        return json.loads(r.read())


# Login
print("=== Login ===")
r = req("POST", "/auth/login", {"email": "admin@activeducation.tg", "motDePasse": "admin123!"})
token = r["accessToken"]
hdr = {"Authorization": f"Bearer {token}"}
print("OK")

# Check if ESSEG already exists
print("\n=== Check existence ===")
all_etabs = req("GET", "/bibliotheque/etablissements?size=500", headers=hdr)
for e in all_etabs.get("content", []):
    if "esseg" in e["titre"].lower():
        print(f"DEJA EXISTANT: {e['titre']} ({e['trackingId']})")
        exit(0)
print("N'existe pas -> creation")

# Get filieres trackingIds
print("\n=== Get filieres ===")
all_filieres = req("GET", "/bibliotheque/filieres?size=100", headers=hdr)
filieres_map = {f["titre"].lower(): f["trackingId"] for f in all_filieres.get("content", [])}

needed = ["economie", "finance", "gestion des entreprises", "mathematiques appliquees"]
filieres_ids = []
for n in needed:
    match = None
    for k, v in filieres_map.items():
        if n in k or k in n:
            match = v
            break
    if match:
        filieres_ids.append(match)
        print(f"  {n} -> {match}")
    else:
        print(f"  [!!] {n}: non trouve")

# Create ESSEG
print("\n=== Create ESSEG ===")
body = {
    "titre": "ESSEG Dr DJOKA — École Supérieure des Sciences Économiques et de Gestion Statistique",
    "resume": "1ère université privée togolaise offrant les mêmes formations que les FASEG des universités publiques. Spécialité unique : la Statistique, avec concours d'entrée. Diplômes reconnus par les universités publiques du Togo et agréés MESR.",
    "contenu": "L'ESSEG Dr DJOKA est la 1ère université privée togolaise à offrir les mêmes formations que les FASEG des universités publiques. Spécialité unique : la Statistique, avec concours d'entrée. Ses diplômes sont reconnus par les universités publiques du Togo et agréés MESR.",
    "estPublie": True,
    "adresse": "Lomé",
    "ville": "Lomé",
    "typeEtablissement": "UNIVERSITE",
    "niveau": "Licence, Master",
    "contacts": "",
    "siteWeb": "https://essegtogo.com",
    "offreFormation": "Licence, Master — Statistique, Économie-Gestion, Comptabilité — Concours d'entrée pour Statistique",
    "estPublic": False,
    "filieresTrackingIds": filieres_ids,
}

new = req("POST", "/bibliotheque/etablissements", body, headers=hdr)
tid = new["trackingId"]
print(f"  Cree: {tid} -> {new['titre']}")

# Upload logo
print("\n=== Upload logo ===")
logo_dir = "/home/grace/Projet-activ-education/activ-education/backoffice/public/images/universites"
esseg_logo = None
for f in os.listdir(logo_dir):
    if f.startswith("esseg"):
        esseg_logo = os.path.join(logo_dir, f)
if esseg_logo and os.path.isfile(esseg_logo):
    req("POST", f"/bibliotheque/etablissements/{tid}/medias",
        headers=hdr,
        mp_files=[("images", esseg_logo, f"logo_esseg{os.path.splitext(esseg_logo)[1]}")])
    print(f"  Logo upload: {esseg_logo}")
else:
    print("  [--] Aucun fichier logo ESSEG trouve")

print("\n=== Termine ===")

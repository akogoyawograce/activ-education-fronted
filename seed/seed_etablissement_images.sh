#!/bin/bash
# seed_etablissement_images.sh — Ajoute des images aux établissements seedés
# Usage: bash seed_etablissement_images.sh [email] [password]
# À exécuter APRÈS seed_bibliotheque.sh
#
# Liste les établissements via GET /api/v1/bibliotheque/etablissements
# puis upload une image pour chacun via POST /{trackingId}/medias.
#
# Ajoutez de nouvelles entrées dans le tableau IMAGES_URLS ci-dessous
# pour associer un nom d'établissement à une image Wikimedia.

API="http://4.233.145.112:8080/api/v1"
EMAIL="${1:-admin@activeducation.tg}"
PASS="${2:-admin123!}"

# ─── Mapping établissement → URL image ────────────────────────────────
# Seuls les établissements listés ici recevront une image spécifique.
# Les autres reçoivent GENERIC_IMAGE par défaut.
GENERIC_IMAGE="https://www.svgrepo.com/show/532355/school.svg"

# On stocke le mapping dans un fichier temporaire pour éviter les
# problèmes de scope avec les tableaux associatifs bash dans les pipes.
MAPPING=$(mktemp)
# Format: titre|url_image (une par ligne)
cat > "$MAPPING" << 'MAPEOF'
Université de Lomé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Université de Kara|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Université des Sciences de la Santé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
École Nationale d'Administration (ENA)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
École Polytechnique de Lomé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Institut National de la Jeunesse et des Sports (INJS)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
École Supérieure d'Agronomie (ESA)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée de Tokoin|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée de Kégué|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée d'Adidogomé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée de Bè|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée de Kara|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée d'Atakpamé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée de Sokodé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée Technique de Lomé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée Technique de Kara|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Lycée Technique d'Atakpamé|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Institut Supérieur de Gestion (ISG)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Université Catholique de l'Afrique de l'Ouest (UCAO)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Université WASCAL|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
École Supérieure des Techniques Biologiques|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
Centre de Formation et de Perfectionnement (CFP)|https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/School.svg/1280px-School.svg.png
MAPEOF

# ─── Fin mapping ─────────────────────────────────────────────────────

echo "╔═══════════════════════════════════════════════╗"
echo "║   SEED IMAGES ÉTABLISSEMENTS                  ║"
echo "╚═══════════════════════════════════════════════╝"

echo ""
echo "=== Authentification ==="
TOKEN=$(curl -s -X POST "$API/auth/login" -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"motDePasse\": \"$PASS\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")
AUTH="Authorization: Bearer $TOKEN"
echo "Token obtenu"

echo ""
echo "=== Récupération de tous les établissements ==="
JSON_FILE=$(mktemp)
# Récupérer toutes les pages
python3 -c "
import json, subprocess, os, sys

api = '$API'
auth = '$AUTH'
all_items = []
page = 0
while True:
    result = subprocess.run(['curl', '-s', f'{api}/bibliotheque/etablissements?page={page}&size=50', '-H', auth],
                          capture_output=True, text=True)
    if result.returncode != 0:
        break
    data = json.loads(result.stdout)
    items = data.get('content', []) if 'content' in data else data
    if not items:
        break
    all_items.extend(items)
    page += 1
    if len(items) < 50:
        break

with open('$JSON_FILE', 'w') as f:
    json.dump(all_items, f)
print(f'{len(all_items)} établissements trouvés')
"

echo ""
echo "=== Upload des images ==="
mkdir -p /tmp/seed_images

# Générer une image placeholder locale (pour éviter les blocages de téléchargement)
python3 -c "
from PIL import Image
img = Image.new('RGB', (400, 300), (41, 128, 185))
from PIL import ImageDraw, ImageFont
draw = ImageDraw.Draw(img)
draw.text((50, 130), 'Activ Education', fill=(255, 255, 255))
img.save('/tmp/seed_images/placeholder.png')
" 2>/dev/null || python3 -c "
# Fallback: create minimal PNG manually
import struct, zlib
def create_png(width, height, r, g, b):
    raw = b''
    for y in range(height):
        raw += b'\x00' + bytes([r, g, b]) * width
    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b'')
with open('/tmp/seed_images/placeholder.png', 'wb') as f:
    f.write(create_png(400, 300, 41, 128, 185))
"

python3 -c "
import sys, json, subprocess, os

api = '$API'
auth = '$AUTH'

with open('$JSON_FILE') as f:
    data = json.load(f)
items = data if isinstance(data, list) else (data.get('content', []) if 'content' in data else data)

mapping = {}
with open('$MAPPING') as f:
    for line in f:
        line = line.strip()
        if '|' in line:
            titre, url = line.split('|', 1)
            mapping[titre] = url

for e in items:
    tid = e['trackingId']
    titre = e['titre']
    url = mapping.get(titre, '')
    
    if url:
        print(f'  {titre}... ', end='', flush=True)
        try:
            import urllib.request
            ext = 'jpg'
            tmpfile = f'/tmp/seed_images/{tid}.{ext}'
            urllib.request.urlretrieve(url, tmpfile)
            result = subprocess.run(['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
                '-X', 'POST', f'{api}/bibliotheque/etablissements/{tid}/medias',
                '-H', auth, '-F', f'images=@{tmpfile}'], capture_output=True, text=True)
            http = result.stdout.strip()
            print(f'{\"✓\" if http in (\"200\",\"201\") else \"✗\"} ({http})')
            os.remove(tmpfile)
        except Exception as ex:
            print(f'✗ {ex}')
    else:
        # Upload placeholder
        print(f'  {titre}... ', end='', flush=True)
        result = subprocess.run(['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
            '-X', 'POST', f'{api}/bibliotheque/etablissements/{tid}/medias',
            '-H', auth, '-F', 'images=@/tmp/seed_images/placeholder.png'], capture_output=True, text=True)
        http = result.stdout.strip()
        print(f'{\"✓\" if http in (\"200\",\"201\") else \"✗\"} ({http})')
" 2>&1

echo ""
echo "=== Nettoyage ==="
rm -rf /tmp/seed_images "$JSON_FILE" "$MAPPING"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║      SEED IMAGES TERMINÉ !                    ║"
echo "╚═══════════════════════════════════════════════╝"

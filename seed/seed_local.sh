#!/bin/bash
# seed_local.sh — Exécute tous les scripts seed contre l'API locale
# Usage: bash seed_local.sh [email] [password]

set -e

SEED_DIR="$(cd "$(dirname "$0")" && pwd)"
EMAIL="${1:-admin@activeducation.tg}"
PASS="${2:-admin123!}"
API="http://localhost:8080/api/v1"

echo "╔═══════════════════════════════════════════════╗"
echo "║     SEED LOCAL — Activ Education              ║"
echo "╚═══════════════════════════════════════════════╝"
echo "API : $API"
echo ""

# Vérifier que l'API répond
echo "=== Vérification API ==="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api-docs 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "200" ]; then
  echo "ERREUR : API inaccessible (HTTP $HTTP_CODE)"
  echo "Assure-toi que le backend tourne sur http://localhost:8080"
  exit 1
fi
echo "API OK"
echo ""

run_script() {
  local name="$1" script="$2"
  echo "=== $name ==="
  sed "s|API=\"http://4.233.145.112:8080/api/v1\"|API=\"$API\"|" "$script" | bash -s "$EMAIL" "$PASS"
  echo ""
}

run_script "1/4 : Bibliothèque (séries, filières, métiers, établissements, FAQ)" \
  "$SEED_DIR/seed_bibliotheque.sh"

run_script "2/4 : Images des établissements" \
  "$SEED_DIR/seed_etablissement_images.sh"

run_script "3/4 : Quiz (RIASEC + Personnalité)" \
  "$SEED_DIR/seed_quiz.sh"

run_script "4/4 : Établissements supérieurs" \
  "$SEED_DIR/seed_universites.sh"

echo "╔═══════════════════════════════════════════════╗"
echo "║        SEED LOCAL TERMINÉ AVEC SUCCÈS !       ║"
echo "╚═══════════════════════════════════════════════╝"

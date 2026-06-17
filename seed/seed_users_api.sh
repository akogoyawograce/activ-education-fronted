#!/bin/bash
# seed_users_api.sh — Crée les utilisateurs via l'API (alternative à seed_users.sql pour H2)
# Usage: bash seed_users_api.sh [email] [password]
API="http://localhost:8080/api/v1"
EMAIL="${1:-admin@activeducation.tg}"
PASS="${2:-admin123!}"

echo "=== Authentification ==="
TOKEN=$(curl -s -X POST "$API/auth/login" -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"motDePasse\": \"$PASS\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")
AUTH="Authorization: Bearer $TOKEN"
echo "Token obtenu"
echo ""

echo "=== Création des administrateurs ==="
post_admin() {
  local email="$1" nom="$2" prenom="$3" niveau="$4"
  local resp=$(curl -s -w "\n%{http_code}" -X POST "$API/administrateurs" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"motDePasse\":\"admin123\",\"nom\":\"$nom\",\"prenom\":\"$prenom\",\"niveauAcces\":\"$niveau\"}")
  local code=$(echo "$resp" | tail -1)
  if [ "$code" = "201" ]; then echo "  ✓ $email ($niveau)"; else echo "  ✗ $email: HTTP $code"; fi
}

post_admin "superadmin@activ-education.com" "Admin" "Super" "SUPER_ADMIN"
post_admin "moderateur@activ-education.com" "Modérateur" "Admin" "MODERATEUR"
post_admin "gestionnaire@activ-education.com" "Gestionnaire" "Admin" "GESTIONNAIRE_CONSEILLER"

echo ""
echo "=== Création des conseillers ==="
post_conseiller() {
  local email="$1" nom="$2" prenom="$3" specialites="$4" bio="$5" qualifs="$6" exp="$7"
  local resp=$(curl -s -w "\n%{http_code}" -X POST "$API/conseillers" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"motDePasse\":\"admin123\",\"nom\":\"$nom\",\"prenom\":\"$prenom\",\"specialites\":\"$specialites\",\"biographie\":\"$bio\",\"qualifications\":\"$qualifs\",\"anneesExperience\":$exp}")
  local code=$(echo "$resp" | tail -1)
  if [ "$code" = "201" ]; then echo "  ✓ $email"; else echo "  ✗ $email: HTTP $code"; fi
}

post_conseiller "conseiller1@activ-education.com" "Kodjo" "Jean" \
  "Orientation scolaire, Psychologie" \
  "Conseiller spécialisé dans l orientation des lycéens." \
  "Master en Psychologie de l Éducation" 5
post_conseiller "conseiller2@activ-education.com" "Lawson" "Marie" \
  "Orientation professionnelle, Bilan de compétences" \
  "Experte en reconversion professionnelle." \
  "Master en Conseil en Orientation" 8

echo ""
echo "=== Création élève ==="
post_eleve() {
  local email="$1" nom="$2" prenom="$3" niveau="$4" type="$5" etablissement="$6" filiere="$7"
  local resp=$(curl -s -w "\n%{http_code}" -X POST "$API/eleves" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"motDePasse\":\"pass1234\",\"nom\":\"$nom\",\"prenom\":\"$prenom\",\"telephone\":\"+22890000006\",\"niveauEtude\":\"$niveau\",\"typeApprenant\":\"$type\",\"etablissementActuel\":\"$etablissement\",\"filiere\":\"$filiere\"}")
  local code=$(echo "$resp" | tail -1)
  if [ "$code" = "201" ]; then
    echo "  ✓ $email"
    # Récupérer le trackingId pour associer le parent
    ELEVE_TRACKING=$(echo "$resp" | head -1 | python3 -c "import sys,json; print(json.load(sys.stdin).get('trackingId',''))" 2>/dev/null)
  else
    echo "  ✗ $email: HTTP $code"
    ELEVE_TRACKING=""
  fi
}

ELEVE_TRACKING=""
post_eleve "eleve1@activ-education.com" "Koffi" "Akossiwa" "Terminale" "LYCEEN" "Lycée de Tokoin" "Série C"
ELEVE_ID=$(curl -s "$API/eleves?email=eleve1@activ-education.com" -H "$AUTH" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['content'][0]['trackingId'] if d.get('content') else '')" 2>/dev/null)

echo ""
echo "=== Création parent ==="
post_parent() {
  local email="$1" nom="$2" prenom="$3" telephone="$4"
  local resp=$(curl -s -w "\n%{http_code}" -X POST "$API/parents" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"motDePasse\":\"parent123\",\"nom\":\"$nom\",\"prenom\":\"$prenom\",\"telephone\":\"$telephone\"}")
  local code=$(echo "$resp" | tail -1)
  if [ "$code" = "201" ]; then echo "  ✓ $email"; else echo "  ✗ $email: HTTP $code"; fi
}

post_parent "parent1@activ-education.com" "Koffi" "Mensah" "+22890000007"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║        SEED USERS TERMINÉ !                    ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "Identifiants :"
echo "  superadmin@activ-education.com / admin123"
echo "  moderateur@activ-education.com / admin123"
echo "  gestionnaire@activ-education.com / admin123"
echo "  conseiller1@activ-education.com / admin123"
echo "  conseiller2@activ-education.com / admin123"
echo "  eleve1@activ-education.com / pass1234"
echo "  parent1@activ-education.com / parent123"

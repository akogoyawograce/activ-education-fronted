#!/bin/bash
# seed_quiz.sh — Crée des quizzes via l'API (nécessite JWT admin)
# Usage: bash seed_quiz.sh [email] [password]
#        bash seed_quiz.sh admin@activeducation.tg admin123!

API="http://4.233.145.112:8080/api/v1"
EMAIL="${1:-admin@activeducation.tg}"
PASS="${2:-admin123!}"

echo "=== Authentification ==="
TOKEN=$(curl -s -X POST "$API/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"motDePasse\": \"$PASS\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")
echo "Token obtenu"

AUTH="Authorization: Bearer $TOKEN"

create_quiz() {
  local titre="$1" desc="$2"
  local q=$(curl -s -X POST "$API/quiz" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"titre\": \"$titre\", \"description\": \"$desc\", \"estActif\": true}")
  echo "$q" | python3 -c "import sys,json; print(json.load(sys.stdin)['trackingId'])"
}

add_question() {
  local qid="$1" texte="$2" ordre="$3"
  local q=$(curl -s -X POST "$API/quiz/$qid/questions" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"texteQuestion\": \"$texte\", \"ordre\": $ordre}")
  echo "$q" | python3 -c "import sys,json; print(json.load(sys.stdin)['trackingId'])"
}

add_r() {
  local qst="$1" texte="$2" cat="$3" pts="$4"
  curl -s -X POST "$API/questions/$qst/reponses" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"texteReponse\": \"$texte\", \"categoriePoint\": \"$cat\", \"points\": $pts}" > /dev/null
}

# ─── Quiz 1 : RIASEC ──────────────────────────────────────────────
echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║        Quiz RIASEC (30 questions)              ║"
echo "╚═══════════════════════════════════════════════╝"

RIASEC_ID=$(create_quiz \
  "Test d Orientation RIASEC" \
  "Quiz de découverte des profils RIASEC (Réaliste, Investigateur, Artistique, Social, Entreprenant, Conventionnel)")
echo "RIASEC ID: $RIASEC_ID"

q() { add_question "$RIASEC_ID" "$1" "$2"; }

echo "-- Réaliste"
Q=$(q "J aime construire ou réparer des objets" 1)
add_r "$Q" "Oui, j adore ça" "R" 5; add_r "$Q" "Ça peut me plaire" "R" 3; add_r "$Q" "Pas vraiment" "R" 1; add_r "$Q" "Non, pas du tout" "R" 0
Q=$(q "Je préfère les activités manuelles aux travaux intellectuels" 2)
add_r "$Q" "Tout à fait d accord" "R" 5; add_r "$Q" "Plutôt d accord" "R" 3; add_r "$Q" "Plutôt pas d accord" "R" 1; add_r "$Q" "Pas du tout d accord" "R" 0
Q=$(q "J aime travailler dehors plutôt qu enfermé dans un bureau" 3)
add_r "$Q" "Oui, j aime le plein air" "R" 5; add_r "$Q" "Ça dépend des jours" "R" 3; add_r "$Q" "Je préfère l intérieur" "R" 1; add_r "$Q" "Pas du tout" "R" 0
Q=$(q "Je suis doué(e) pour utiliser des outils et des machines" 4)
add_r "$Q" "Oui, c est mon point fort" "R" 5; add_r "$Q" "Assez doué(e)" "R" 3; add_r "$Q" "Pas vraiment" "R" 1; add_r "$Q" "Non, pas du tout" "R" 0
Q=$(q "Je préfère les activités qui demandent de la force physique" 5)
add_r "$Q" "Oui, j aime ça" "R" 5; add_r "$Q" "Parfois" "R" 3; add_r "$Q" "Rarement" "R" 1; add_r "$Q" "Jamais" "R" 0
echo "  OK"

echo "-- Investigateur"
Q=$(q "J aime résoudre des problèmes complexes" 6)
add_r "$Q" "Oui, ça me passionne" "I" 5; add_r "$Q" "Ça m intéresse" "I" 3; add_r "$Q" "Pas vraiment" "I" 1; add_r "$Q" "Non, je n aime pas ça" "I" 0
Q=$(q "Je suis curieux(se) de comprendre comment les choses fonctionnent" 7)
add_r "$Q" "Très curieux(se)" "I" 5; add_r "$Q" "Assez curieux(se)" "I" 3; add_r "$Q" "Peu curieux(se)" "I" 1; add_r "$Q" "Pas curieux(se)" "I" 0
Q=$(q "J aime faire des expériences scientifiques" 8)
add_r "$Q" "J adore ça" "I" 5; add_r "$Q" "Ça m intrigue" "I" 3; add_r "$Q" "Pas vraiment" "I" 1; add_r "$Q" "Non, je déteste" "I" 0
Q=$(q "Je préfère les jeux de réflexion (échecs, puzzles)" 9)
add_r "$Q" "Oui, j en raffole" "I" 5; add_r "$Q" "Parfois" "I" 3; add_r "$Q" "Rarement" "I" 1; add_r "$Q" "Jamais" "I" 0
Q=$(q "J aime lire des articles scientifiques ou des documentaires" 10)
add_r "$Q" "Très souvent" "I" 5; add_r "$Q" "De temps en temps" "I" 3; add_r "$Q" "Rarement" "I" 1; add_r "$Q" "Jamais" "I" 0
echo "  OK"

echo "-- Artistique"
Q=$(q "J aime dessiner, peindre ou créer des choses" 11)
add_r "$Q" "Oui, c est ma passion" "A" 5; add_r "$Q" "J aime bien" "A" 3; add_r "$Q" "Pas vraiment" "A" 1; add_r "$Q" "Non, pas du tout" "A" 0
Q=$(q "Je suis sensible à l art et à la beauté" 12)
add_r "$Q" "Très sensible" "A" 5; add_r "$Q" "Assez sensible" "A" 3; add_r "$Q" "Peu sensible" "A" 1; add_r "$Q" "Pas sensible" "A" 0
Q=$(q "J aime écrire des histoires, des poèmes ou des chansons" 13)
add_r "$Q" "Oui, j adore écrire" "A" 5; add_r "$Q" "Parfois" "A" 3; add_r "$Q" "Rarement" "A" 1; add_r "$Q" "Jamais" "A" 0
Q=$(q "Je préfère les activités créatives aux activités structurées" 14)
add_r "$Q" "Tout à fait" "A" 5; add_r "$Q" "Plutôt" "A" 3; add_r "$Q" "Plutôt pas" "A" 1; add_r "$Q" "Pas du tout" "A" 0
Q=$(q "J aime la musique et jouer d un instrument" 15)
add_r "$Q" "Oui, je suis musicien(ne)" "A" 5; add_r "$Q" "J aime écouter" "A" 3; add_r "$Q" "Pas vraiment" "A" 1; add_r "$Q" "Non" "A" 0
echo "  OK"

echo "-- Social"
Q=$(q "J aime aider les autres" 16)
add_r "$Q" "Oui, c est important pour moi" "S" 5; add_r "$Q" "Assez souvent" "S" 3; add_r "$Q" "Parfois" "S" 1; add_r "$Q" "Pas vraiment" "S" 0
Q=$(q "Je suis à l aise pour parler en public" 17)
add_r "$Q" "Très à l aise" "S" 5; add_r "$Q" "Assez à l aise" "S" 3; add_r "$Q" "Un peu nerveux(se)" "S" 1; add_r "$Q" "Pas du tout à l aise" "S" 0
Q=$(q "J aime travailler en équipe" 18)
add_r "$Q" "J adore le travail d équipe" "S" 5; add_r "$Q" "Ça me va" "S" 3; add_r "$Q" "Je préfère seul(e)" "S" 1; add_r "$Q" "Non, je déteste" "S" 0
Q=$(q "Je suis à l écoute des problèmes des autres" 19)
add_r "$Q" "Toujours" "S" 5; add_r "$Q" "Souvent" "S" 3; add_r "$Q" "Parfois" "S" 1; add_r "$Q" "Rarement" "S" 0
Q=$(q "Je voudrais exercer un métier qui aide les gens" 20)
add_r "$Q" "Oui, c est mon rêve" "S" 5; add_r "$Q" "Ça m intéresserait" "S" 3; add_r "$Q" "Pas forcément" "S" 1; add_r "$Q" "Non, pas du tout" "S" 0
echo "  OK"

echo "-- Entreprenant"
Q=$(q "J aime prendre des initiatives et diriger" 21)
add_r "$Q" "Oui, je suis leader né" "E" 5; add_r "$Q" "Assez souvent" "E" 3; add_r "$Q" "Parfois" "E" 1; add_r "$Q" "Non, je préfère suivre" "E" 0
Q=$(q "Je suis ambitieux(se) et j aime les défis" 22)
add_r "$Q" "Très ambitieux(se)" "E" 5; add_r "$Q" "Assez ambitieux(se)" "E" 3; add_r "$Q" "Peu ambitieux(se)" "E" 1; add_r "$Q" "Pas ambitieux(se)" "E" 0
Q=$(q "J aime convaincre les gens et négocier" 23)
add_r "$Q" "Oui, j excelle dans ce domaine" "E" 5; add_r "$Q" "Assez bien" "E" 3; add_r "$Q" "Pas vraiment" "E" 1; add_r "$Q" "Non, je n aime pas" "E" 0
Q=$(q "Je préfère créer mon entreprise plutôt qu être employé" 24)
add_r "$Q" "Oui, c est mon objectif" "E" 5; add_r "$Q" "Ça me tente" "E" 3; add_r "$Q" "Je préfère être employé" "E" 1; add_r "$Q" "Non, pas du tout" "E" 0
Q=$(q "J aime les compétitions et les challenges" 25)
add_r "$Q" "Oui, j adore" "E" 5; add_r "$Q" "Ça peut être intéressant" "E" 3; add_r "$Q" "Pas vraiment" "E" 1; add_r "$Q" "Non, je déteste" "E" 0
echo "  OK"

echo "-- Conventionnel"
Q=$(q "Je suis organisé(e) et méthodique" 26)
add_r "$Q" "Très organisé(e)" "C" 5; add_r "$Q" "Assez organisé(e)" "C" 3; add_r "$Q" "Un peu désordonné(e)" "C" 1; add_r "$Q" "Pas organisé(e) du tout" "C" 0
Q=$(q "J aime travailler avec des chiffres et des données" 27)
add_r "$Q" "Oui, j adore les chiffres" "C" 5; add_r "$Q" "Ça me va" "C" 3; add_r "$Q" "Pas vraiment" "C" 1; add_r "$Q" "Non, je déteste" "C" 0
Q=$(q "Je suis attentif(ve) aux détails" 28)
add_r "$Q" "Très attentif(ve)" "C" 5; add_r "$Q" "Assez attentif(ve)" "C" 3; add_r "$Q" "Parfois" "C" 1; add_r "$Q" "Pas du tout" "C" 0
Q=$(q "Je préfère les tâches structurées avec des consignes claires" 29)
add_r "$Q" "Oui, j aime la structure" "C" 5; add_r "$Q" "Ça dépend" "C" 3; add_r "$Q" "Je préfère la liberté" "C" 1; add_r "$Q" "Non, je déteste la routine" "C" 0
Q=$(q "J aime classer, ranger et tenir des registres" 30)
add_r "$Q" "Oui, j aime l ordre" "C" 5; add_r "$Q" "Assez" "C" 3; add_r "$Q" "Pas vraiment" "C" 1; add_r "$Q" "Non, pas du tout" "C" 0
echo "  OK"

echo "RIASEC : 30 questions, 120 réponses ✓"

# ─── Quiz 2 : Connais-toi toi-même ─────────────────────────────────
echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║   Quiz Connais-toi toi-même (5 questions)      ║"
echo "╚═══════════════════════════════════════════════╝"

PERSO_ID=$(create_quiz \
  "Connais-toi toi-même" \
  "Quiz de personnalité pour mieux se connaître avant de choisir son orientation")
echo "Personnalité ID: $PERSO_ID"

qp() { add_question "$PERSO_ID" "$1" "$2"; }

Q=$(qp "Je préfère les projets clairs et bien définis" 1)
add_r "$Q" "Toujours" "STRUCTURE" 5; add_r "$Q" "Souvent" "STRUCTURE" 3
add_r "$Q" "Parfois" "ADAPTABILITE" 3; add_r "$Q" "Jamais" "ADAPTABILITE" 5

Q=$(qp "J apprends mieux en faisant qu en écoutant" 2)
add_r "$Q" "Tout à fait" "PRATIQUE" 5; add_r "$Q" "Plutôt" "PRATIQUE" 3
add_r "$Q" "Plutôt pas" "THEORIQUE" 3; add_r "$Q" "Pas du tout" "THEORIQUE" 5

Q=$(qp "Je préfère travailler seul(e) plutôt qu en groupe" 3)
add_r "$Q" "Toujours seul(e)" "AUTONOMIE" 5; add_r "$Q" "Souvent" "AUTONOMIE" 3
add_r "$Q" "En groupe" "COLLABORATION" 3; add_r "$Q" "Toujours en groupe" "COLLABORATION" 5

Q=$(qp "Je suis plus créatif(ve) que logique" 4)
add_r "$Q" "Très créatif(ve)" "CREATIF" 5; add_r "$Q" "Plutôt créatif(ve)" "CREATIF" 3
add_r "$Q" "Plutôt logique" "LOGICIEL" 3; add_r "$Q" "Très logique" "LOGICIEL" 5

Q=$(qp "Je sais gérer le stress et les imprévus" 5)
add_r "$Q" "Très bien" "RESILIENCE" 5; add_r "$Q" "Assez bien" "RESILIENCE" 3
add_r "$Q" "Difficilement" "SENSIBILITE" 3; add_r "$Q" "Pas du tout" "SENSIBILITE" 5

echo "Connais-toi : 5 questions, 20 réponses ✓"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║           Seed terminé !                       ║"
echo "╚═══════════════════════════════════════════════╝"
echo "Quiz RIASEC       : $RIASEC_ID"
echo "Quiz Personnalité : $PERSO_ID"

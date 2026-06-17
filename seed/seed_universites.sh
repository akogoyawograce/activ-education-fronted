#!/bin/bash
# seed_universites.sh — Seed les établissements d'enseignement supérieur du Togo
# Usage: bash seed_universites.sh [email] [password]
API="http://4.233.145.112:8080/api/v1"
EMAIL="${1:-admin@activeducation.tg}"
PASS="${2:-admin123!}"

echo "=== Authentification ==="
TOKEN=$(curl -s -X POST "$API/auth/login" -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"motDePasse\": \"$PASS\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")
AUTH="Authorization: Bearer $TOKEN"
echo "Token obtenu"

post() { curl -s -o /dev/null -X POST "$API/$1" -H "$AUTH" -H "Content-Type: application/json" -d "$2"; }

echo "╔═══════════════════════════════════════════════╗"
echo "║     SEED ÉTABLISSEMENTS SUPÉRIEURS TOGO       ║"
echo "╚═══════════════════════════════════════════════╝"

# ─── RÉCUPÉRATION DES FILIÈRES EXISTANTES ────────────
echo ""
echo "=== Récupération des filières existantes ==="
FILIERES_RAW=$(curl -s -X GET "$API/bibliotheque/filieres" -H "$AUTH" -H "Accept: application/json")
if [ -n "$FILIERES_RAW" ]; then
  eval "$(echo "$FILIERES_RAW" | python3 -c '
import sys, json, unicodedata
try:
    raw = json.loads(sys.stdin.read())
    if isinstance(raw, dict) and "content" in raw:
        items = raw.get("content", [])
    else:
        items = raw if isinstance(raw, list) else []
    for item in items:
        t = item.get("titre", "") or ""
        tid = item.get("trackingId", "") or ""
        if t and tid:
            nfkd = unicodedata.normalize("NFKD", t)
            key = nfkd.encode("ASCII", "ignore").decode().upper()
            key = key.replace(" ", "_").replace("&", "ET").replace("-", "_").replace("'\''", "_").replace(",", "").replace(".", "")
            print("FID_" + key + "=\"" + tid + "\"")
except Exception:
    pass
' 2>/dev/null)"
fi
echo "  Filières chargées ✓"

# Helper : convertit des noms de filières (séparés par |) en JSON array de trackingIds
fids() {
  local first=true
  echo -n '['
  IFS='|' read -ra names <<< "$1"
  for name in "${names[@]}"; do
    name=$(echo "$name" | xargs)
    # NFKD normalization + ASCII + uppercase + clean
    local key=$(echo "$name" | python3 -c "
import sys, unicodedata
s = sys.stdin.read().strip()
nfkd = unicodedata.normalize('NFKD', s)
key = nfkd.encode('ASCII', 'ignore').decode().upper()
key = key.replace(' ', '_').replace('&', 'ET').replace('-', '_').replace(\"'\", '_').replace(',', '').replace('.', '')
print(key)
")
    local var="FID_${key}"
    local tid="${!var}"
    if [ -n "$tid" ]; then
      if [ "$first" = true ]; then first=false; else echo -n ','; fi
      echo -n "\"$tid\""
    fi
  done
  echo -n ']'
}

# Auto-détection des filières à partir d'un texte (titre + offreFormation)
# Retourne une chaîne de noms de filières séparés par |
autodetect_filieres() {
  local text="$1"
  local result=""
  # Mapping keywords -> filières
  if echo "$text" | grep -qi "informati\|developp.*web\|data.*scien\|cyber\|logiciel\|reseau\|telecom"; then result="${result}Informatique|"; fi
  if echo "$text" | grep -qi "math.*appliqu\|statisti\|actuaria\|data.*scien\|analyste.financ"; then result="${result}Mathématiques Appliquées|"; fi
  if echo "$text" | grep -qi "physique\|chimie\|energ.*renouvel"; then result="${result}Physique-Chimie|"; fi
  if echo "$text" | grep -qi "biolog\|biochim\|biotech\|microbiol\|svt\|sciences.*vie\|agronom"; then result="${result}Biologie|"; fi
  if echo "$text" | grep -qi "genie.*civil\|bâtiment\|construction\|pont.*chauss\|topograph\|btp\|travaux.*public"; then result="${result}Génie Civil|"; fi
  if echo "$text" | grep -qi "genie.*electri\|electrotech\|automatism\|energie"; then result="${result}Génie Électrique|"; fi
  if echo "$text" | grep -qi "genie.*mecan\|mecanique.*industri\|maintenance.*industri"; then result="${result}Génie Mécanique|"; fi
  if echo "$text" | grep -qi "genie.*informati\|system.*embarq\|robot\|iot"; then result="${result}Génie Informatique|"; fi
  if echo "$text" | grep -qi "medecin\|chirurg\|sante\|medical\|hopital\|clinique"; then result="${result}Médecine|"; fi
  if echo "$text" | grep -qi "pharmac\|medicament"; then result="${result}Pharmacie|"; fi
  if echo "$text" | grep -qi "dentair\|odontolog\|bucco"; then result="${result}Odontologie|"; fi
  if echo "$text" | grep -qi "infirm\|sage.femm\|soins\|paramedical\|puericulture"; then result="${result}Sciences Infirmières|"; fi
  if echo "$text" | grep -qi "droit\|juridique\|avocat\|magistr\|notaire\|juriste"; then result="${result}Droit|"; fi
  if echo "$text" | grep -qi "sciences.*polit\|relation.*intern\|diplomat\|geopolitique"; then result="${result}Sciences Politiques|"; fi
  if echo "$text" | grep -qi "economi.*general\|macro.*econom\|micro.*econom\|politique.*econom"; then result="${result}Économie|"; fi
  if echo "$text" | grep -qi "gestion.*entrepris\|management\|marketing\|rh\|ressource.*humain\|entrepre"; then result="${result}Gestion des Entreprises|"; fi
  if echo "$text" | grep -qi "financ\|comptabil\|audit\|fiscal\|tresor\|banque\|assuran"; then result="${result}Finance et Comptabilité|"; fi
  if echo "$text" | grep -qi "banque\|assurance\|march.*financ\|conseil.*financ"; then result="${result}Banque et Assurance|"; fi
  if echo "$text" | grep -qi "lettre.*moderne\|litterature\|linguistique\|francais.*langue"; then result="${result}Lettres Modernes|"; fi
  if echo "$text" | grep -qi "anglais\|traduct\|interpret\|langue.*etrangere\|litterature.*anglaise"; then result="${result}Anglais|"; fi
  if echo "$text" | grep -qi "sociolog\|enquete.*social\|developpement.*communaut\|travail.*social"; then result="${result}Sociologie|"; fi
  if echo "$text" | grep -qi "psycholog\|psycho\|conseil.*psycho\|coach"; then result="${result}Psychologie|"; fi
  if echo "$text" | grep -qi "geograph\|amenage.*territoir\|urbanis\|environn"; then result="${result}Géographie|"; fi
  if echo "$text" | grep -qi "histoire.*general\|histoire.*africain\|patrimoin\|archiv"; then result="${result}Histoire|"; fi
  if echo "$text" | grep -qi "agronom\|agricul\|science.*sol\|product.*vegetal\|product.*animal\|agro"; then result="${result}Agronomie|"; fi
  if echo "$text" | grep -qi "forest\|rebois\|bois\|foret\|gestion.*parc"; then result="${result}Sciences Forestières|"; fi
  if echo "$text" | grep -qi "environn\|ecolog\|dechet.*gest\|developpement.*durable\|climat"; then result="${result}Sciences Environnementales|"; fi
  if echo "$text" | grep -qi "science.*educat\|pedagog\|didactic\|psychopedagog\|format.*enseign\|enseign.*prim\|instituteur"; then result="${result}Sciences de l'Éducation|"; fi
  if echo "$text" | grep -qi "enseign.*prim\|instituteur\|maitre.*ecole"; then result="${result}Enseignement Primaire|"; fi
  if echo "$text" | grep -qi "art.*plast\|peintur\|sculpt\|design\|graph\|mode\|stylis\|creat.*artist"; then result="${result}Arts Plastiques|"; fi
  if echo "$text" | grep -qi "communic\|journal\|relation.*publ\|media.*numer\|community.*manager\|publicite\|audiovisu"; then result="${result}Communication et Journalisme|"; fi
  if echo "$text" | grep -qi "touris\|hotel\|hotellerie\|restaur\|evenement\|guide.*tourist"; then result="${result}Tourisme et Hôtellerie|"; fi
  echo "${result%|}"
}

# ─── ÉTABLISSEMENTS PUBLICS ────────────────────────────
echo ""
echo "=== UNIVERSITÉS PUBLIQUES ==="

pub() {
  local titre="$1" resume="$2" adresse="$3" ville="$4" typeEtab="$5" niveau="$6" contacts="$7" siteWeb="$8" offreFormation="$9" filieres="${10}"
  if [ -z "$filieres" ]; then
    filieres=$(autodetect_filieres "$titre $offreFormation")
  fi
  local fids_val=$(fids "$filieres")
  post "bibliotheque/etablissements" \
    "{\"titre\":\"$titre\",\"resume\":\"$resume\",\"contenu\":\"$resume\",\"estPublie\":true,\"adresse\":\"$adresse\",\"ville\":\"$ville\",\"typeEtablissement\":\"$typeEtab\",\"niveau\":\"$niveau\",\"contacts\":\"$contacts\",\"siteWeb\":\"$siteWeb\",\"offreFormation\":\"$offreFormation\",\"estPublic\":true,\"filieresTrackingIds\":$fids_val}"
}

pub \
  "Centre International de Recherche et d'Étude des Langues (CIREL-VB)" \
  "Centre public spécialisé dans l'enseignement et la recherche en langues, situé à Village du Bénin. Rattaché à l'Université de Lomé." \
  "Village du Bénin" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 56 74" \
  "" \
  "Formation en langues et linguistique. Programmes de Licence et Master en Anglais, Allemand, Espagnol, Français Langue Étrangère, Linguistique Appliquée. Recherche en didactique des langues et linguistique africaine." \
  "Anglais|Lettres Modernes|Communication et Journalisme"
pub \
  "Université de Kara (UK)" \
  "Deuxième université publique du Togo, située dans la région de la Kara depuis 2004. Elle dessert tout le nord du pays." \
  "BP 43, Kara" \
  "Kara" \
  "UNIVERSITE" \
  "Licence, Master, Doctorat" \
  "+228 26 60 16 00 / contact@univ-kara.tg" \
  "https://www.univ-kara.tg" \
  "Facultés: Sciences et Techniques, Lettres et Sciences Humaines, Droit et Sciences Politiques, Sciences Économiques et de Gestion. Licence (3 ans), Master (2 ans), Doctorat (3 ans). Filières: Informatique, Mathématiques, Physique-Chimie, Biologie, Lettres Modernes, Anglais, Sociologie, Géographie, Droit, Économie, Gestion." \
  "Informatique|Mathématiques Appliquées|Physique-Chimie|Biologie|Génie Civil|Droit|Sciences Politiques|Économie|Gestion des Entreprises|Finance et Comptabilité|Lettres Modernes|Anglais|Sociologie|Géographie|Histoire|Agronomie|Sciences de l'Éducation"
pub \
  "Université de Lomé (UL)" \
  "Première université publique du Togo, fondée en 1970. Compte plusieurs facultés : Sciences, Lettres, Droit, Économie, Médecine, et écoles doctorales." \
  "BP 1515, Boulevard Eyadema" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master, Doctorat" \
  "+228 22 22 29 61 / contact@univ-lome.tg" \
  "https://www.univ-lome.tg" \
  "Facultés: Sciences, Lettres et Sciences Humaines, Droit, Sciences Économiques et de Gestion, Médecine, Sciences de la Santé. Écoles: École Supérieure d'Agronomie, Institut National des Sciences de l'Éducation. Programmes de Licence (3 ans), Master (2 ans), Doctorat (3 ans). Domaines: Sciences Exactes, Sciences Humaines, Droit, Économie, Santé, Agronomie." \
  "Informatique|Mathématiques Appliquées|Physique-Chimie|Biologie|Génie Civil|Génie Électrique|Génie Mécanique|Génie Informatique|Médecine|Pharmacie|Odontologie|Sciences Infirmières|Droit|Sciences Politiques|Économie|Gestion des Entreprises|Finance et Comptabilité|Banque et Assurance|Lettres Modernes|Anglais|Sociologie|Psychologie|Géographie|Histoire|Agronomie|Sciences Forestières|Sciences Environnementales|Sciences de l'Éducation|Enseignement Primaire|Arts Plastiques|Communication et Journalisme|Tourisme et Hôtellerie"
pub \
  "École Nationale des Auxiliaires Médicaux (ENAM) de Lomé" \
  "École publique de formation des auxiliaires médicaux (infirmiers, sages-femmes, techniciens de santé)." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formation des professionnels de santé: Infirmier Diplômé d'État, Sage-Femme, Technicien de Laboratoire, Technicien de Radiologie." \
  "Sciences Infirmières|Médecine"
pub \
  "École Nationale Supérieure (ENS) d'Atakpamé" \
  "École publique de formation des enseignants du secondaire, située à Atakpamé. Forme des professeurs certifiés pour les lycées et collèges." \
  "BP 10, Atakpamé" \
  "Atakpamé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "+228 27 70 01 32" \
  "" \
  "Formation des enseignants du secondaire. Filières: Mathématiques, Physique-Chimie, SVT, Lettres Modernes, Anglais, Histoire-Géographie. Licence d'Enseignement (3 ans), Master Enseignement (2 ans)." \
  "Mathématiques Appliquées|Physique-Chimie|Biologie|Lettres Modernes|Anglais|Géographie|Histoire|Sciences de l'Éducation|Enseignement Primaire"

pub \
  "Université de Kara (UK)" \
  "Deuxième université publique du Togo, située dans la région de la Kara depuis 2004. Elle dessert tout le nord du pays." \
  "BP 43, Kara" \
  "Kara" \
  "UNIVERSITE" \
  "Licence, Master, Doctorat" \
  "+228 26 60 16 00 / contact@univ-kara.tg" \
  "https://www.univ-kara.tg" \
  "Facultés: Sciences et Techniques, Lettres et Sciences Humaines, Droit et Sciences Politiques, Sciences Économiques et de Gestion. Licence (3 ans), Master (2 ans), Doctorat (3 ans). Filières: Informatique, Mathématiques, Physique-Chimie, Biologie, Lettres Modernes, Anglais, Sociologie, Géographie, Droit, Économie, Gestion." \
  "Informatique|Mathématiques Appliquées|Physique-Chimie|Biologie|Génie Civil|Droit|Sciences Politiques|Économie|Gestion des Entreprises|Finance et Comptabilité|Lettres Modernes|Anglais|Sociologie|Géographie|Histoire|Agronomie|Sciences de l'Éducation"

pub \
  "École Nationale Supérieure (ENS) d'Atakpamé" \
  "École publique de formation des enseignants du secondaire, située à Atakpamé. Forme des professeurs certifiés pour les lycées et collèges." \
  "BP 10, Atakpamé" \
  "Atakpamé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "+228 27 70 01 32" \
  "" \
  "Formation des enseignants du secondaire. Filières: Mathématiques, Physique-Chimie, SVT, Lettres Modernes, Anglais, Histoire-Géographie. Licence d'Enseignement (3 ans), Master Enseignement (2 ans)." \
  "Mathématiques Appliquées|Physique-Chimie|Biologie|Lettres Modernes|Anglais|Géographie|Histoire|Sciences de l'Éducation|Enseignement Primaire"

pub \
  "Centre International de Recherche et d'Étude des Langues (CIREL-VB)" \
  "Centre public spécialisé dans l'enseignement et la recherche en langues, situé à Village du Bénin. Rattaché à l'Université de Lomé." \
  "Village du Bénin" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 56 74" \
  "" \
  "Formation en langues et linguistique. Programmes de Licence et Master en Anglais, Allemand, Espagnol, Français Langue Étrangère, Linguistique Appliquée. Recherche en didactique des langues et linguistique africaine." \
  "Anglais|Lettres Modernes|Communication et Journalisme"

pub \
  "École Nationale des Auxiliaires Médicaux (ENAM) de Lomé" \
  "École publique de formation des auxiliaires médicaux (infirmiers, sages-femmes, techniciens de santé)." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formation des professionnels de santé: Infirmier Diplômé d'État, Sage-Femme, Technicien de Laboratoire, Technicien de Radiologie." \
  "Sciences Infirmières|Médecine"

echo "  Universités publiques ✓"

# ─── ÉTABLISSEMENTS PRIVÉS ────────────────────────────
echo ""
echo "=== UNIVERSITÉS ET GRANDES ÉCOLES PRIVÉES ==="

priv() {
  local titre="$1" resume="$2" adresse="$3" ville="$4" typeEtab="$5" niveau="$6" contacts="$7" siteWeb="$8" offreFormation="$9" filieres="${10}"
  if [ -z "$filieres" ]; then
    filieres=$(autodetect_filieres "$titre $offreFormation")
  fi
  local fids_val=$(fids "$filieres")
  post "bibliotheque/etablissements" \
    "{\"titre\":\"$titre\",\"resume\":\"$resume\",\"contenu\":\"$resume\",\"estPublie\":true,\"adresse\":\"$adresse\",\"ville\":\"$ville\",\"typeEtablissement\":\"$typeEtab\",\"niveau\":\"$niveau\",\"contacts\":\"$contacts\",\"siteWeb\":\"$siteWeb\",\"offreFormation\":\"$offreFormation\",\"estPublic\":false,\"filieresTrackingIds\":$fids_val}"
}

priv \
  "American Institute of Commonwealth (AIC-Togo)" \
  "Institut privé proposant des formations aux standards internationaux, programmes bilingues." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Programmes bilingues en Management, Informatique, Finance, Relations Internationales."
priv \
  "CEFIP" \
  "Centre privé de formation et d'insertion professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Métiers du Tertiaire, Services, Commerce."
priv \
  "Centre de Formation Bancaire du Togo (CFBT)" \
  "Centre privé spécialisé dans la formation aux métiers de la banque et de la finance." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Banque, Finance, Assurance, Microfinance. Programmes certifiants." \
  "Banque et Assurance|Finance et Comptabilité|Économie"
priv \
  "Centre de Formation Supérieure SartenMode (CFS-SartenMode)" \
  "Centre privé de formation supérieure en mode et couture." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Stylisme, Couture, Mode, Design de Mode."
priv \
  "Centre de Perfectionnement aux Techniques Économiques et Commerciales (CPTEC)" \
  "Centre privé de perfectionnement en techniques économiques et commerciales." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Techniques Commerciales, Gestion, Comptabilité, Marketing."
priv \
  "Centre Informatique de Formation et d'Orientation Professionnelle (CIFOP)" \
  "Centre privé de formation en informatique et orientation professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Orientation Professionnelle."
priv \
  "Centre Omnithérapeutique Africain (COA)" \
  "Centre privé de formation en médecine et thérapies." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Médecine Traditionnelle, Phytothérapie, Bien-être, Santé Naturelle."
priv \
  "CIB-INTA" \
  "Centre privé de formation en informatique, bureautique et nouvelles technologies." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Maintenance, Réseaux, Développement Web."
priv \
  "DEFITECH Togo" \
  "Institut privé de formation en technologies et innovation." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Développement Web et Mobile, Design Digital, Marketing Digital, Infographie."
priv \
  "Ecole Supérieure de l'Aéronautique et des Technologies Togo (ESAT-TOGO)" \
  "École privée spécialisée dans les métiers de l'aéronautique et des hautes technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Aéronautique, Maintenance Aéronautique, Logistique Aérienne, Technologies Avancées."
priv \
  "ESAM" \
  "École supérieure privée des affaires et de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Marketing, Finance, Comptabilité, Ressources Humaines."
priv \
  "ESFP-FIMAC" \
  "École supérieure privée de formation professionnelle FIMAC." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations professionnelles en Comptabilité, Gestion, Marketing."
priv \
  "ESTECA" \
  "École supérieure privée de technologie et de commerce." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Commerce, Gestion, Informatique de Gestion, Marketing."
priv \
  "Faculté de Théologie des Assemblées de Dieu (FATAD)" \
  "Faculté privée de théologie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Théologie, Sciences Bibliques, Pastorale, Éducation Chrétienne."
priv \
  "FORMATEC" \
  "Centre privé de formation technique." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations techniques en Informatique, Électronique, Maintenance."
priv \
  "Global University School of Science and Technology (GUST)" \
  "Université privée spécialisée en sciences, technologies et innovation." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences et Technologies: Informatique, Intelligence Artificielle, Data Science, Biotechnologies, Sciences de l'Ingénieur." \
  "Informatique|Mathématiques Appliquées|Génie Informatique|Physique-Chimie|Biologie"
priv \
  "Groupe IHERIS" \
  "Groupe d'enseignement supérieur privé proposant des formations en management, technologies et sciences." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Licences et Masters en Management, Informatique, Finance, Marketing, Communication, Ressources Humaines, Hôtellerie et Tourisme." \
  "Informatique|Gestion des Entreprises|Finance et Comptabilité|Communication et Journalisme|Tourisme et Hôtellerie"
priv \
  "Haute Technologie d'Informatique et Bureautique Atlantis (HTIB-ATLANTIS)" \
  "Institut privé de hautes technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Technologies de l'Information."
priv \
  "Haute École de Technologies et de Management des Lacs (HETML)" \
  "Haute école privée de technologies et management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Technologies, Management, Informatique, Gestion."
priv \
  "Heritage International University Institute (HIUI)" \
  "Institut universitaire privé international." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes internationaux en Management, Finance, Informatique, Commerce."
priv \
  "Hôtel École Avenida" \
  "École hôtelière privée." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Hôtellerie, Restauration, Tourisme, Arts Culinaires."
priv \
  "Hôtel École Concordia" \
  "École hôtelière privée formant aux métiers de l'hôtellerie, de la restauration et du tourisme." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Hôtellerie, Restauration, Cuisine, Services Hôteliers, Tourisme."
priv \
  "Hôtel École La Savoureuse (HES)" \
  "École hôtelière privée." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Hôtellerie, Restauration, Cuisine, Pâtisserie, Services Hôteliers."
priv \
  "Institut Africain d'Administration et d'Études Commerciales (IAEC)" \
  "Institut privé spécialisé en administration des affaires et études commerciales." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 00 00" \
  "" \
  "Formations en Administration des Affaires, Commerce International, Marketing, Gestion des Ressources Humaines, Finance, Comptabilité. Licence (3 ans), Master (2 ans)." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie|Banque et Assurance"
priv \
  "Institut Africain de Développement Sanitaire et Social (IADSS)" \
  "Institut privé de formation dans les domaines sanitaire et social." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Santé Publique, Développement Social, Assistance Sociale, Gestion Sanitaire."
priv \
  "Institut Africain des Sciences, des Technologies et des Métiers (IASTM)" \
  "Institut privé de sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Métiers Techniques, Informatique."
priv \
  "Institut Africain Le Leadership" \
  "Institut privé de formation en leadership." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Leadership, Management, Développement Personnel, Communication."
priv \
  "Institut Consortium Saint John Révélation" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Théologie, Management, Développement Personnel."
priv \
  "Institut d'Ingénierie Hôtelière et du Tourisme (IIHT)" \
  "Institut privé d'hôtellerie et tourisme." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Hôtellerie, Tourisme, Restauration, Gestion Hôtelière."
priv \
  "Institut de Formation aux Métiers de la Sécurité Sociale (IFOMESS-Kara)" \
  "Institut privé de formation aux métiers de la sécurité sociale, situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sécurité Sociale, Protection Sociale, Gestion des Organismes Sociaux."
priv \
  "Institut de Formation aux Normes et Technologies de l'Informatique (IFNTI-Sokodé)" \
  "Institut privé de formation en informatique situé à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Réseaux, Développement, Maintenance."
priv \
  "Institut de Formation en Actuariat et Finance (IFA)" \
  "Institut privé de formation en actuariat et finance." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Actuariat, Finance Quantitative, Statistique, Gestion des Risques."
priv \
  "Institut de Formation en Gestion (IFG)" \
  "Institut privé de formation en gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Management, Ressources Humaines, Finance."
priv \
  "Institut de Formation et de Recherche pour le Développement Durable (IFORDD)" \
  "Institut privé de recherche et formation en développement durable." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Développement Durable, Environnement, Écologie, Gestion des Ressources."
priv \
  "Institut de Formation Technique et Supérieure (IFTS)" \
  "Institut privé de formation technique et professionnelle." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations techniques en Informatique, Gestion, Comptabilité, Secrétariat."
priv \
  "Institut de Génie Biomédical de Lomé (IGEB)" \
  "Institut privé spécialisé en génie biomédical." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Génie Biomédical, Maintenance Hospitalière, Équipements Médicaux."
priv \
  "Institut de Recherche en Sciences de la Santé (ISOR-TOGO)" \
  "Institut privé de recherche et formation en santé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences de la Santé, Soins Infirmiers, Paramédical."
priv \
  "Institut de Recherche et de Formation en Développement Local (IRFODEL)" \
  "Institut privé de recherche et formation en développement local." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Développement Local, Décentralisation, Gouvernance Locale, Projets."
priv \
  "Institut de Technologie IPNET IT" \
  "Institut privé de technologies de l'information." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Réseaux, Sécurité Informatique, Développement, Administration Système."
priv \
  "Institut des Arts et Technologies de l'Image (IATI)" \
  "Institut privé d'arts et technologies de l'image." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Arts Visuels, Photographie, Vidéo, Design Graphique, Multimédia."
priv \
  "Institut des Hautes Études de Relations Internationales et Stratégiques (IHERIS)" \
  "Institut privé de relations internationales et stratégie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Relations Internationales, Stratégie, Diplomatie, Sécurité Internationale, Géopolitique."
priv \
  "Institut des Sciences Technologies et Arts (ISTA-Kara)" \
  "Institut privé de sciences, technologies et arts situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Arts, Design."
priv \
  "Institut des Technologies Avancées (JUMAU-ITA)" \
  "Institut privé de technologies avancées." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologies Avancées, Informatique, Robotique, Intelligence Artificielle."
priv \
  "Institut ELATSA" \
  "Institut privé de formation supérieure." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Lettres, Langues, Traduction, Communication."
priv \
  "Institut IAI-TOGO" \
  "Institut privé d'intelligence artificielle et d'informatique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Intelligence Artificielle, Data Science, Développement."
priv \
  "Institut Polytechnique des Bâtiments et des Travaux Publics (IPBTP)" \
  "Institut privé de formation aux métiers du BTP." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Bâtiment, Travaux Publics, Topographie, Génie Civil, Architecture."
priv \
  "Institut Régional d'Enseignement Supérieur et de Recherche en Développement Culturel" \
  "Institut privé dédié à la recherche et l'enseignement en développement culturel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Développement Culturel, Gestion du Patrimoine, Industries Culturelles, Tourisme Culturel."
priv \
  "Institut Supérieur Agata Carelli (ISAC)" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Paramédical, Puériculture, Soins Infirmiers."
priv \
  "Institut Supérieur d'Administration, des Sciences Économiques et de Gestion (ISAGES)" \
  "Institut supérieur privé d'administration et économie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Administration, Sciences Économiques, Gestion des Entreprises."
priv \
  "Institut Supérieur d'Études Générales (SUP IEG)" \
  "Institut supérieur privé d'études générales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Lettres, Droit, Économie."
priv \
  "Institut Supérieur de Bâtiment Ayin'a (ISBA)" \
  "Institut privé de formation aux métiers du bâtiment." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Bâtiment, Construction, Architecture, Génie Civil."
priv \
  "Institut Supérieur de Droit et d'Interprétariat (ISDI)" \
  "Institut privé spécialisé dans les formations juridiques et l'interprétariat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Droit, Sciences Juridiques, Interprétariat, Traduction, Relations Internationales."
priv \
  "Institut Supérieur de Management Adonaï (ISM Adonaï)" \
  "Institut privé de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Comptabilité, Marketing, Ressources Humaines."
priv \
  "Institut Supérieur de Management et de Développement (ISMAD)" \
  "Institut privé de management et développement." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Développement Durable, Projets, Gouvernance."
priv \
  "Institut Supérieur de Management et de l'Entrepreneuriat (ISME)" \
  "Institut privé de formation en management et entrepreneuriat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "+228 90 01 11 11" \
  "" \
  "Formations en Management, Entrepreneuriat, Marketing, Finance." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie"
priv \
  "Institut Supérieur de Management Mgr Bakpessi (Kara)" \
  "Institut supérieur privé situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion, Comptabilité."
priv \
  "Institut Supérieur de Philosophie et des Sciences Humaines Don Bosco (ISDB)" \
  "Institut privé confessionnel formant en philosophie et sciences humaines." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Philosophie, Sciences Humaines, Théologie, Éducation, Psychologie."
priv \
  "Institut Supérieur des Langues et des Affaires (ISLA)" \
  "Institut privé de formation en langues et commerce international." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Langues Étrangères Appliquées, Commerce International, Traduction, Relations Internationales."
priv \
  "Institut Supérieur des Sciences Psychologiques et de l'Humain (ISPSH)" \
  "Institut supérieur privé de psychologie et sciences humaines." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Psychologie, Sociologie, Sciences de l'Éducation, Travail Social."
priv \
  "Institut Supérieur des Sciences Économiques et Commerciales (ISSEC-KOUVAHEY)" \
  "Institut supérieur privé de sciences économiques et commerciales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences Économiques, Commerce, Marketing, Finance."
priv \
  "Institut Supérieur des Technologies et de Management (ISTM)" \
  "Institut supérieur privé de technologies et management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologies, Management, Informatique, Réseaux."
priv \
  "Institut Supérieur La Maîtrise" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Comptabilité, Marketing, Secrétariat."
priv \
  "Institut Supérieur Le Technocrate" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Techniques Commerciales, Informatique."
priv \
  "Institut Supérieur Privé de Management (UPM-TOGO)" \
  "Institut privé de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion, Marketing, Finance."
priv \
  "Institut supérieur Privé de Management du Togo (IPM-Togo)" \
  "Institut privé de management et de gestion des entreprises." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion des Entreprises, Marketing, Ressources Humaines, Finance."
priv \
  "Institut Technique Bonita Haus" \
  "Institut privé de formation technique et professionnelle." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations techniques: Hôtellerie, Tourisme, Restauration, Arts Culinaires."
priv \
  "Institut Universitaire Global Wealth" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes en Finance, Management, Entrepreneuriat, Commerce International."
priv \
  "Institut Universitaire Lucas University College" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes universitaires en Gestion, Informatique, Droit, Communication."
priv \
  "Institut Universitaire Nobel (IUN)" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Gestion, Informatique, Marketing, Communication."
priv \
  "Institut Upsilon Collège de Paris Supérieur" \
  "Institut supérieur privé, antenne du Collège de Paris." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Management, Marketing, Finance, Ressources Humaines."
priv \
  "Institute of Strategy and Leadership (ISL)" \
  "Institut privé dédié au leadership, à la stratégie et au management. Fondé par le Groupe DWDG." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Master" \
  "" \
  "https://isl.education" \
  "Masters en Stratégie d'Entreprise, Intelligence Artificielle, Management, Leadership. Formation hybride (en ligne et présentiel). Stages et projets consulting." \
  "Gestion des Entreprises|Informatique|Génie Informatique"
priv \
  "International School of Technology and Business (ISTB)" \
  "École internationale privée alliant technologie et commerce. Programmes bilingues français/anglais." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes bilingues en Technologies de l'Information, Business Management, Finance Internationale, Marketing Digital." \
  "Informatique|Gestion des Entreprises|Finance et Comptabilité|Anglais"
priv \
  "ISC College (CIBC)" \
  "College privé de formation supérieure." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Commerce, Informatique."
priv \
  "Knowbridge University Institute (Sokodé)" \
  "Institut universitaire privé situé à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "UNIVERSITE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Informatique, Commerce, Entrepreneuriat."
priv \
  "Lomé Business School (LBS)" \
  "Business school privée offrant des formations en management, commerce et entrepreneuriat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes en Management, Commerce International, Entrepreneuriat, Marketing Digital, Finance."
priv \
  "Social and Inclusive Business Institute of Togo (SIBI-Togo)" \
  "Institut privé de business social et inclusif." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Entrepreneuriat Social, Business Inclusif, Développement Durable."
priv \
  "Univers du Leadership International de XOESE (Univers XOESE)" \
  "Institut privé de leadership et de développement personnel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Leadership, Développement Personnel, Management, Communication."
priv \
  "Université Catholique de l'Afrique de l'Ouest - Unité Universitaire du Togo (UCAO-UUT)" \
  "Université privée catholique membre du réseau UCAO. Formations en sciences sociales, juridiques et économiques." \
  "BP 20258, Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "+228 22 21 46 65 / info@ucao-uut.tg" \
  "https://www.ucao-uut.tg" \
  "Facultés: Droit, Sciences Économiques et de Gestion, Sciences Sociales, Lettres et Sciences Humaines. Licence (3 ans), Master (2 ans). Filières: Droit des Affaires, Économie, Gestion des Entreprises, Sociologie, Psychologie, Communication, Sciences Politiques." \
  "Droit|Sciences Politiques|Économie|Gestion des Entreprises|Finance et Comptabilité|Sociologie|Psychologie|Lettres Modernes|Anglais|Communication et Journalisme"
priv \
  "Université des Sciences et Technologies du Togo (UST-TG)" \
  "Université privée des sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences et Technologies, Informatique, Ingénierie."
priv \
  "Université UBLT" \
  "Université privée au Togo." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Gestion, Droit."
priv \
  "École Africaine des Métiers de l'Architecture et de l'Urbanisme (EAMAU)" \
  "École inter-africaine spécialisée dans les métiers de l'architecture, de l'urbanisme et du développement territorial." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Architecture, Urbanisme, Aménagement du Territoire, Développement Durable."
priv \
  "École de Finance" \
  "École privée spécialisée dans les métiers de la finance." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Finance, Banque, Assurance, Comptabilité, Gestion Financière."
priv \
  "École des Cadres" \
  "École privée de formation des cadres d'entreprise." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Administration, Gestion des Entreprises."
priv \
  "École des Hautes Études de Commerce et de Gestion (HECOGU)" \
  "École privée de commerce et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Commerce, Gestion, Marketing, Finance, Audit."
priv \
  "École des Hautes Études de Sciences et Technologies (HEST)" \
  "École privée de sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences et Technologies, Informatique, Mathématiques, Physique."
priv \
  "École des Micro-Entrepreneurs du Centre (EMC-Sokodé)" \
  "École privée d'entrepreneuriat située à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Entrepreneuriat, Microfinance, Gestion de Projets, Développement Local."
priv \
  "École Maritime du Togo (EMARITO)" \
  "École privée spécialisée dans les métiers de la mer et du transport maritime." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Navigation Maritime, Logistique Portuaire, Transport International, Gestion Maritime."
priv \
  "École Nationale d'Administration (ENA) - Togo" \
  "École privée formant aux métiers de l'administration publique et privée." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Administration Publique, Gestion des Collectivités, RH, Finances Publiques."
priv \
  "École Supérieure d'Administration et de Gestion (ESCA)" \
  "École privée d'administration et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Administration, Gestion, Comptabilité, Marketing."
priv \
  "École Supérieure d'Administration et de Gestion Notre Dame de l'Église (ESAG-NDE)" \
  "École privée confessionnelle d'administration et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Administration, Gestion, Comptabilité, Informatique de Gestion."
priv \
  "École Supérieure d'Architecture et de Topographie (ESTABAT)" \
  "École privée formant dans les domaines de l'architecture, de la topographie et du bâtiment." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Architecture, Topographie, Génie Civil, Urbanisme, Design d'intérieur."
priv \
  "École Supérieure d'Audit et de Management (ESAM)" \
  "École privée d'audit et de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Audit, Management, Finance, Comptabilité, Contrôle de Gestion."
priv \
  "École Supérieure d'Esthétique Appliquée Pharm-A-Peau (ESEA-Q'LS)" \
  "École privée d'esthétique et de soins." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Esthétique, Cosmétologie, Soins de la Peau, Bien-être."
priv \
  "École Supérieure d'Informatique et de Gestion (ESIG GLOBAL SUCCESS)" \
  "École privée spécialisée en informatique et gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique de Gestion, Développement Web, Comptabilité, Marketing Digital."
priv \
  "École Supérieure d'Informatique, de Business et d'Administration (ESIBA)" \
  "École privée d'informatique, business et administration." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique de Gestion, Business Administration, Marketing."
priv \
  "École Supérieure d'Ingénieurs d'Aného (ESIA)" \
  "École privée d'ingénieurs située à Aného, spécialisée dans les formations techniques et scientifiques." \
  "Aného" \
  "Aného" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations d'ingénieurs et techniciens supérieurs. Filières: Génie Civil, Génie Électrique, Génie Informatique, Énergies Renouvelables." \
  "Génie Civil|Génie Électrique|Génie Informatique|Génie Mécanique|Physique-Chimie"
priv \
  "École Supérieure de Commerce et de l'Économie Numérique (ESCEN)" \
  "École privée de commerce axée sur l'économie numérique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Commerce, Économie Numérique, Marketing Digital, E-commerce, Gestion."
priv \
  "École Supérieure de Communication et de Gestion (ESCG-Tsévié)" \
  "École privée de communication et gestion située à Tsévié." \
  "Tsévié" \
  "Tsévié" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Communication, Gestion des Entreprises, Marketing, Comptabilité."
priv \
  "École Supérieure de Formation Professionnelle (CFP ANCILA)" \
  "Centre privé de formation professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Métiers Techniques, Services, Artisanat."
priv \
  "École Supérieure de Gestion et d'Informatique (ESGIS)" \
  "Grande école privée spécialisée en gestion, informatique et technologies. L'un des plus grands établissements privés du Togo." \
  "BP 80665, Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 60 60 / info@esgis.tg" \
  "https://www.esgis.tg" \
  "Écoles: ESGIS Management, ESGIS Informatique, ESGIS Communication. Programmes: Licence (3 ans), Master (2 ans), MBA. Filières: Informatique de Gestion, Génie Logiciel, Réseaux et Télécommunications, Marketing, Finance, Comptabilité, Audiovisuel, Design Graphique." \
  "Informatique|Génie Informatique|Gestion des Entreprises|Finance et Comptabilité|Marketing Digital|Communication et Journalisme|Arts Plastiques"
priv \
  "École Supérieure de Management (ESMA)" \
  "École privée de management et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Ressources Humaines, Marketing, Finance, Entrepreneuriat."
priv \
  "École Supérieure de Relations Internationales et de Diplomatie (ESRID)" \
  "École privée de relations internationales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Relations Internationales, Diplomatie, Géopolitique, Droit International."
priv \
  "École Supérieure de Technologie et de Gestion (ESTEG)" \
  "École privée de technologie et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologie, Gestion, Informatique, Commerce."
priv \
  "École Supérieure des Affaires (ESA)" \
  "Grande école privée de commerce et de gestion. Propose des programmes en management, finance et entrepreneuriat." \
  "BP 81170, Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 35 00 / contact@esa.tg" \
  "https://www.esa.tg" \
  "Programmes: Licence en Commerce et Gestion (3 ans), Master en Management des Entreprises (2 ans), MBA. Filières: Marketing, Finance d'Entreprise, Ressources Humaines, Logistique, Commerce International, Entrepreneuriat." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie|Banque et Assurance|Communication et Journalisme"
priv \
  "École Supérieure des Arts de la Mode et des Arts Plastiques (ESAMOD)" \
  "École privée spécialisée dans les métiers de la mode, du design et des arts plastiques." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Stylisme, Création de Mode, Design Textile, Arts Plastiques, Design Graphique." \
  "Arts Plastiques"
priv \
  "École Supérieure des Arts et Sciences du Numérique (ESASN)" \
  "École privée spécialisée dans les arts et sciences du numérique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Arts Numériques, Design Digital, Animation 3D, Développement Web, Multimédia."
priv \
  "École Supérieure des Ponts et Chaussées (ESPC)" \
  "École privée spécialisée en génie civil, topographie et travaux publics." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Génie Civil, Ponts et Chaussées, Topographie, Bâtiment et Travaux Publics."
priv \
  "École Supérieure des Techniques et Arts de la Communication (ESTAC)" \
  "École privée de communication et de techniques médiatiques." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Communication, Journalisme, Marketing Digital, Relations Publiques, Publicité."
priv \
  "École Supérieure des Études Cinématographiques (ESEC)" \
  "École privée de cinéma et d'audiovisuel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Réalisation Cinématographique, Production Audiovisuelle, Montage, Scénarisation."
priv \
  "École Supérieure du Tourisme et d'Hôtellerie Stella Matutina (ESTH-SM)" \
  "École privée de tourisme et d'hôtellerie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Tourisme, Hôtellerie, Gestion Hôtelière, Restauration, Événementiel."
priv \
  "École Supérieure Le Miel de Kpové-Zion" \
  "École privée de formation supérieure." \
  "Kpové" \
  "Kpové" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Agriculture, Développement Rural, Entrepreneuriat."
priv \
  "École Supérieure Multinationale des Télécommunications (ESMT) - Antenne Togo" \
  "École supérieure multinationale spécialisée dans les télécommunications (antenne togolaise)." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 00 00" \
  "https://www.esmt.sn" \
  "Formations en Télécommunications, Réseaux Informatiques, Cybersécurité, Technologies Mobiles. Licence (3 ans), Master (2 ans)." \
  "Informatique|Génie Informatique|Génie Électrique|Physique-Chimie"

priv \
  "École Supérieure de Gestion et d'Informatique (ESGIS)" \
  "Grande école privée spécialisée en gestion, informatique et technologies. L'un des plus grands établissements privés du Togo." \
  "BP 80665, Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 60 60 / info@esgis.tg" \
  "https://www.esgis.tg" \
  "Écoles: ESGIS Management, ESGIS Informatique, ESGIS Communication. Programmes: Licence (3 ans), Master (2 ans), MBA. Filières: Informatique de Gestion, Génie Logiciel, Réseaux et Télécommunications, Marketing, Finance, Comptabilité, Audiovisuel, Design Graphique." \
  "Informatique|Génie Informatique|Gestion des Entreprises|Finance et Comptabilité|Marketing Digital|Communication et Journalisme|Arts Plastiques"

priv \
  "École Supérieure des Affaires (ESA)" \
  "Grande école privée de commerce et de gestion. Propose des programmes en management, finance et entrepreneuriat." \
  "BP 81170, Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 35 00 / contact@esa.tg" \
  "https://www.esa.tg" \
  "Programmes: Licence en Commerce et Gestion (3 ans), Master en Management des Entreprises (2 ans), MBA. Filières: Marketing, Finance d'Entreprise, Ressources Humaines, Logistique, Commerce International, Entrepreneuriat." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie|Banque et Assurance|Communication et Journalisme"

priv \
  "Institut Africain d'Administration et d'Études Commerciales (IAEC)" \
  "Institut privé spécialisé en administration des affaires et études commerciales." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 00 00" \
  "" \
  "Formations en Administration des Affaires, Commerce International, Marketing, Gestion des Ressources Humaines, Finance, Comptabilité. Licence (3 ans), Master (2 ans)." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie|Banque et Assurance"

priv \
  "École Supérieure Multinationale des Télécommunications (ESMT) - Antenne Togo" \
  "École supérieure multinationale spécialisée dans les télécommunications (antenne togolaise)." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "+228 22 21 00 00" \
  "https://www.esmt.sn" \
  "Formations en Télécommunications, Réseaux Informatiques, Cybersécurité, Technologies Mobiles. Licence (3 ans), Master (2 ans)." \
  "Informatique|Génie Informatique|Génie Électrique|Physique-Chimie"

priv \
  "École Supérieure d'Ingénieurs d'Aného (ESIA)" \
  "École privée d'ingénieurs située à Aného, spécialisée dans les formations techniques et scientifiques." \
  "Aného" \
  "Aného" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations d'ingénieurs et techniciens supérieurs. Filières: Génie Civil, Génie Électrique, Génie Informatique, Énergies Renouvelables." \
  "Génie Civil|Génie Électrique|Génie Informatique|Génie Mécanique|Physique-Chimie"

priv \
  "Global University School of Science and Technology (GUST)" \
  "Université privée spécialisée en sciences, technologies et innovation." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences et Technologies: Informatique, Intelligence Artificielle, Data Science, Biotechnologies, Sciences de l'Ingénieur." \
  "Informatique|Mathématiques Appliquées|Génie Informatique|Physique-Chimie|Biologie"

priv \
  "International School of Technology and Business (ISTB)" \
  "École internationale privée alliant technologie et commerce. Programmes bilingues français/anglais." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes bilingues en Technologies de l'Information, Business Management, Finance Internationale, Marketing Digital." \
  "Informatique|Gestion des Entreprises|Finance et Comptabilité|Anglais"

priv \
  "Groupe IHERIS" \
  "Groupe d'enseignement supérieur privé proposant des formations en management, technologies et sciences." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Licences et Masters en Management, Informatique, Finance, Marketing, Communication, Ressources Humaines, Hôtellerie et Tourisme." \
  "Informatique|Gestion des Entreprises|Finance et Comptabilité|Communication et Journalisme|Tourisme et Hôtellerie"

priv \
  "Institute of Strategy and Leadership (ISL)" \
  "Institut privé dédié au leadership, à la stratégie et au management. Fondé par le Groupe DWDG." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Master" \
  "" \
  "https://isl.education" \
  "Masters en Stratégie d'Entreprise, Intelligence Artificielle, Management, Leadership. Formation hybride (en ligne et présentiel). Stages et projets consulting." \
  "Gestion des Entreprises|Informatique|Génie Informatique"

priv \
  "École Supérieure des Arts de la Mode et des Arts Plastiques (ESAMOD)" \
  "École privée spécialisée dans les métiers de la mode, du design et des arts plastiques." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Stylisme, Création de Mode, Design Textile, Arts Plastiques, Design Graphique." \
  "Arts Plastiques"

priv \
  "Centre de Formation Bancaire du Togo (CFBT)" \
  "Centre privé spécialisé dans la formation aux métiers de la banque et de la finance." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Banque, Finance, Assurance, Microfinance. Programmes certifiants." \
  "Banque et Assurance|Finance et Comptabilité|Économie"

priv \
  "Institut Supérieur de Management et de l'Entrepreneuriat (ISME)" \
  "Institut privé de formation en management et entrepreneuriat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "+228 90 01 11 11" \
  "" \
  "Formations en Management, Entrepreneuriat, Marketing, Finance." \
  "Gestion des Entreprises|Finance et Comptabilité|Économie"

priv \
  "École Supérieure des Ponts et Chaussées (ESPC)" \
  "École privée spécialisée en génie civil, topographie et travaux publics." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Génie Civil, Ponts et Chaussées, Topographie, Bâtiment et Travaux Publics."

priv \
  "École Supérieure d'Architecture et de Topographie (ESTABAT)" \
  "École privée formant dans les domaines de l'architecture, de la topographie et du bâtiment." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Architecture, Topographie, Génie Civil, Urbanisme, Design d'intérieur."

priv \
  "École Africaine des Métiers de l'Architecture et de l'Urbanisme (EAMAU)" \
  "École inter-africaine spécialisée dans les métiers de l'architecture, de l'urbanisme et du développement territorial." \
  "Lomé" \
  "Lomé" \
  "GRANDE_ECOLE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Architecture, Urbanisme, Aménagement du Territoire, Développement Durable."

priv \
  "Lomé Business School (LBS)" \
  "Business school privée offrant des formations en management, commerce et entrepreneuriat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes en Management, Commerce International, Entrepreneuriat, Marketing Digital, Finance."

priv \
  "Institut Supérieur de Droit et d'Interprétariat (ISDI)" \
  "Institut privé spécialisé dans les formations juridiques et l'interprétariat." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Droit, Sciences Juridiques, Interprétariat, Traduction, Relations Internationales."

priv \
  "Institut de Formation Technique et Supérieure (IFTS)" \
  "Institut privé de formation technique et professionnelle." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations techniques en Informatique, Gestion, Comptabilité, Secrétariat."

priv \
  "Institut supérieur Privé de Management du Togo (IPM-Togo)" \
  "Institut privé de management et de gestion des entreprises." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion des Entreprises, Marketing, Ressources Humaines, Finance."

priv \
  "Institut Supérieur de Philosophie et des Sciences Humaines Don Bosco (ISDB)" \
  "Institut privé confessionnel formant en philosophie et sciences humaines." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Philosophie, Sciences Humaines, Théologie, Éducation, Psychologie."

priv \
  "École Supérieure d'Administration et de Gestion Notre Dame de l'Église (ESAG-NDE)" \
  "École privée confessionnelle d'administration et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Administration, Gestion, Comptabilité, Informatique de Gestion."

priv \
  "Ecole Supérieure de l'Aéronautique et des Technologies Togo (ESAT-TOGO)" \
  "École privée spécialisée dans les métiers de l'aéronautique et des hautes technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Aéronautique, Maintenance Aéronautique, Logistique Aérienne, Technologies Avancées."

priv \
  "Institut Africain de Développement Sanitaire et Social (IADSS)" \
  "Institut privé de formation dans les domaines sanitaire et social." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Santé Publique, Développement Social, Assistance Sociale, Gestion Sanitaire."

priv \
  "Institut Technique Bonita Haus" \
  "Institut privé de formation technique et professionnelle." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations techniques: Hôtellerie, Tourisme, Restauration, Arts Culinaires."

priv \
  "Institut Régional d'Enseignement Supérieur et de Recherche en Développement Culturel" \
  "Institut privé dédié à la recherche et l'enseignement en développement culturel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Développement Culturel, Gestion du Patrimoine, Industries Culturelles, Tourisme Culturel."

priv \
  "École Nationale d'Administration (ENA) - Togo" \
  "École privée formant aux métiers de l'administration publique et privée." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Administration Publique, Gestion des Collectivités, RH, Finances Publiques."

priv \
  "DEFITECH Togo" \
  "Institut privé de formation en technologies et innovation." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Développement Web et Mobile, Design Digital, Marketing Digital, Infographie."

priv \
  "Institut Supérieur des Langues et des Affaires (ISLA)" \
  "Institut privé de formation en langues et commerce international." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Langues Étrangères Appliquées, Commerce International, Traduction, Relations Internationales."

priv \
  "American Institute of Commonwealth (AIC-Togo)" \
  "Institut privé proposant des formations aux standards internationaux, programmes bilingues." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Programmes bilingues en Management, Informatique, Finance, Relations Internationales."

priv \
  "Hôtel École Concordia" \
  "École hôtelière privée formant aux métiers de l'hôtellerie, de la restauration et du tourisme." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Hôtellerie, Restauration, Cuisine, Services Hôteliers, Tourisme."

priv \
  "CIB-INTA" \
  "Centre privé de formation en informatique, bureautique et nouvelles technologies." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Maintenance, Réseaux, Développement Web."

priv \
  "ESTECA" \
  "École supérieure privée de technologie et de commerce." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Commerce, Gestion, Informatique de Gestion, Marketing."

priv \
  "ESAM" \
  "École supérieure privée des affaires et de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Marketing, Finance, Comptabilité, Ressources Humaines."

priv \
  "École Supérieure d'Informatique et de Gestion (ESIG GLOBAL SUCCESS)" \
  "École privée spécialisée en informatique et gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique de Gestion, Développement Web, Comptabilité, Marketing Digital."

priv \
  "École Supérieure de Commerce et de l'Économie Numérique (ESCEN)" \
  "École privée de commerce axée sur l'économie numérique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Commerce, Économie Numérique, Marketing Digital, E-commerce, Gestion."

priv \
  "École Supérieure d'Audit et de Management (ESAM)" \
  "École privée d'audit et de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Audit, Management, Finance, Comptabilité, Contrôle de Gestion."

priv \
  "École des Hautes Études de Sciences et Technologies (HEST)" \
  "École privée de sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences et Technologies, Informatique, Mathématiques, Physique."

priv \
  "École Supérieure des Arts et Sciences du Numérique (ESASN)" \
  "École privée spécialisée dans les arts et sciences du numérique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Arts Numériques, Design Digital, Animation 3D, Développement Web, Multimédia."

priv \
  "École Supérieure des Études Cinématographiques (ESEC)" \
  "École privée de cinéma et d'audiovisuel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Réalisation Cinématographique, Production Audiovisuelle, Montage, Scénarisation."

priv \
  "École Supérieure des Techniques et Arts de la Communication (ESTAC)" \
  "École privée de communication et de techniques médiatiques." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Communication, Journalisme, Marketing Digital, Relations Publiques, Publicité."

priv \
  "École Maritime du Togo (EMARITO)" \
  "École privée spécialisée dans les métiers de la mer et du transport maritime." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Navigation Maritime, Logistique Portuaire, Transport International, Gestion Maritime."

priv \
  "École Supérieure du Tourisme et d'Hôtellerie Stella Matutina (ESTH-SM)" \
  "École privée de tourisme et d'hôtellerie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Tourisme, Hôtellerie, Gestion Hôtelière, Restauration, Événementiel."

priv \
  "École Supérieure de Management (ESMA)" \
  "École privée de management et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Ressources Humaines, Marketing, Finance, Entrepreneuriat."

priv \
  "École Supérieure de Relations Internationales et de Diplomatie (ESRID)" \
  "École privée de relations internationales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Relations Internationales, Diplomatie, Géopolitique, Droit International."

priv \
  "École Supérieure de Communication et de Gestion (ESCG-Tsévié)" \
  "École privée de communication et gestion située à Tsévié." \
  "Tsévié" \
  "Tsévié" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Communication, Gestion des Entreprises, Marketing, Comptabilité."

priv \
  "École des Micro-Entrepreneurs du Centre (EMC-Sokodé)" \
  "École privée d'entrepreneuriat située à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Entrepreneuriat, Microfinance, Gestion de Projets, Développement Local."

priv \
  "Institut Polytechnique des Bâtiments et des Travaux Publics (IPBTP)" \
  "Institut privé de formation aux métiers du BTP." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Bâtiment, Travaux Publics, Topographie, Génie Civil, Architecture."

priv \
  "Institut de Génie Biomédical de Lomé (IGEB)" \
  "Institut privé spécialisé en génie biomédical." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Génie Biomédical, Maintenance Hospitalière, Équipements Médicaux."

priv \
  "Institut Supérieur de Management et de Développement (ISMAD)" \
  "Institut privé de management et développement." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Développement Durable, Projets, Gouvernance."

priv \
  "Institut Supérieur de Management Adonaï (ISM Adonaï)" \
  "Institut privé de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Comptabilité, Marketing, Ressources Humaines."

priv \
  "Institut Supérieur de Bâtiment Ayin'a (ISBA)" \
  "Institut privé de formation aux métiers du bâtiment." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Bâtiment, Construction, Architecture, Génie Civil."

priv \
  "Institut Africain des Sciences, des Technologies et des Métiers (IASTM)" \
  "Institut privé de sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Métiers Techniques, Informatique."

priv \
  "Institut des Hautes Études de Relations Internationales et Stratégiques (IHERIS)" \
  "Institut privé de relations internationales et stratégie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Relations Internationales, Stratégie, Diplomatie, Sécurité Internationale, Géopolitique."

priv \
  "Heritage International University Institute (HIUI)" \
  "Institut universitaire privé international." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes internationaux en Management, Finance, Informatique, Commerce."

priv \
  "Institut Universitaire Nobel (IUN)" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Gestion, Informatique, Marketing, Communication."

priv \
  "Knowbridge University Institute (Sokodé)" \
  "Institut universitaire privé situé à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "UNIVERSITE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Informatique, Commerce, Entrepreneuriat."

priv \
  "Univers du Leadership International de XOESE (Univers XOESE)" \
  "Institut privé de leadership et de développement personnel." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Leadership, Développement Personnel, Management, Communication."

priv \
  "École Supérieure Le Miel de Kpové-Zion" \
  "École privée de formation supérieure." \
  "Kpové" \
  "Kpové" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Agriculture, Développement Rural, Entrepreneuriat."

priv \
  "Centre de Perfectionnement aux Techniques Économiques et Commerciales (CPTEC)" \
  "Centre privé de perfectionnement en techniques économiques et commerciales." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Techniques Commerciales, Gestion, Comptabilité, Marketing."

priv \
  "Centre Informatique de Formation et d'Orientation Professionnelle (CIFOP)" \
  "Centre privé de formation en informatique et orientation professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Orientation Professionnelle."

priv \
  "École de Finance" \
  "École privée spécialisée dans les métiers de la finance." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Finance, Banque, Assurance, Comptabilité, Gestion Financière."

priv \
  "École des Cadres" \
  "École privée de formation des cadres d'entreprise." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Administration, Gestion des Entreprises."

priv \
  "École Supérieure d'Informatique, de Business et d'Administration (ESIBA)" \
  "École privée d'informatique, business et administration." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique de Gestion, Business Administration, Marketing."

priv \
  "École Supérieure de Formation Professionnelle (CFP ANCILA)" \
  "Centre privé de formation professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Métiers Techniques, Services, Artisanat."

priv \
  "Faculté de Théologie des Assemblées de Dieu (FATAD)" \
  "Faculté privée de théologie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Théologie, Sciences Bibliques, Pastorale, Éducation Chrétienne."

priv \
  "FORMATEC" \
  "Centre privé de formation technique." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations techniques en Informatique, Électronique, Maintenance."

priv \
  "Haute Technologie d'Informatique et Bureautique Atlantis (HTIB-ATLANTIS)" \
  "Institut privé de hautes technologies." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Bureautique, Technologies de l'Information."

priv \
  "Hôtel École Avenida" \
  "École hôtelière privée." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Hôtellerie, Restauration, Tourisme, Arts Culinaires."

priv \
  "Hôtel École La Savoureuse (HES)" \
  "École hôtelière privée." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Hôtellerie, Restauration, Cuisine, Pâtisserie, Services Hôteliers."

priv \
  "Institut Africain Le Leadership" \
  "Institut privé de formation en leadership." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Leadership, Management, Développement Personnel, Communication."

priv \
  "Institut de Formation et de Recherche pour le Développement Durable (IFORDD)" \
  "Institut privé de recherche et formation en développement durable." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Développement Durable, Environnement, Écologie, Gestion des Ressources."

priv \
  "Institut de Recherche et de Formation en Développement Local (IRFODEL)" \
  "Institut privé de recherche et formation en développement local." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Développement Local, Décentralisation, Gouvernance Locale, Projets."

priv \
  "Institut de Technologie IPNET IT" \
  "Institut privé de technologies de l'information." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Réseaux, Sécurité Informatique, Développement, Administration Système."

priv \
  "Haute École de Technologies et de Management des Lacs (HETML)" \
  "Haute école privée de technologies et management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Technologies, Management, Informatique, Gestion."

priv \
  "Institut Supérieur La Maîtrise" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Comptabilité, Marketing, Secrétariat."

priv \
  "Institut Supérieur Le Technocrate" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Techniques Commerciales, Informatique."

priv \
  "Institut Supérieur Agata Carelli (ISAC)" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Paramédical, Puériculture, Soins Infirmiers."

priv \
  "Institut Supérieur d'Administration, des Sciences Économiques et de Gestion (ISAGES)" \
  "Institut supérieur privé d'administration et économie." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Administration, Sciences Économiques, Gestion des Entreprises."

priv \
  "Institut Supérieur des Sciences Économiques et Commerciales (ISSEC-KOUVAHEY)" \
  "Institut supérieur privé de sciences économiques et commerciales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences Économiques, Commerce, Marketing, Finance."

priv \
  "Institut Universitaire Lucas University College" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes universitaires en Gestion, Informatique, Droit, Communication."

priv \
  "Institut Universitaire Global Wealth" \
  "Institut universitaire privé." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Programmes en Finance, Management, Entrepreneuriat, Commerce International."

priv \
  "Institut Upsilon Collège de Paris Supérieur" \
  "Institut supérieur privé, antenne du Collège de Paris." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Management, Marketing, Finance, Ressources Humaines."

priv \
  "Institut des Technologies Avancées (JUMAU-ITA)" \
  "Institut privé de technologies avancées." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologies Avancées, Informatique, Robotique, Intelligence Artificielle."

priv \
  "Institut Supérieur de Management Mgr Bakpessi (Kara)" \
  "Institut supérieur privé situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion, Comptabilité."

priv \
  "Institut de Formation aux Métiers de la Sécurité Sociale (IFOMESS-Kara)" \
  "Institut privé de formation aux métiers de la sécurité sociale, situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sécurité Sociale, Protection Sociale, Gestion des Organismes Sociaux."

priv \
  "Institut de Formation aux Normes et Technologies de l'Informatique (IFNTI-Sokodé)" \
  "Institut privé de formation en informatique situé à Sokodé." \
  "Sokodé" \
  "Sokodé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Réseaux, Développement, Maintenance."

priv \
  "Institut des Sciences Technologies et Arts (ISTA-Kara)" \
  "Institut privé de sciences, technologies et arts situé à Kara." \
  "Kara" \
  "Kara" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Arts, Design."

priv \
  "Centre de Formation Supérieure SartenMode (CFS-SartenMode)" \
  "Centre privé de formation supérieure en mode et couture." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Stylisme, Couture, Mode, Design de Mode."

priv \
  "École Supérieure d'Administration et de Gestion (ESCA)" \
  "École privée d'administration et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Administration, Gestion, Comptabilité, Marketing."

priv \
  "École Supérieure de Technologie et de Gestion (ESTEG)" \
  "École privée de technologie et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologie, Gestion, Informatique, Commerce."

priv \
  "Institut Supérieur d'Études Générales (SUP IEG)" \
  "Institut supérieur privé d'études générales." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences, Lettres, Droit, Économie."

priv \
  "Institut de Recherche en Sciences de la Santé (ISOR-TOGO)" \
  "Institut privé de recherche et formation en santé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Sciences de la Santé, Soins Infirmiers, Paramédical."

priv \
  "Institut Supérieur des Sciences Psychologiques et de l'Humain (ISPSH)" \
  "Institut supérieur privé de psychologie et sciences humaines." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Psychologie, Sociologie, Sciences de l'Éducation, Travail Social."

priv \
  "Institut IAI-TOGO" \
  "Institut privé d'intelligence artificielle et d'informatique." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Informatique, Intelligence Artificielle, Data Science, Développement."

priv \
  "Institut des Arts et Technologies de l'Image (IATI)" \
  "Institut privé d'arts et technologies de l'image." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Arts Visuels, Photographie, Vidéo, Design Graphique, Multimédia."

priv \
  "Institut d'Ingénierie Hôtelière et du Tourisme (IIHT)" \
  "Institut privé d'hôtellerie et tourisme." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Hôtellerie, Tourisme, Restauration, Gestion Hôtelière."

priv \
  "Institut de Formation en Actuariat et Finance (IFA)" \
  "Institut privé de formation en actuariat et finance." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Actuariat, Finance Quantitative, Statistique, Gestion des Risques."

priv \
  "Institut de Formation en Gestion (IFG)" \
  "Institut privé de formation en gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Management, Ressources Humaines, Finance."

priv \
  "ESFP-FIMAC" \
  "École supérieure privée de formation professionnelle FIMAC." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations professionnelles en Comptabilité, Gestion, Marketing."

priv \
  "Social and Inclusive Business Institute of Togo (SIBI-Togo)" \
  "Institut privé de business social et inclusif." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Entrepreneuriat Social, Business Inclusif, Développement Durable."

priv \
  "École Supérieure d'Esthétique Appliquée Pharm-A-Peau (ESEA-Q'LS)" \
  "École privée d'esthétique et de soins." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Esthétique, Cosmétologie, Soins de la Peau, Bien-être."

priv \
  "Institut Consortium Saint John Révélation" \
  "Institut supérieur privé." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Théologie, Management, Développement Personnel."

priv \
  "École des Hautes Études de Commerce et de Gestion (HECOGU)" \
  "École privée de commerce et de gestion." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Commerce, Gestion, Marketing, Finance, Audit."

priv \
  "Institut Supérieur Privé de Management (UPM-TOGO)" \
  "Institut privé de management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Management, Gestion, Marketing, Finance."

priv \
  "Institut ELATSA" \
  "Institut privé de formation supérieure." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Lettres, Langues, Traduction, Communication."

priv \
  "Université UBLT" \
  "Université privée au Togo." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences, Technologies, Gestion, Droit."

priv \
  "Université des Sciences et Technologies du Togo (UST-TG)" \
  "Université privée des sciences et technologies." \
  "Lomé" \
  "Lomé" \
  "UNIVERSITE" \
  "Licence, Master" \
  "" \
  "" \
  "Formations en Sciences et Technologies, Informatique, Ingénierie."

priv \
  "CEFIP" \
  "Centre privé de formation et d'insertion professionnelle." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations professionnelles en Métiers du Tertiaire, Services, Commerce."

priv \
  "Centre Omnithérapeutique Africain (COA)" \
  "Centre privé de formation en médecine et thérapies." \
  "Lomé" \
  "Lomé" \
  "CENTRE_FORMATION_PROFESSIONNELLE" \
  "Formation professionnelle" \
  "" \
  "" \
  "Formations en Médecine Traditionnelle, Phytothérapie, Bien-être, Santé Naturelle."

priv \
  "Institut Supérieur des Technologies et de Management (ISTM)" \
  "Institut supérieur privé de technologies et management." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Technologies, Management, Informatique, Réseaux."

priv \
  "ISC College (CIBC)" \
  "College privé de formation supérieure." \
  "Lomé" \
  "Lomé" \
  "ECOLE_SUPERIEURE" \
  "Licence" \
  "" \
  "" \
  "Formations en Gestion, Commerce, Informatique."

echo "  Établissements privés ✓"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║         SEED TERMINÉ AVEC SUCCÈS              ║"
echo "╚═══════════════════════════════════════════════╝"

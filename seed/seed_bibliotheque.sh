#!/bin/bash
# seed_bibliotheque.sh — Seed toutes les données bibliothèque (Togo)
# Usage: bash seed_bibliotheque.sh [email] [password]
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
echo "║        SEED BIBLIOTHÈQUE TOGO                 ║"
echo "╚═══════════════════════════════════════════════╝"

# ─── SÉRIES (BAC TOGO) ───────────────────────────────
echo ""
echo "=== SÉRIES ==="

serie() { post "bibliotheque/series" "{\"titre\":\"$1\",\"resume\":\"$2\",\"contenu\":\"$2\",\"estPublie\":true,\"niveau\":\"$3\",\"matieresPrincipales\":\"$4\",\"debouches\":\"$5\"}"; }

serie "Série A1 (Lettres)" "Série littéraire axée sur la philosophie et le latin" "Lycée" "Philosophie, Latin, Français, Histoire-Géo, Langues" "Droit, Journalisme, Communication, Enseignement, Sciences Politiques"
serie "Série A2 (Lettres-Anglais)" "Série littéraire axée sur l'anglais et les langues vivantes" "Lycée" "Anglais, Français, Allemand, Histoire-Géo, Littérature" "Traduction, Tourisme, Diplomatie, Enseignement"
serie "Série B (Sciences Économiques)" "Série économique et sociale" "Lycée" "Mathématiques, Économie, Sociologie, Histoire-Géo, Anglais" "Gestion, Comptabilité, Banque, Commerce, Administration"
serie "Série C (Mathématiques)" "Série scientifique axée sur les mathématiques et la physique" "Lycée" "Mathématiques, Physique-Chimie, SVT, Anglais" "Ingénierie, Médecine, Informatique, Recherche, Architecture"
serie "Série D (Sciences Expérimentales)" "Série scientifique axée sur les SVT et la chimie" "Lycée" "SVT, Physique-Chimie, Mathématiques, Anglais" "Médecine, Pharmacie, Agronomie, Biologie, Environnement"
serie "Série E (Mathématiques-Techniques)" "Série technologique industrielle" "Lycée" "Mathématiques, Sciences Industrielles, Physique, Anglais" "Génie Civil, Électrotechnique, Mécanique, Maintenance"
serie "Série F1 (Construction Mécanique)" "Série technique en construction mécanique" "Lycée Technique" "Construction Mécanique, Dessin Technique, Mathématiques" "Mécanique Auto, Chaudronnerie, Maintenance Industrielle"
serie "Série F2 (Électronique)" "Série technique en électronique" "Lycée Technique" "Électronique, Électrotechnique, Mathématiques, Physique" "Télécommunications, Informatique, Domotique"
serie "Série F3 (Électrotechnique)" "Série technique en électrotechnique" "Lycée Technique" "Électrotechnique, Électronique, Mathématiques" "Énergie, Maintenance, Installation Électrique"
serie "Série F4 (Génie Civil)" "Série technique en génie civil" "Lycée Technique" "Génie Civil, Topographie, Dessin Technique, Mathématiques" "BTP, Architecture, Construction, Urbanisme"
serie "Série G1 (Commerce)" "Série technique commerciale" "Lycée Technique" "Commerce, Économie, Comptabilité, Droit, Anglais" "Marketing, Vente, Import-Export, Banque"
serie "Série G2 (Comptabilité)" "Série technique comptable" "Lycée Technique" "Comptabilité, Mathématiques Financières, Droit, Économie" "Expertise Comptable, Finance, Audit, Gestion"
serie "Série G3 (Secrétariat)" "Série technique bureautique" "Lycée Technique" "Bureautique, Français, Anglais, Communication" "Assistant de Direction, Administration, RH"
echo "  13 séries ✓"

# ─── FILIÈRES (ENSEIGNEMENT SUPÉRIEUR) ───────────────
echo ""
echo "=== FILIÈRES ==="

filiere() { post "bibliotheque/filieres" "{\"titre\":\"$1\",\"resume\":\"$2\",\"contenu\":\"$2\",\"estPublie\":true,\"duree\":\"$3\",\"niveauRequis\":\"$4\",\"conditionsAdmission\":\"$5\",\"domaine\":\"$6\",\"debouchesMetiers\":\"$7\"}"; }

# Sciences & Technologies
filiere "Informatique" "Programmation, réseaux, intelligence artificielle, cybersécurité, développement web" "3-5 ans" "Bac C/D/E" "Concours ou dossier" "Sciences & Technologies" "Développeur, Administrateur Réseau, Data Scientist, Analyste Cybersécurité"
filiere "Mathématiques Appliquées" "Modélisation mathématique, statistiques, analyse de données" "3-5 ans" "Bac C" "Concours" "Sciences & Technologies" "Statisticien, Actuaire, Analyste Financier"
filiere "Physique-Chimie" "Physique fondamentale, chimie des matériaux, énergies renouvelables" "3-5 ans" "Bac C/D" "Concours" "Sciences & Technologies" "Ingénieur, Chercheur, Enseignant"
filiere "Biologie" "Biologie moléculaire, biochimie, microbiologie, biotechnologies" "3-5 ans" "Bac D" "Concours" "Sciences & Technologies" "Biologiste, Chercheur, Technicien de Laboratoire"
filiere "Génie Civil" "Construction, ponts, routes, bâtiments, matériaux" "3-5 ans" "Bac C/E/F4" "Concours" "Sciences & Technologies" "Ingénieur Génie Civil, Architecte, Chef de Chantier, Topographe"
filiere "Génie Électrique" "Électrotechnique, électronique, automatismes, énergie" "3-5 ans" "Bac C/E/F3" "Concours" "Sciences & Technologies" "Ingénieur Électrique, Électrotechnicien, Automaticien"
filiere "Génie Mécanique" "Mécanique industrielle, conception, maintenance" "3-5 ans" "Bac C/E/F1" "Concours" "Sciences & Technologies" "Ingénieur Mécanique, Technicien Maintenance, Dessinateur Industriel"
filiere "Génie Informatique" "Systèmes embarqués, IoT, robotique, automatisation" "3-5 ans" "Bac C/D/E/F2" "Concours" "Sciences & Technologies" "Ingénieur Informatique, Roboticien, Architecte Système"

# Médecine & Santé
filiere "Médecine" "Formation médicale générale, chirurgie, pédiatrie, gynécologie" "7 ans" "Bac D/C" "Concours" "Médecine & Santé" "Médecin, Chirurgien, Pédiatre, Gynécologue"
filiere "Pharmacie" "Médicaments, pharmacologie, industrie pharmaceutique" "5 ans" "Bac D/C" "Concours" "Médecine & Santé" "Pharmacien, Chercheur, Industrie Pharmaceutique"
filiere "Odontologie" "Chirurgie dentaire, soins bucco-dentaires" "5 ans" "Bac D/C" "Concours" "Médecine & Santé" "Dentiste, Orthodontiste"
filiere "Sciences Infirmières" "Soins infirmiers, santé publique, puériculture" "3 ans" "Bac D/C" "Dossier" "Médecine & Santé" "Infirmier, Sage-Femme, Cadre de Santé"

# Droit & Sciences Politiques
filiere "Droit" "Droit civil, pénal, des affaires, international" "3-5 ans" "Bac A/B" "Concours" "Droit & Politique" "Avocat, Juge, Notaire, Juriste d'Entreprise, Magistrat"
filiere "Sciences Politiques" "Relations internationales, politiques publiques, diplomatie" "3-5 ans" "Bac A/B" "Concours" "Droit & Politique" "Diplomate, Analyste Politique, Journaliste Politique"

# Économie & Gestion
filiere "Économie" "Microéconomie, macroéconomie, développement, politiques économiques" "3-5 ans" "Bac B/C" "Concours" "Économie & Gestion" "Économiste, Analyste, Banquier, Fonctionnaire"
filiere "Gestion des Entreprises" "Management, marketing, RH, finance d'entreprise" "3-5 ans" "Bac B/G1/G2" "Dossier" "Économie & Gestion" "Manager, Chef d'Entreprise, Consultant"
filiere "Finance et Comptabilité" "Comptabilité, audit, fiscalité, finance" "3-5 ans" "Bac B/G2" "Dossier" "Économie & Gestion" "Comptable, Auditeur, Expert-Comptable, Contrôleur de Gestion"
filiere "Banque et Assurance" "Secteur bancaire, assurances, marchés financiers" "3 ans" "Bac B/G2" "Dossier" "Économie & Gestion" "Banquier, Agent d'Assurance, Conseiller Financier"

# Lettres & Sciences Humaines
filiere "Lettres Modernes" "Littérature, linguistique, analyse textuelle" "3-5 ans" "Bac A" "Dossier" "Lettres & Sciences Humaines" "Enseignant, Écrivain, Journaliste, Éditeur"
filiere "Anglais" "Littérature anglaise, linguistique, traduction" "3-5 ans" "Bac A/A2" "Dossier" "Lettres & Sciences Humaines" "Traducteur, Interprète, Enseignant d'Anglais"
filiere "Sociologie" "Étude des sociétés, enquêtes sociales, développement communautaire" "3-5 ans" "Bac A/B" "Dossier" "Lettres & Sciences Humaines" "Sociologue, Enquêteur, Travailleur Social"
filiere "Psychologie" "Psychologie clinique, cognitive, sociale" "3-5 ans" "Bac A/B/D" "Concours" "Lettres & Sciences Humaines" "Psychologue, Conseiller, Coach"
filiere "Géographie" "Aménagement du territoire, environnement, climat" "3-5 ans" "Bac A/B/D" "Dossier" "Lettres & Sciences Humaines" "Géographe, Urbaniste, Environnementaliste"
filiere "Histoire" "Histoire générale, histoire africaine, patrimoine" "3-5 ans" "Bac A/B" "Dossier" "Lettres & Sciences Humaines" "Historien, Archiviste, Guide Touristique"

# Agriculture & Environnement
filiere "Agronomie" "Agriculture, science des sols, production végétale et animale" "3-5 ans" "Bac D" "Concours" "Agriculture & Environnement" "Ingénieur Agronome, Agriculteur, Technicien Agricole"
filiere "Sciences Forestières" "Gestion des forêts, reforestation, bois" "3-5 ans" "Bac D" "Concours" "Agriculture & Environnement" "Forestier, Gestionnaire de Parcs, Écologue"
filiere "Sciences Environnementales" "Écologie, gestion des déchets, développement durable" "3-5 ans" "Bac D/C" "Concours" "Agriculture & Environnement" "Environmentaliste, Chargé de Développement Durable"

# Éducation
filiere "Sciences de l'Éducation" "Pédagogie, didactique, psychopédagogie" "3-5 ans" "Bac A/B/D" "Dossier" "Éducation" "Enseignant, Inspecteur, Directeur d'École, Formateur"
filiere "Enseignement Primaire" "Formation des instituteurs, pédagogie générale" "3 ans" "Bac A/B/D" "Concours" "Éducation" "Instituteur, Maître d'École"

# Arts & Communication
filiere "Arts Plastiques" "Peinture, sculpture, design, arts numériques" "3-5 ans" "Bac A/Technique" "Dossier + Portfolio" "Arts & Culture" "Artiste, Designer, Graphiste, Architecte d'Intérieur"
filiere "Communication et Journalisme" "Journalisme, relations publiques, médias numériques" "3-5 ans" "Bac A/B/G" "Concours" "Arts & Culture" "Journaliste, Chargé de Communication, Community Manager"
filiere "Tourisme et Hôtellerie" "Gestion hôtelière, tourisme, événementiel" "3 ans" "Bac A/B/G" "Dossier" "Arts & Culture" "Hôtelier, Guide Touristique, Organisateur d'Événements"

echo "  32 filières ✓"

# ─── MÉTIERS ──────────────────────────────────────────
echo ""
echo "=== MÉTIERS ==="

metier() { post "bibliotheque/metiers" "{\"titre\":\"$1\",\"resume\":\"$2\",\"contenu\":\"$2\",\"estPublie\":true,\"secteur\":\"$3\",\"missions\":\"$4\",\"competences\":\"$5\",\"formationsAcces\":\"$6\",\"debouchesTogo\":\"$7\",\"fourchetteSalaire\":\"$8\"}"; }

# Santé
metier "Médecin" "Diagnostique et traite les maladies. Peut se spécialiser en chirurgie, pédiatrie, gynécologie, etc." "Santé" "Consulter des patients, prescrire des traitements, réaliser des interventions" "Rigueur, empathie, capacité d'analyse, sang-froid" "Doctorat en Médecine (7 ans)" "CHU Lomé, CHU Kara, hôpitaux régionaux" "300 000 - 1 500 000 FCFA"
metier "Infirmier" "Soigne les patients et assiste les médecins dans les hôpitaux et cliniques" "Santé" "Soins infirmiers, administration des médicaments, suivi des patients" "Patience, organisation, sens du contact" "Diplôme d'État Infirmier (3 ans)" "Hôpitaux, cliniques, centres de santé" "150 000 - 400 000 FCFA"
metier "Pharmacien" "Délivre les médicaments et conseille les patients" "Santé" "Délivrance d'ordonnances, conseil pharmaceutique, gestion de pharmacie" "Précision, honnêteté, connaissances pharmaceutiques" "Doctorat en Pharmacie (5 ans)" "Pharmacies, hôpitaux, industrie pharmaceutique" "250 000 - 800 000 FCFA"
metier "Sage-Femme" "Accompagne les femmes pendant la grossesse, l'accouchement et le post-partum" "Santé" "Suivi de grossesse, accouchements, consultations post-natales" "Douceur, sang-froid, expertise médicale" "Diplôme d'État Sage-Femme (3-4 ans)" "Maternités, hôpitaux, cliniques" "150 000 - 350 000 FCFA"

# Technologies
metier "Développeur Web" "Conçoit et développe des sites web et applications" "Numérique" "Coder des applications, tester des fonctionnalités, maintenir des sites" "Logique, créativité, veille technologique" "Licence/Master en Informatique, Bootcamp" "Freelance, entreprises, ESN, startups" "200 000 - 800 000 FCFA"
metier "Administrateur Réseau" "Gère l'infrastructure réseau d'une organisation" "Numérique" "Configuration réseau, maintenance, sécurité, dépannage" "Rigueur, réactivité, connaissances techniques" "Licence/Master en Réseaux" "Entreprises, FAI, administrations" "250 000 - 600 000 FCFA"
metier "Data Scientist" "Analyse les données pour aider à la prise de décision" "Numérique" "Collecte et analyse de données, modélisation, visualisation" "Mathématiques, programmation, esprit d'analyse" "Master/Doctorat en Data Science" "Banques, télécoms, startups" "400 000 - 1 200 000 FCFA"
metier "Technicien de Maintenance" "Répare et maintient les équipements électroniques et informatiques" "Numérique" "Diagnostic de pannes, réparation, maintenance préventive" "Habileté manuelle, méthode, patience" "BTS/DUT Génie Électrique ou Informatique" "Entreprises, ateliers, services techniques" "100 000 - 300 000 FCFA"

# Agriculture
metier "Ingénieur Agronome" "Conseille les agriculteurs et améliore les rendements agricoles" "Agriculture" "Conseil technique, gestion d'exploitation, recherche agronomique" "Connaissances agricoles, terrain, pédagogie" "Diplôme d'Ingénieur Agronome (5 ans)" "ITRA, Ministère Agriculture, ONG, privé" "250 000 - 600 000 FCFA"
metier "Agriculteur" "Produit des cultures et élève du bétail" "Agriculture" "Préparation des sols, semis, récolte, élevage" "Force physique, patience, gestion" "CAP/Bac Agricole, expérience terrain" "Fermes, coopératives, exploitation personnelle" "50 000 - 500 000 FCFA"
metier "Technicien Agricole" "Assiste les ingénieurs agronomes et encadre les agriculteurs" "Agriculture" "Encadrement de producteurs, suivi des cultures, démonstrations" "Sens pratique, pédagogie, mobilité" "BTS/DUT Agriculture" "Projets agricoles, ONG, services d'État" "150 000 - 350 000 FCFA"

# Bâtiment & Travaux Publics
metier "Ingénieur Génie Civil" "Conçoit et supervise les projets de construction" "BTP" "Conception de plans, supervision de chantier, contrôle qualité" "Rigueur mathématique, leadership, sens pratique" "Diplôme d'Ingénieur Génie Civil (5 ans)" "Entreprises BTP, État, promoteurs" "300 000 - 800 000 FCFA"
metier "Architecte" "Conçoit les bâtiments et veille à leur esthétique et fonctionnalité" "BTP" "Conception architecturale, plans, suivi de chantier" "Créativité, précision, vision spatiale" "Diplôme d'Architecte (5-6 ans)" "Cabinets d'architecture, promoteurs" "300 000 - 1 000 000 FCFA"
metier "Maçon" "Construit les murs et les structures en béton" "BTP" "Montage de murs, coffrage, coulage de béton" "Force physique, précision, expérience" "CAP Maçonnerie, formation sur le tas" "Chantiers, entreprises BTP" "50 000 - 200 000 FCFA"
metier "Électricien" "Installe et maintient les installations électriques" "BTP" "Installation électrique, dépannage, mise aux normes" "Précision, connaissance des normes, sécurité" "CAP/BTS Électrotechnique" "Entreprises, particuliers, industrie" "80 000 - 250 000 FCFA"
metier "Plombier" "Installe et répare les systèmes de plomberie" "BTP" "Installation sanitaire, tuyauterie, dépannage" "Habileté manuelle, méthode" "CAP Plomberie" "Particuliers, entreprises" "60 000 - 200 000 FCFA"

# Économie & Finance
metier "Expert-Comptable" "Gère la comptabilité des entreprises et certifie les comptes" "Finance" "Tenue de comptes, audit, conseil fiscal" "Rigueur, intégrité, organisation" "Master CCA, DEC Expert-Comptable" "Cabinets, entreprises, administrations" "400 000 - 1 500 000 FCFA"
metier "Banquier" "Gère les comptes clients et les opérations bancaires" "Finance" "Accueil client, crédits, placements, conseil financier" "Sens du service, rigueur, discrétion" "Licence/Master Banque-Finance" "Banques, microfinance" "200 000 - 600 000 FCFA"
metier "Comptable" "Enregistre les opérations comptables d'une entreprise" "Finance" "Saisie comptable, déclarations fiscales, bilans" "Organisation, précision, discrétion" "BTS/DUT/Licence Comptabilité" "Toutes entreprises" "100 000 - 350 000 FCFA"

# Commerce & Marketing
metier "Commercial" "Vend les produits ou services d'une entreprise" "Commerce" "Prospection, négociation, suivi client" "Persuasion, dynamisme, sens du relationnel" "Bac+2/3 Commerce" "Tous secteurs" "100 000 - 500 000 FCFA"
metier "Community Manager" "Gère la présence en ligne d'une marque sur les réseaux sociaux" "Commerce" "Publications, animation de communauté, modération" "Créativité, réactivité, bon français" "Licence Communication/Marketing" "Agences, entreprises, ONG" "150 000 - 400 000 FCFA"
metier "Chef de Produit" "Développe et gère un produit ou une gamme de produits" "Commerce" "Étude marché, développement produit, lancement, suivi" "Analyse, créativité, gestion de projet" "Master Marketing/Commerce" "Grandes entreprises, industrie" "300 000 - 800 000 FCFA"

# Éducation
metier "Enseignant" "Transmet des connaissances aux élèves dans une discipline" "Éducation" "Préparation de cours, enseignement, évaluation" "Pédagogie, patience, passion" "Licence/Master + Concours ENI" "Écoles publiques et privées" "100 000 - 350 000 FCFA"
metier "Formateur" "Forme des adultes à des compétences professionnelles" "Éducation" "Animation de formations, conception de programmes" "Expertise métier, pédagogie, aisance orale" "Bac+3/5 + expérience métier" "Centres de formation, entreprises" "200 000 - 600 000 FCFA"
metier "Directeur d'École" "Dirige un établissement scolaire" "Éducation" "Gestion administrative, animation pédagogique, relations parents" "Leadership, gestion, sens du contact" "Master + Concours de Direction" "Établissements scolaires" "250 000 - 500 000 FCFA"

# Droit
metier "Avocat" "Conseille et défend ses clients en justice" "Droit" "Consultation juridique, plaidoirie, rédaction d'actes" "Éloquence, analyse, discrétion" "Master Droit + CAPA + Barreau" "Cabinets, entreprises, administration" "300 000 - 2 000 000 FCFA"
metier "Notaire" "Authentifie les actes juridiques (ventes, mariages, successions)" "Droit" "Rédaction d'actes authentiques, conseil juridique" "Précision, intégrité, rigueur" "Master Droit + Diplôme Notaire" "Études notariales" "300 000 - 1 000 000 FCFA"
metier "Magistrat" "Rend la justice au sein des tribunaux" "Droit" "Jugement, instruction, application de la loi" "Impartialité, sens de la justice, rigueur" "Master Droit + Concours ENM" "Tribunaux, cours d'appel" "300 000 - 800 000 FCFA"

# Logistique & Transport
metier "Conducteur de Poids Lourd" "Transporte des marchandises sur longues distances" "Transport" "Conduite, respect des délais, entretien véhicule" "Endurance, prudence, sens des responsabilités" "Permis C/CE, FIMO" "Transporteurs, entreprises" "100 000 - 300 000 FCFA"
metier "Logisticien" "Organise le transport et le stockage des marchandises" "Transport" "Gestion des stocks, optimisation des flux, ordonnancement" "Organisation, réactivité, gestion" "BTS/DUT/Licence Logistique" "Entreprises, transporteurs, ports" "200 000 - 500 000 FCFA"
metier "Agent de Transit" "Gère les formalités douanières pour l'import-export" "Transport" "Dédouanement, documents douaniers, relation douane" "Connaissance douane, rigueur, organisation" "BTS Transit, Licence Transport" "Transitaires, importateurs" "150 000 - 400 000 FCFA"

# Arts & Culture
metier "Graphiste" "Conçoit des visuels pour la communication (logos, affiches, sites)" "Arts" "Création graphique, mise en page, retouche photo" "Créativité, maîtrise logiciels, sens esthétique" "Bac+2/3 Design Graphique" "Agences, imprimeries, freelance" "100 000 - 400 000 FCFA"
metier "Journaliste" "Recherche, vérifie et présente l'information" "Médias" "Enquête terrain, rédaction d'articles, interview" "Curiosité, bon français, intégrité" "Master Journalisme/Communication" "Journaux, radios, télévisions, web" "150 000 - 500 000 FCFA"
metier "Photographe" "Prend des photos professionnelles pour divers usages" "Arts" "Prise de vue, retouche, reportage" "Créativité, technique, sens de l'image" "Formation photo, expérience" "Freelance, agences, presse" "50 000 - 300 000 FCFA"

# Hôtellerie & Tourisme
metier "Hôtelier" "Gère un établissement hôtelier" "Tourisme" "Accueil, gestion des réservations, management équipe" "Sens du service, gestion, sourire" "BTS/Licence Hôtellerie" "Hôtels, lodges, auberges" "150 000 - 500 000 FCFA"
metier "Guide Touristique" "Fait découvrir les sites touristiques aux visiteurs" "Tourisme" "Animation de visites guidées, information culturelle" "Éloquence, culture générale, langues" "Formation guide, licence tourisme" "Agences, sites touristiques" "80 000 - 250 000 FCFA"
metier "Cuisinier" "Prépare les repas dans des établissements de restauration" "Tourisme" "Préparation culinaire, gestion de cuisine, créativité" "Créativité, rapidité, hygiène" "CAP/BTS Cuisine" "Restaurants, hôtels, collectivités" "50 000 - 250 000 FCFA"

echo "  42 métiers ✓"

# ─── ÉTABLISSEMENTS ──────────────────────────────────
echo ""
echo "=== ÉTABLISSEMENTS ==="

etab() { post "bibliotheque/etablissements" "{\"titre\":\"$1\",\"resume\":\"$2\",\"contenu\":\"$2\",\"estPublie\":true,\"adresse\":\"$3\",\"ville\":\"$4\",\"typeEtablissement\":\"$5\",\"contacts\":\"$6\",\"siteWeb\":\"$7\",\"offreFormation\":\"$8\",\"estPublic\":$9}"; }

# Universités publiques
etab "Université de Lomé" "La plus grande université du Togo. Plus de 60 000 étudiants." "Lomé" "Lomé" "UNIVERSITE" "+228 22 25 59 00" "https://univ-lome.tg" "Toutes les disciplines (sciences, lettres, droit, économie, médecine)" true
etab "Université de Kara" "Deuxième université publique du Togo, située dans la région de la Kara." "Kara" "Kara" "UNIVERSITE" "+228 26 61 10 67" "https://univ-kara.tg" "Sciences, lettres, droit, économie, agronomie" true
etab "Université des Sciences de la Santé" "Spécialisée dans les formations médicales et paramédicales." "Lomé" "Lomé" "UNIVERSITE" "+228 22 21 42 60" "" "Médecine, pharmacie, odontologie, soins infirmiers" true

# Grandes écoles
etab "École Nationale d'Administration (ENA)" "Forme les hauts fonctionnaires de l'État togolais." "Lomé" "Lomé" "GRANDE_ECOLE" "+228 22 21 30 63" "" "Administration publique, diplomatie" true
etab "École Polytechnique de Lomé" "Formation d'ingénieurs de haut niveau." "Lomé" "Lomé" "GRANDE_ECOLE" "+228 22 25 59 00" "" "Génie civil, électrique, mécanique, informatique" true
etab "Institut National de la Jeunesse et des Sports (INJS)" "Formation aux métiers du sport." "Lomé" "Lomé" "GRANDE_ECOLE" "+228 22 21 40 38" "" "Éducation physique, coaching sportif" true
etab "École Supérieure d'Agronomie (ESA)" "Formation aux métiers de l'agriculture et de l'environnement." "Lomé" "Lomé" "GRANDE_ECOLE" "" "" "Agronomie, sciences forestières, élevage" true

# Lycées publics
etab "Lycée de Tokoin" "Grand lycée public du centre-ville de Lomé." "Tokoin, Lomé" "Lomé" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée de Kégué" "Important lycée public dans la banlieue de Lomé." "Kégué, Lomé" "Lomé" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée d'Adidogomé" "Lycée public situé à Adidogomé (Lomé)." "Adidogomé, Lomé" "Lomé" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée de Bè" "Lycée public du quartier de Bè à Lomé." "Bè, Lomé" "Lomé" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée de Kara" "Principal lycée de la ville de Kara." "Kara" "Kara" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée d'Atakpamé" "Lycée public de la ville d'Atakpamé." "Atakpamé" "Atakpamé" "LYCEE" "" "" "Séries A, B, C, D" true
etab "Lycée de Sokodé" "Lycée public de Sokodé, région Centrale." "Sokodé" "Sokodé" "LYCEE" "" "" "Séries A, B, C, D" true

# Lycées techniques
etab "Lycée Technique de Lomé" "Principal lycée technique du Togo." "Lomé" "Lomé" "LYCEE" "" "" "Séries F1, F2, F3, F4, G1, G2, G3" true
etab "Lycée Technique de Kara" "Lycée technique de la région de la Kara." "Kara" "Kara" "LYCEE" "" "" "Séries F, G" true
etab "Lycée Technique d'Atakpamé" "Lycée technique de la région des Plateaux." "Atakpamé" "Atakpamé" "LYCEE" "" "" "Séries F, G" true

# Écoles privées
etab "Institut Supérieur de Gestion (ISG)" "École privée de gestion et de commerce." "Lomé" "Lomé" "ECOLE_SUPERIEURE" "+228 22 21 60 17" "" "Gestion, marketing, RH, finance" false
etab "Université Catholique de l'Afrique de l'Ouest (UCAO)" "Université privée catholique." "Lomé" "Lomé" "UNIVERSITE" "" "" "Sciences humaines, droit, économie" false
etab "Université WASCAL" "Université ouest-africaine spécialisée en sciences du climat." "Lomé" "Lomé" "UNIVERSITE" "" "" "Climatologie, environnement" false
etab "École Supérieure des Techniques Biologiques" "Formation privée en biologie et santé." "Lomé" "Lomé" "ECOLE_SUPERIEURE" "" "" "Biologie, analyses médicales" false
etab "Centre de Formation et de Perfectionnement (CFP)" "Centre privé de formation professionnelle." "Lomé" "Lomé" "CENTRE_FORMATION_PROFESSIONNELLE" "" "" "Bureautique, comptabilité, informatique" false

echo "  22 établissements ✓"

# ─── FAQ ──────────────────────────────────────────────
echo ""
echo "=== FAQ ==="

faq() { post "bibliotheque/faq" "{\"question\":\"$1\",\"reponse\":\"$2\",\"categorie\":\"$3\",\"estPublie\":true}"; }

faq "Comment choisir ma série au lycée ?" "Choisis ta série en fonction de tes points forts et des études que tu veux faire. Si tu aimes les maths et la physique → Série C. Si tu préfères les SVT et la chimie → Série D. Si tu es plutôt littéraire → Série A. Pour le commerce et la gestion → Série B ou G." "ORIENTATION"
faq "Quelle série choisir pour devenir médecin ?" "Pour devenir médecin, il faut passer par la Série D (Sciences Expérimentales) au lycée, puis réussir le concours d'entrée à la Faculté de Médecine. La Série C est aussi acceptée mais la D est recommandée." "ORIENTATION"
faq "Quelle est la différence entre Licence, Master et Doctorat ?" "La Licence (Bac+3) est le premier diplôme universitaire. Le Master (Bac+5) permet de se spécialiser. Le Doctorat (Bac+8) est le plus haut diplôme, destiné à la recherche. Dans le système LMD, chaque étape dure 2 ans sauf la Licence qui dure 3 ans." "INSCRIPTION"
faq "Comment obtenir une bourse d'études au Togo ?" "Les bourses sont attribuées par l'Office des Bourses et Stages (OBS) du Togo. Il faut déposer un dossier chaque année. Les critères incluent les résultats académiques et le revenu familial. Les bourses couvrent les frais de scolarité et parfois une allocation." "BOURSE"
faq "Quels sont les débouchés après une Série C ?" "La Série C ouvre les portes des grandes écoles d'ingénieurs, des facultés de médecine, d'informatique, de mathématiques, de physique et d'architecture. C'est la série la plus polyvalente pour les études scientifiques." "ORIENTATION"
faq "Peut-on changer de filière après le Bac ?" "Oui, il est possible de changer de filière via les passerelles. Par exemple, passer de la Série D à l'informatique ou du commerce à la gestion. Certaines universités proposent des années préparatoires ou des concours d'entrée ouverts à tous." "INSCRIPTION"
faq "Comment s'inscrire à l'Université de Lomé ?" "Les inscriptions se font en ligne via le site de l'UL. Les candidats doivent remplir un formulaire, fournir leurs relevés de notes et payer les frais d'inscription. Les concours d'entrée se déroulent généralement en juillet-août." "INSCRIPTION"
faq "Quels sont les métiers les plus demandés au Togo ?" "Les secteurs qui recrutent le plus au Togo sont : l'agriculture, les télécommunications, la banque, l'enseignement, la santé, le BTP, et le numérique. Les métiers techniques et digitaux sont particulièrement porteurs." "METIER"
faq "Comment s'orienter après la 3ème ?" "Après le BEPC, tu peux choisir entre le lycée général (préparer le Bac), le lycée technique (Bac technique) ou le centre de formation professionnelle (CAP). Parle avec ton conseiller d'orientation et visite les journées portes ouvertes." "ORIENTATION"
faq "Quel est le salaire moyen d'un jeune diplômé au Togo ?" "Le salaire d'un jeune diplômé varie selon le secteur : 100 000-200 000 FCFA dans l'enseignement, 150 000-300 000 FCFA dans la fonction publique, 200 000-400 000 FCFA dans le privé, 250 000-600 000 FCFA dans les banques et télécoms." "METIER"
faq "Les études à l'étranger sont-elles accessibles ?" "Oui, plusieurs programmes existent : bourses françaises (Campus France), bourses allemandes (DAAD), bourses canadiennes, et programmes de l'Union Africaine. Les critères incluent l'excellence académique et un projet d'études cohérent." "BOURSE"
faq "Qu'est-ce que le test d'orientation RIASEC ?" "Le test RIASEC évalue tes centres d'intérêt selon 6 profils : Réaliste, Investigateur, Artistique, Social, Entreprenant, Conventionnel. Il t'aide à identifier les métiers et formations qui correspondent à ta personnalité." "ORIENTATION"

echo "  12 FAQ ✓"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║        SEED TERMINÉ AVEC SUCCÈS !             ║"
echo "╚═══════════════════════════════════════════════╝"
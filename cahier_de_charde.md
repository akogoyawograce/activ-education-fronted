
Cahier de charge fonctionnel
1. Module Gestion des Profils Utilisateurs (Espace Personnel et Sécurité)
1.1. Architecture générale du module
1.2. Authentification et Inscription
1.2.1. Inscription sécurisée
1.2.2. Connexion sécurisée
1.3. Gestion du Profil Utilisateur
1.3.1. Informations de base (Complétude du profil)
1.3.2. Upload et gestion des documents
1.3.3. Favoris et centres d'intérêt
1.3.4. Historique des activités
1.4. Gestion des Comptes Liés et Familles
1.5. Paramètres de Confidentialité et Sécurité
1.6. Intégration avec les autres modules
1.7. Spécificités techniques à noter pour les développeurs
2. Module Exploration des Formations et Métiers (La Bibliothèque Centrale)
2.1. Architecture de la base de connaissances
2.2. Accessibilité et Navigation
2.3. Structure commune enrichie pour chaque type de fiche
2.4. Détail des quatre types de fiches
2.4.1. Fiche "Séries et Spécialités" (Parcours secondaire)
2.4.2. Fiche "Filières et Formations" (Parcours supérieur)
2.4.3. Fiche "Métiers" (Réalité professionnelle)
2.4.4. Fiche "Établissements" (Catalogue des lieux de formation)
2.5. Intégration avec les autres modules
3. Module Diagnostic d'Orientation
3.1. Architecture générale du module diagnostic
3.2. Quiz d'Orientation (Basé sur les aspirations)
3.2.1. Fonctionnalités d’orientation
3.2.2. Arbre de décision par profil
A. Parcours "Nouveau Bachelier": Je viens d'avoir le Bac, que faire après ?
B. Parcours "Réorientation Universitaire" :J'ai commencé des études mais je veux changer
C. Parcours "Nouveau Bepcien" :Je viens d'avoir le BEPC, quelle série choisir ?
3.3. Analyse Académique :Basée sur les performances réelles
3.3.1. Fonctionnalités macroscopiques
3.3.2. Fonctionnalités microscopiques
A. Import et structuration des données
B. Moteur de correspondance académique
C. Croisement avec le Quiz (Mode combiné)
3.4. Livrables et affichage des résultats
3.5. Intégration avec les autres modules
4. Module Interaction et Accompagnement: Conseil personnalisé
4.1. Architecture générale du module
4.2.1. Fonctionnalités macroscopiques
4.2.2. Fonctionnalités microscopiques
4.3. Système de Messagerie / Contact (Échange asynchrone)
4.3.1. Fonctionnalités macroscopiques (côté utilisateur)
4.3.2. Fonctionnalités microscopiques (côté conseiller - back-office)
4.4. Prise de Rendez-vous et Accompagnement Approfondi (Échange synchrone)
4.4.1. Fonctionnalités macroscopiques
4.4.2. Fonctionnalités microscopiques
4.5. Espace d'Échange Spécifique (Situations Particulières)
4.5.1. Accompagnement pour les jeunes en situation de handicap
4.5.2. Accompagnement pour les jeunes en décrochage ou déscolarisés
4.5.3. Accompagnement pour les adultes en reconversion
4.6. Intégration avec les autres modules
4.7. Spécificités techniques à noter pour les développeurs
5. Module Administration et Modération (Back-office)
5.1. Architecture générale du module
5.2. Gestion des Contenus : Alimentation de la Bibliothèque Centrale
5.2.1. Gestion des fiches (Séries, Filières, Métiers, Établissements)
5.2.2. Gestion des vidéos (Vidéothèque)
5.2.3. Gestion des quiz (Module 3.1)
5.3. Gestion des Utilisateurs et Conseillers
5.3.1. Gestion des utilisateurs finaux
5.3.2. Gestion des conseillers (Ressources humaines)
5.4. Modération des Interactions
5.4.1. Modération de la FAQ collaborative
5.4.2. Modération des échanges
5.5.Pilotage et Statistiques
5.5.1. Statistiques d'audience
5.5.2. Statistiques des diagnostics (Module 3)
5.5.3. Statistiques de l'accompagnement (Module 4)
5.5.4. Rapports exportables
5.6. Paramétrages Système
5.7. Intégration avec les autres modules
5.8. Spécificités techniques à noter pour les développeurs



Cahier de charge fonctionnel 
1. Module Gestion des Profils Utilisateurs (Espace Personnel et Sécurité)
Ce module a pour objectif de gérer l'identité, l'authentification et les données personnelles des différents types d'utilisateurs. Il constitue la porte d'entrée de la plateforme et permet de personnaliser l'expérience en fonction du profil, du niveau d'études et des centres d'intérêt de chacun. Il assure également la confidentialité et la sécurité des données sensibles (bulletins, conversations avec les conseillers).
1.1. Architecture générale du module
Accès sécurisé : Protocole HTTPS, chiffrement des mots de passe (hachage fort), protection contre les attaques courantes (brute force, injections).
Progressive Onboarding : Inscription simple et rapide, avec possibilité de compléter le profil progressivement au fil des utilisations.
Granularité des rôles : Distinction claire entre les types d'utilisateurs pour adapter les fonctionnalités et les permissions.
Conformité RGPD : Respect de la vie privée, consentement explicite pour la collecte des données, possibilité de supprimer son compte et ses données.
1.2. Authentification et Inscription
1.2.1. Inscription sécurisée
Création de compte simplifiée :
Inscription par email + mot de passe avec confirmation.
Inscription par numéro de téléphone : pour envoi de notifications SMS.
Inscription via réseaux sociaux (Google, Facebook) pour faciliter l'accès .
Vérification de l'identité :
Email de confirmation avec lien d'activation.
Vérification par SMS pour les comptes sensibles (conseillers, administrateurs).
Choix du rôle principal : À l'inscription, l'utilisateur doit sélectionner son profil principal parmi :
Collégien (avec précision de la classe)
Lycéen (avec précision de la classe et de la série)
Étudiant (avec précision du niveau et de la filière)
Parent (avec possibilité de lier un ou plusieurs enfants)
Apprenti / Jeune en formation professionnelle
Jeune déscolarisé / en situation de décrochage
Jeune en situation de handicap / besoins éducatifs particuliers
Adulte en reconversion professionnelle
Conseiller / Accompagnateur (rôle spécial avec accès back-office)

1.2.2. Connexion sécurisée
Authentification classique : Email/ téléphone + mot de passe.
Gestion des sessions : Maintien de la connexion ("Se souvenir de moi") avec durée de session paramétrable.
Récupération de mot de passe :
Envoi d'un lien de réinitialisation par email.
(Optionnel) Envoi d'un code de réinitialisation par SMS.
Déconnexion automatique : Après une période d'inactivité définie (sécurité renforcée pour les données sensibles).
1.3. Gestion du Profil Utilisateur 
1.3.1. Informations de base (Complétude du profil)
Champs communs :
Photo de profil (optionnelle).
Nom, prénom.
Date de naissance.
Ville / Région de résidence.
Contacts : Email, téléphone (avec préférences de notification).
Champs spécifiques au rôle (affichés dynamiquement selon le profil choisi) :
A. Pour Collégien / Lycéen :
Établissement fréquenté (recherche parmi les Établissements du Module 2).
Classe actuelle (6e, 5e, 4e, 3e, Seconde, Première, Terminale).
Série (pour Première et Terminale : A, C, D, E, etc.).
Options suivies (LV2, Latin, etc.).
Année d'obtention prévue du BEPC / Bac.
B. Pour Étudiant :
Établissement fréquenté (Université, École, Institut).
Filière / Formation suivie (lien vers les Filières du Module 2).
Niveau d'études actuel (Bac+1, Bac+2, etc.).
Année d'obtention prévue du diplôme.
Statut (inscrit en présentiel, à distance, alternance).
C. Pour Parent :
Lien avec un ou plusieurs enfants (déjà inscrits ou à inscrire).
Fonctionnalité "Espace Parent" : Vue consolidée des diagnostics et des échanges de son enfant (avec son consentement).
D. Pour Adulte en reconversion / Jeune déscolarisé :
Dernier diplôme obtenu.
Dernier niveau d'études atteint.
Situation actuelle (en emploi, au chômage, en inactivité).
Domaines d'intérêt professionnel (choix multiples).
Contraintes spécifiques (handicap, disponibilité, mobilité).
1.3.2. Upload et gestion des documents
Bibliothèque de documents : Espace de stockage personnel pour les documents télévisés.
Types de documents acceptés : Bulletins de notes, relevés de notes, diplômes, CV, lettres de motivation.
Fonctionnalités :
Upload (PDF, JPEG, PNG).
Visualisation en ligne.
Suppression et remplacement.
Tagging automatique : Possibilité d'associer un document à un niveau scolaire (ex: Bulletin de Terminale S1").
Confidentialité : Ces documents ne sont visibles que par l'utilisateur et les conseillers (si partagés explicitement via le Module 4).
1.3.3. Favoris et centres d'intérêt
Liste de favoris : L'utilisateur peut ajouter des Séries, Filières, Métiers ou Établissements (Module 2) à une liste personnelle.
Notification sur les favoris : Possibilité d'être alerté si une information change (ex: "Journée portes ouvertes à l'établissement que vous suivez").
Déclaration des centres d'intérêt : Saisie libre ou par mots-clés des domaines qui intéressent l'utilisateur (pour améliorer les recommandations).
1.3.4. Historique des activités
Journal de bord personnel : Enregistrement chronologique des actions de l'utilisateur :
Quiz passés (avec lien vers les résultats).
Analyses académiques réalisées (avec lien vers les résultats).
Fiches consultées dans la Bibliothèque (Module 2).
Échanges avec les conseillers (Module 4).
Vidéos visionnées.
Utilité : Permet à l'utilisateur de retrouver facilement ses recherches précédentes et de suivre l'évolution de sa réflexion.
1.4. Gestion des Comptes Liés et Familles
Cette fonctionnalité est cruciale pour les parents qui souhaitent accompagner plusieurs enfants.
Création d'un compte "Famille" : Un parent peut créer un compte principal et y rattacher des profils "enfants".
Gestion des profils enfants :
Création d'un profil simplifié pour l'enfant (sans email dédié si trop jeune).
Le parent peut suivre l'activité de l'enfant (quiz passés, diagnostics) et recevoir des notifications.
L'enfant peut avoir son propre espace de connexion si souhaité, avec des restrictions de confidentialité adaptées à son âge.
Consentement parental : Pour les mineurs, recueil du consentement parental obligatoire (case à cocher) conforme à la réglementation.

1.5. Paramètres de Confidentialité et Sécurité
Gestion des données personnelles :
Possibilité de télécharger l'intégralité de ses données (export).
Possibilité de supprimer définitivement son compte et toutes ses données (droit à l'oubli).
Préférences de communication :
Choix des notifications souhaitées (email, SMS, notifications in-app).
Abonnement/désabonnement aux newsletters et conseils d'orientation.
Paramètres de confidentialité :
Choix de rendre son profil public (limité) ou privé.
Gestion du partage des données avec les conseillers (accord explicite requis à chaque échange).
1.6. Intégration avec les autres modules
Avec le Module 2 (Bibliothèque) :
Les favoris ajoutés depuis les fiches sont sauvegardés dans le profil.
L'historique des consultations alimente le Journal de bord".
Avec le Module 3 (Diagnostic - Quiz et Analyse) :
Le rôle sélectionné dans le profil détermine le parcours de quiz proposé.
Les résultats des diagnostics sont automatiquement sauvegardés dans l'historique.
Les notes saisies dans l'analyse académique sont stockées et peuvent être réutilisées pour un nouveau diagnostic.
Avec le Module 4 (Accompagnement) :
L'identité de l'utilisateur est automatiquement communiquée au conseiller lorsqu'il pose une question.
L'historique des échanges est consultable dans le profil.
Avec le Module 5 (Administration) :
Les administrateurs peuvent gérer les comptes (suspension, suppression) en cas de non-respect des conditions d'utilisation.
1.7. Spécificités techniques à noter pour les développeurs
Système de rôles flexible : Privilégier une architecture permettant à un utilisateur d'avoir plusieurs rôles (ex: un étudiant peut aussi être un jeune en situation de handicap).
Gestion des âges : Implémenter des règles métier basées sur l'âge (ex: un utilisateur de moins de 15 ans ne peut pas être "Adulte en reconversion").
Scalabilité : Prévoir que le nombre d'utilisateurs puisse croître rapidement (notamment en période d'orientation scolaire).




2. Module Exploration des Formations et Métiers (La Bibliothèque Centrale)
Ce module constitue la bibliothèque centrale et la mémoire vive de la plateforme. Il a pour objectif de cartographier l'ensemble du paysage éducatif et professionnel togolais à travers un catalogue de fiches interconnectées, enrichies de contenus multimédia (vidéos explicatives) et de textes structurés (résumés et paragraphes détaillés).
L'accès à ce module est public (sans authentification) pour maximiser la diffusion de l'information, mais l'historique de consultation peut être sauvegardé pour les utilisateurs connectés.
2.1. Architecture de la base de connaissances
Le module est structuré autour de quatre types de fiches principales, formant un graphe de connaissances cohérent :
Fiches "Séries et Spécialités" : Couvre le secondaire (collège, lycée) avec les spécificités togolaises (ex: Séries A, C, D, seconde, première, terminale).
Fiches "Filières et Formations" : Couvre le supérieur (BTS, DUT, Licences, Masters, Écoles spécialisées, formations professionnelles).
Fiches "Métiers" : Décrit les réalités du marché du travail au Togo.
Fiches "Établissements" : Répertorie les écoles, universités et centres de formation (publics/privés) sur le territoire.
2.2. Accessibilité et Navigation
Accès Public : L'intégralité du catalogue est consultable sans création de compte, garantissant un accès universel à l'information.
Moteur de recherche global : Barre de recherche unique permettant d'interroger les quatre types de fiches simultanément.
Navigation interconnectée (Liens sémantiques) : Chaque fiche doit pouvoir lister les fiches liées.
Exemple : Sur la fiche "Métier d'Architecte", on trouve la liste des "Filières" qui y mènent (ex: Licence Génie Civil) et les Établissements qui les proposent.
Filtrage multicritères : Permettre de filtrer les listes par zone géographique (région), par type d'établissement (public/privé), ou par niveau d'études.
2.3. Structure commune enrichie pour chaque type de fiche
Chaque fiche dispose désormais d'une structure à trois niveaux de lecture pour s'adapter à tous les publics et tous les besoins d'information :
Niveau 1 : "En bref" (Résumé ultra-simple)
Un texte court et percutant (3 à 5 lignes maximum) pour comprendre l'essentiel en 30 secondes.
Public cible : Élèves pressés, première découverte, mobile.
Niveau 2 : "Comprendre en vidéo" (Contenu multimédia)
Une vidéo explicative de 3 à 5 minutes présentant le sujet de manière dynamique et pédagogique (interviews, schémas, témoignages).
Public cible : Jeunes qui préfèrent l'apprentissage visuel et auditif, complément au texte.
Niveau 3 : "Pour aller plus loin" (Paragraphes explicatifs détaillés)
Des sections de texte structurées avec des titres, permettant d'approfondir chaque aspect du sujet.
Public cible : Parents, élèves en phase de recherche intensive, conseillers, curieux.
2.4. Détail des quatre types de fiches 
2.4.1. Fiche "Séries et Spécialités" (Parcours secondaire)
Objectif : Aider les collégiens et lycéens à choisir leur orientation avant le Bac.
Contenu structuré :
[Niveau 1] En bref : "La série C, c'est pour ceux qui aiment les maths et la physique. Elle ouvre les portes des études scientifiques à l'université."
[Niveau 2] Comprendre en vidéo : "Tout savoir sur la série C en 3 minutes" (lien vidéo intégré).
[Niveau 3] Pour aller plus loin :
Présentation générale : Un paragraphe détaillant l'histoire et la place de cette série dans le système éducatif togolais.
Programme détaillé : Plusieurs paragraphes listant et expliquant les principales matières enseignées, les coefficients, et les horaires hebdomadaires.
Profil de l'élève idéal : Un paragraphe décrivant les qualités, les centres d'intérêt et les compétences nécessaires pour réussir dans cette série.
Débouchés naturels : Un paragraphe expliquant les parcours possibles après cette série, avec une liste des Filières universitaires ou Écoles accessibles (Liens vers les fiches correspondantes).
Témoignages et conseils : Paragraphes optionnels avec des citations d'anciens élèves ou de professeurs.
2.4.2. Fiche "Filières et Formations" (Parcours supérieur)
Objectif : Décrire précisément un cursus d'études supérieures.
Contenu structuré :
[Niveau 1] En bref : "Le DUT Génie Logiciel est une formation de 2 ans pour apprendre à créer des sites web et des applications. Idéal pour travailler dans le numérique."
[Niveau 2] Comprendre en vidéo : "Journée type en DUT Génie Logiciel à l'Université de Lomé" (lien vidéo intégré).
[Niveau 3] Pour aller plus loin :
Présentation de la formation : Un paragraphe détaillant les objectifs pédagogiques et le cadre général de la formation.
Conditions d'admission : Un paragraphe expliquant les prérequis (niveau Bac, Séries recommandées, procédure de sélection sur dossier ou concours).
Programme pédagogique : Plusieurs paragraphes détaillant les semestres, les unités d'enseignement (UE), les matières principales, les projets tutorés et les stages obligatoires.
Compétences acquises : Un paragraphe listant les compétences techniques et transversales développées pendant la formation.
Poursuites d'études possibles : Un paragraphe décrivant les passerelles vers les Licences professionnelles, Masters ou Écoles spécialisées.
Débouchés professionnels : Un paragraphe détaillant les secteurs d'activité et les métiers accessibles (Liens vers fiches métiers), avec des précisions sur le marché de l'emploi au Togo.
Établissements proposant cette formation : Liste descriptive des Établissements (Liens vers fiches établissements).
2.4.3. Fiche "Métiers" (Réalité professionnelle)
Objectif : Donner une vision concrète et locale d'un métier.
Contenu structuré :
[Niveau 1] En bref : "L'architecte dessine et conçoit des bâtiments (maisons, écoles, immeubles). Il doit être créatif et bon en maths."
[Niveau 2] Comprendre en vidéo : "Rencontre avec Koffi, architecte à Lomé : son parcours, son quotidien" (lien vidéo intégré).
[Niveau 3] Pour aller plus loin :
Présentation du métier : Un paragraphe décrivant la profession, son importance et son évolution dans le contexte togolais.
Missions principales : Plusieurs paragraphes détaillant les activités quotidiennes, les types de projets, les responsabilités.
Compétences et qualités requises : Un paragraphe sur les hard skills (maîtrise des logiciels, dessin technique) et les soft skills (créativité, rigueur, relation client).
Conditions de travail : Un paragraphe décrivant l'environnement (cabinet, entreprise, indépendant), les horaires, les déplacements éventuels.
Parcours pour y accéder : Un paragraphe détaillant les Filières de formation recommandées (Liens vers fiches filières), les diplômes requis et les concours éventuels.
Débouchés et évolutions au Togo : Un paragraphe analysant la demande sur le marché local, les possibilités de carrière et l'évolution vers des postes à responsabilités.
Témoignage approfondi : Transcription ou extraits longs de l'interview du professionnel.
2.4.4. Fiche "Établissements" (Catalogue des lieux de formation)
Objectif : Centraliser les informations pratiques sur les lieux de formation.
Contenu structuré :
[Niveau 1] En bref : "L'Institut National de la Jeunesse et des Sports (INJS) forme les futurs éducateurs sportifs et professeurs de sport au Togo. Il est situé à Lomé."
[Niveau 2] Comprendre en vidéo : Visite guidée du campus de l'INJS : installations, cours, vie étudiante" (lien vidéo intégré).
[Niveau 3] Pour aller plus loin :
Présentation générale : Un paragraphe sur l'histoire, la réputation et les spécificités de l'établissement.
Localisation et accès : Un paragraphe détaillant l'adresse, les moyens de transport pour s'y rendre, et une carte interactive intégrée.
Infrastructures et vie étudiante : Plusieurs paragraphes décrivant les bibliothèques, laboratoires, installations sportives, hébergements, restauration et associations étudiantes.
Offre de formation : Un paragraphe listant et décrivant brièvement les différentes Filières proposées (Liens vers fiches filières), avec les spécialités éventuelles.
Modalités pratiques : Plusieurs paragraphes détaillant la procédure d'inscription, les frais de scolarité (si publics), les bourses disponibles, les contacts administratifs.
Débouchés et réseau des anciens : Un paragraphe sur la réputation de l'établissement auprès des employeurs et les opportunités de réseautage.
2.5. Intégration avec les autres modules
Ce module n'est pas un silo ; il est au cœur du système et interagit avec les autres fonctionnalités :
Depuis le Module Diagnostic (Quiz ou Analyse de notes) :
Action : L'utilisateur finit un quiz ou son bulletin est analysé.
Résultat : La plateforme affiche "Votre profil correspond aux Métiers suivants..." ou "Vous devriez explorer la Filière ...".
Lien : Clic sur le résultat → redirige vers la fiche correspondante dans la Bibliothèque Centrale (avec ses trois niveaux d'information).
Depuis le Module Vidéothèque :
Action : L'utilisateur regarde une vidéo explicative sur une filière ou un métier.
Résultat : Un encart en fin de vidéo propose : "Lire la fiche détaillée de cette formation" ou "Voir les établissements qui proposent ce cursus".
Lien : Clic → redirige vers la section "Pour aller plus loin" de la fiche correspondante.
Depuis l'Espace Personnel :
Action : L'utilisateur connecté consulte son historique ou sa liste de favoris.
Résultat : Il voit "Vous avez consulté la fiche Métier de Développeur Web" ou "Vos favoris".
Lien : Clic pour y retourner directement et lire les paragraphes détaillés ou revisionner la vidéo.

3. Module Diagnostic d'Orientation 
Ce module est le moteur intelligent de la plateforme. Il a pour objectif de générer des recommandations personnalisées de filières, de formations et de métiers en croisant deux sources de données distinctes : les aspirations personnelles (issues d'un quiz psychométrique) et les performances académiques (issues de l'analyse des résultats scolaires).
L'architecture est divisée en deux sous-modules complémentaires, accessibles séparément ou de manière combinée pour un diagnostic encore plus précis.
3.1. Architecture générale du module diagnostic
Accès conditionnel : Accessible à tous les utilisateurs connectés (pour sauvegarder l'historique des diagnostics).
Parcours utilisateur typique :
L'utilisateur peut choisir de faire uniquement le Quiz d'Orientation (pour une première idée).
OU il peut renseigner ses notes dans l'analyse Académique (pour une approche plus concrète).
OU il peut combiner les deux pour obtenir des recommandations croisées plus fiables (ex: "Vous aimez le social et vous avez de bonnes notes en SVT ? Découvrez les carrières de la santé").
Moteur de règles contextualisées : Les algorithmes de suggestion doivent intégrer les spécificités du système éducatif togolais (coefficients, séries, passerelles entre BTS et Université, etc.).
3.2. Quiz d'Orientation (Basé sur les aspirations)
Ce module propose une séquence de questions interactives conçues spécifiquement pour le contexte togolais. Il permet de cerner le profil, les intérêts, les compétences douces et les contraintes réelles de chaque jeune.
3.2.1. Fonctionnalités d’orientation
Moteur de quiz dynamique : Les questions s'adaptent en temps réel en fonction des réponses précédentes.
Personnalisation par profil : Le parcours de questions diffère selon la situation de l'utilisateur (déclaré lors de l'inscription ou au début du quiz).
Rapport de personnalité : À la fin du quiz, génération d'un profil type (ex: "Profil Créatif", "Profil Technique", "Profil Social", "Profil Méthodique").
Suggestions automatiques : Génération d'une liste de Filières et de Métiers correspondant au profil, avec des liens directs vers la Bibliothèque Centrale (Module 2).
3.2.2. Arbre de décision par profil
Le quiz doit proposer des branches différentes. Voici trois exemples de parcours distincts :
A. Parcours "Nouveau Bachelier": Je viens d'avoir le Bac, que faire après ?
Objectif : Aider à choisir une filière dans le supérieur.
Questions typiques :
"Quelle était ta série au bac ?" (Liste déroulante : A, C, D, E, etc.)
"Quelles étaient tes matières préférées ?" (Choix multiples : Maths, Français, SVT, Histoire-Géo, etc.)
"Préfères-tu travailler en intérieur (bureau, labo) ou en extérieur (terrain, chantier) ?"
"Es-tu prêt à quitter ta ville pour étudier ?" (Oui/Non/Peut-être)
"Quel type de carrière te fait rêver ?" (Fonctionnaire, Entrepreneur, Salarié en entreprise, Freelance)
"As-tu des contraintes financières pour tes études ?" (Oui, je cherche des formations peu coûteuses / Non)
B. Parcours "Réorientation Universitaire" :J'ai commencé des études mais je veux changer
Objectif : Aider à trouver une voie plus adaptée après un premier échec ou une insatisfaction.
Questions typiques :
"Quelle filière as-tu commencée ? Pourquoi souhaites-tu changer ?" (Texte libre ou choix multiples : "Mauvaise orientation", "Trop difficile", "Pas débouchés", "Pas intéressant")
"Souhaites-tu rester dans le même domaine ou changer complètement ?"
"Acceptes-tu de perdre une année en changeant de filière ?" (Oui/Non)
"Es-tu intéressé par des formations plus courtes et professionnalisantes (BTS, DUT, Licence Pro) ?"
"Quel est ton niveau actuel d'études ?" (Bac+1, Bac+2, etc.)
C. Parcours "Nouveau Bepcien" :Je viens d'avoir le BEPC, quelle série choisir ?
Objectif : Aider à choisir entre la Seconde générale ou une voie technique/professionnelle.
Questions typiques :
"Quelles étaient tes notes au BEPC ?" (Optionnel : "Tu peux les renseigner plus tard dans l'Analyse Académique")
"Préfères-tu apprendre par cœur ou comprendre par le raisonnement ?"
"Aimes-tu travailler de tes mains (bricoler, dessiner, cuisiner) ?"
"As-tu déjà une idée de métier ?" (Si oui, proposer des séries adaptées à ce métier)
"Souhaites-tu arrêter les études rapidement pour travailler, ou poursuivre longtemps ?"
3.3. Analyse Académique :Basée sur les performances réelles
Ce module permet à l'utilisateur de renseigner ses résultats scolaires réels pour affiner les recommandations de la plateforme. Contrairement au quiz qui repose sur les goûts, ce module se base sur les performances objectives pour valider ou nuancer les suggestions d'orientation.
3.3.1. Fonctionnalités macroscopiques
Saisie manuelle des notes : Interface simple pour entrer les notes par matière, avec coefficient (adapté au système togolais).
Upload de bulletins : Reconnaissance automatique des notes à partir d'un scan/photo de bulletin (OCR) pour éviter la saisie manuelle (optionnel mais fortement recommandé).
Moteur d'analyse comparative : Compare les notes de l'élève aux moyennes de la classe, aux seuils de réussite habituels, et aux prérequis des différentes filières.
Validation des pistes d'orientation : Prend une liste de souhaits (ex: "Je veux faire Médecine") et indique la probabilité de réussite en fonction des notes.
3.3.2. Fonctionnalités microscopiques
A. Import et structuration des données
Saisie par niveau : Possibilité de renseigner les notes de la 6e à la Terminale, ou uniquement les deux dernières années.
Gestion des coefficients : Interface permettant d'ajuster les coefficients par matière selon la classe et la série.
Visualisation graphique : Génération automatique d'un graphique en radar ou en barres montrant les points forts et les points faibles de l'élève (ex: "Vous êtes fort en Sciences, moyen en Lettres").
B. Moteur de correspondance académique
Seuils d'admission : La base de données doit contenir, pour chaque Filière du Module 2, les profils de notes recommandés ou exigés (ex: "Pour entrer en Licence de Médecine, il faut généralement une moyenne de 14/20 en SVT et en Maths au Bac").
Génération de recommandations :
À partir des notes, la plateforme propose des Filières où l'utilisateur a le plus de chances de réussir.
Exemple : "Avec 16 en Maths et 12 en Français, vous êtes fait pour les filières scientifiques (Série C, D, etc.). Découvrez le DUT Génie Civil."
Alerte de vigilance : Si l'utilisateur exprime un souhait (ex: "Je veux faire Psychologie") mais que ses notes sont faibles dans les matières clés, une notification apparaît : "Attention, cette filière demande un bon niveau en SVT et en Philosophie. Voici des alternatives proches de ton profil."
C. Croisement avec le Quiz (Mode combiné)
Fusion des données : Si l'utilisateur a fait le quiz ET renseigné ses notes, un onglet "Recommandations croisées" apparaît.
Algorithme pondéré : Les suggestions sont classées selon un score combinant :
La correspondance avec les goûts (Quiz).
La probabilité de réussite académique (Notes).
Affichage clair : Pour chaque suggestion, un indicateur visuel montre :
 "Correspond à tes goûts"
 "Correspond à ton niveau scolaire"
 "Correspond aux deux" (recommandation prioritaire)


3.4. Livrables et affichage des résultats
Quel que soit le parcours choisi (Quiz seul, Analyse seule, ou Combiné), les résultats sont présentés de manière claire et exploitable :
Nuage de recommandations : Affichage visuel (sous forme de cartes ou de bulles) des filières et métiers suggérés.
Filtrage des résultats : Possibilité de filtrer les suggestions par :
Type (Filière, Métier, Établissement).
Durée d'études (court, long).
Localisation (Lomé, Kara, autres régions).
Liens vers la Bibliothèque : Chaque suggestion est cliquable et renvoie vers la fiche détaillée correspondante dans le Module 2 (avec résumé, vidéo et paragraphes).
Export/Sauvegarde : Possibilité d'enregistrer les résultats dans l'Espace Personnel, de les imprimer ou de les partager avec un parent ou un conseiller.
3.5. Intégration avec les autres modules
Avec le Module 2 (Bibliothèque) : Les suggestions sont des liens directs vers les fiches détaillées.
Avec le Module 4 (Accompagnement) : Un bouton "Parler à un conseiller de ces résultats" permet d'envoyer automatiquement le diagnostic à un conseiller pour un échange personnalisé.
Avec le Module 1 (Profil) : L'historique des diagnostics (quiz passés, analyses de notes) est sauvegardé et consultable.

4. Module Interaction et Accompagnement: Conseil personnalisé
Ce module a pour objectif de créer un lien humain entre les utilisateurs et des spécialistes de l'orientation, de la formation et de l'insertion professionnelle. Il permet de répondre aux questions spécifiques, de lever les doutes, d'affiner les projets et d'offrir un soutien moral et pratique à ceux qui en ont le plus besoin (jeunes en décrochage, adultes en reconversion, personnes en situation de handicap).
Il s'articule autour de trois niveaux d'accompagnement progressifs : l'auto-documentation (FAQ) , l'échange asynchrone (messagerie) , et l'échange synchrone (rendez-vous) .
4.1. Architecture générale du module
Accès conditionnel :
La FAQ est accessible à tous, même sans compte.
La messagerie et la prise de rendez-vous sont réservées aux utilisateurs connectés (pour assurer un suivi personnalisé et sécurisé).
Traçabilité des échanges : Toutes les interactions (questions, réponses, comptes-rendus de rendez-vous) sont sauvegardées dans l'historique de l'utilisateur (Module 1) et dans le dossier de l'utilisateur côté conseiller (Module 5).
Confidentialité et bienveillance : Les échanges sont strictement confidentiels. Les conseillers sont formés à l'écoute et à la non-discrimination.
Temps de réponse engagé : Un engagement de réponse sous 48h ouvrées pour les questions posées via la messagerie (à définir selon les moyens humains).
4.2. FAQ Dynamique et Collaborative (Auto-documentation)
Ce sous-module permet de répondre aux questions les plus fréquentes sans solliciter un conseiller, tout en enrichissant la base de connaissances de la plateforme.
4.2.1. Fonctionnalités macroscopiques
Base de connaissances évolutive : Une bibliothèque de questions/réponses classées par thèmes.
Moteur de recherche sémantique : L'utilisateur tape sa question en langage naturel, la FAQ lui propose les réponses les plus pertinentes.
Catégorisation claire :
Questions sur les études (secondaire, supérieur).
Questions sur les métiers.
Questions sur les procédures (inscriptions, bourses, orientation).
Questions sur des situations particulières (handicap, reconversion, décrochage).
4.2.2. Fonctionnalités microscopiques
Suggestion automatique : Si la question de l'utilisateur correspond à une fiche du Module 2, un encart propose : "Vous devriez aussi consulter la fiche sur [Métier/Filière]".
"Cette réponse vous a-t-elle aidé ?" : Boutons de feedback pour améliorer la pertinence des réponses.
Proposition de nouvelles questions : Si l'utilisateur ne trouve pas sa réponse, un bouton "Je n'ai pas trouvé ma réponse" le redirige vers la messagerie pour poser sa question à un conseiller. La question peut ensuite être anonymisée et ajoutée à la FAQ si elle est jugée pertinente.





4.3. Système de Messagerie / Contact (Échange asynchrone)
Ce sous-module permet aux utilisateurs de poser des questions personnalisées et d'obtenir une réponse écrite d'un conseiller, sans contrainte d'horaire.
4.3.1. Fonctionnalités macroscopiques (côté utilisateur)
Formulaire de contact intelligent :
Objet de la demande (liste déroulante : Orientation, Formation, Métier, Procédure, Situation particulière, Autre).
Champ de texte libre pour la question (avec compteur de caractères).
Pièce jointe : Possibilité de joindre un document (bulletins, CV, etc.) pour contextualiser la question.
Contexte automatique : Le niveau d'études et le profil de l'utilisateur (renseignés dans le Module 1) sont automatiquement transmis au conseiller avec la question (gain de temps).
Suivi des échanges :
Interface de messagerie simple (type boîte de réception) listant toutes les questions posées et les réponses apportées.
Statut visible pour l'utilisateur : "Envoyée", "Consultée par un conseiller", "Répondue".
Notification (email ou SMS) à la réception d'une nouvelle réponse.
4.3.2. Fonctionnalités microscopiques (côté conseiller - back-office)
File d'attente des questions : Interface dédiée (Module 5) listant les questions en attente, avec priorisation possible (ex: les questions urgentes ou les situations de décrochage peuvent être marquées comme prioritaires).
Vue contextuelle : Le conseiller voit le profil complet de l'utilisateur (rôle, niveau, historique des diagnostics, documents partagés) pour personnaliser sa réponse.
Outils de réponse :
Éditeur de texte riche (gras, italique, listes).
Insertion de liens vers des fiches du Module 2 (ex: "Comme expliqué dans la fiche sur le DUT Génie Civil...").
Réponses pré-enregistrées (pour les questions récurrentes) à personnaliser avant envoi.
Transfert possible à un autre conseiller plus spécialisé.
Archivage et traçabilité : Toutes les réponses sont sauvegardées et associées au dossier de l'utilisateur.
4.4. Prise de Rendez-vous et Accompagnement Approfondi (Échange synchrone)
Ce sous-module permet de passer à un niveau d'accompagnement supérieur pour les situations complexes nécessitant un échange en direct (téléphone, visio, ou physique).
4.4.1. Fonctionnalités macroscopiques
Demande de rendez-vous : L'utilisateur peut solliciter un rendez-vous avec un spécialiste.
Agenda partagé : Visualisation des créneaux disponibles pour chaque type de conseiller.
Multi-canaux : Proposition de différents modes de rendez-vous :
Téléphone (l'utilisateur indique son numéro).
Visioconférence (lien généré automatiquement).
Physique (dans les locaux d'un partenaire, si applicable).
4.4.2. Fonctionnalités microscopiques
Formulaire de préparation : Avant de valider le rendez-vous, l'utilisateur renseigne brièvement :
L'objet du rendez-vous (liste déroulante : "Validation de mon projet", "Aide à la constitution de dossier", "Situation de décrochage", "Conseils pour une reconversion").
Un résumé de sa situation (texte libre).
Les documents déjà partagés ou à partager.
Confirmation et rappels :
Confirmation immédiate par email/SMS avec les coordonnées du rendez-vous.
Rappel automatique 24h avant le rendez-vous.
Possibilité d'annuler ou de reporter (avec un délai minimum).
Compte-rendu post-rendez-vous :
Le conseiller peut rédiger un compte-rendu succinct (accessible uniquement par l'utilisateur et les autres conseillers autorisés).
L'utilisateur peut recevoir une synthèse écrite des conseils prodigués.
Un questionnaire de satisfaction peut être envoyé après le rendez-vous.
4.5. Espace d'Échange Spécifique (Situations Particulières)
Ce sous-module est dédié aux publics ayant des besoins spécifiques, nécessitant une approche et des conseillers formés.
4.5.1. Accompagnement pour les jeunes en situation de handicap
Conseillers spécialisés : Possibilité de demander un rendez-vous avec un conseiller formé à l'orientation des jeunes en situation de handicap.
Ressources dédiées : Dans la FAQ, une catégorie spécifique sur les aides, les aménagements, les formations accessibles.
Partage de documents spécifiques : Possibilité de joindre des documents médicaux (de manière sécurisée et confidentielle) si nécessaire pour l'accompagnement.
4.5.2. Accompagnement pour les jeunes en décrochage ou déscolarisés
Approche bienveillante : Formulaire de contact avec un ton adapté, rassurant.
Orientation vers les dispositifs existants : Les conseillers doivent connaître les structures d'aide (associations, missions locales, etc.) pour orienter au mieux.
Suivi renforcé : Possibilité pour un conseiller de proposer un suivi régulier (plusieurs rendez-vous) plutôt qu'un contact ponctuel.
4.5.3. Accompagnement pour les adultes en reconversion
Focus sur les droits et financements : Les conseillers dédiés sont formés aux dispositifs de formation continue, CPF, etc.
Bilan de compétences simplifié : Proposition d'un questionnaire préliminaire (intégré au Module 3) pour préparer l'échange.
Lien avec le monde professionnel : Si possible, mise en relation avec des entreprises ou des formations pour adultes.
4.6. Intégration avec les autres modules
Avec le Module 1 (Profil) :
L'historique des échanges (messages et rendez-vous) est visible dans le journal de bord de l'utilisateur.
Le profil de l'utilisateur est automatiquement transmis au conseiller lors d'une demande (gain de temps, pas besoin de tout réexpliquer).
Avec le Module 2 (Bibliothèque) :
Les conseillers peuvent insérer des liens directs vers des fiches (Séries, Filières, Métiers, Établissements) dans leurs réponses.
L'utilisateur peut, depuis une fiche, cliquer sur "Poser une question sur ce métier" pour pré-remplir un message.
Avec le Module 3 (Diagnostic) :
L'utilisateur peut, depuis ses résultats de quiz ou d'analyse académique, cliquer sur "Parler de ces résultats à un conseiller". Le message est alors pré-rempli avec un résumé du diagnostic.
Le conseiller voit les diagnostics de l'utilisateur pour mieux comprendre son parcours.
Avec le Module 5 (Administration) :
Les administrateurs gèrent les comptes des conseillers (création, suspension, rôles).
Tableau de bord de suivi : nombre de questions en attente, délais de réponse moyens, satisfaction des utilisateurs.
Statistiques sur les thèmes les plus abordés pour améliorer la FAQ et le contenu du Module 2.
4.7. Spécificités techniques à noter pour les développeurs
Système de tickets : Implémenter un système de gestion de tickets (questions) avec statuts (ouvert, en cours, résolu, fermé).
Notifications en temps réel : Utiliser WebSockets ou des services de notification push pour alerter les conseillers d'une nouvelle question et les utilisateurs d'une nouvelle réponse.
Sécurité des échanges : Chiffrement des messages en base de données. Pour les échanges très sensibles (handicap, données médicales), prévoir un niveau de confidentialité renforcé.
Intégration visio : Utiliser une API de visioconférence (Jitsi, Zoom, Google Meet) pour générer automatiquement des liens de rendez-vous.
Gestion d'agenda : Intégration avec un système de calendrier (type CalDAV) pour synchroniser les disponibilités des conseillers et éviter les doubles réservations.
5. Module Administration et Modération (Back-office)
Ce module est l'interface de pilotage de la plateforme, réservée aux équipes internes (administrateurs, gestionnaires de contenu, modérateurs, responsables des conseillers). Il a pour objectif de garantir la qualité, la pertinence, la fraîcheur et la conformité de l'ensemble des informations et des interactions présentes sur Activ EDUCATION.
Il s'articule autour de quatre grandes missions : la gestion des contenus (Module 2), la gestion des utilisateurs et conseillers (Module 1 et 4), la modération des interactions (Module 4), et le pilotage stratégique (statistiques et rapports).
5.1. Architecture générale du module
Accès ultra-sécurisé :
Authentification renforcée (double facteur obligatoire).
Connexion uniquement depuis des IP autorisées (optionnel selon hébergement).
Journalisation exhaustive de toutes les actions (logs) pour traçabilité (qui a fait quoi, quand).
Granularité des rôles et permissions : Tous les administrateurs n'ont pas les mêmes droits. Distinction claire entre :
Super Administrateur : Accès total, gestion des comptes administrateurs, paramétrages système.
Gestionnaire de contenu : Peut créer/modifier/supprimer des fiches (Séries, Filières, Métiers, Établissements) et des vidéos.
Responsable des conseillers : Gère les comptes des conseillers, suit leur activité, consulte les échanges.
Conseiller (vue back-office) : Accès à la file d'attente des questions et à la gestion de ses rendez-vous.
Modérateur : Valide les questions avant publication en FAQ, modère les commentaires éventuels.
Interface unifiée mais personnalisée : Tableau de bord unique avec des widgets et des menus adaptés au rôle de chaque utilisateur.
5.2. Gestion des Contenus : Alimentation de la Bibliothèque Centrale
Ce sous-module permet de créer, modifier et supprimer l'ensemble des fiches du Module 2, ainsi que les contenus multimédias associés.
5.2.1. Gestion des fiches (Séries, Filières, Métiers, Établissements)
Interface de création/édition :
Formulaire structuré reprenant exactement les champs définis dans le Module 2 (Résumé, Vidéo, Paragraphes détaillés).
Éditeur WYSIWYG (What You See Is What You Get) pour les paragraphes, permettant de mettre en forme le texte (gras, listes, liens internes).
Gestion des médias : Upload d'images (illustrations, photos d'établissements), intégration de vidéos (YouTube, Vimeo, ou upload direct).
Gestion des liens internes : Interface intuitive pour lier une fiche à d'autres fiches (ex: lier un Métier aux Filières correspondantes).
Workflow de validation :
Possibilité de créer une fiche en "brouillon" avant de la publier.
Option de planification de la publication (ex: pour une rentrée scolaire).
Historique des modifications : Qui a modifié quoi et quand ? Possibilité de revenir à une version antérieure.
Gestion des traductions : Si la plateforme est multilingue (français, langues locales), interface pour gérer les versions traduites des fiches.
Import/Export en masse :
Possibilité d'importer des fiches via un fichier CSV/Excel (pour un déploiement initial rapide).
Export des fiches au format CSV/PDF pour sauvegarde ou analyse externe.
5.2.2. Gestion des vidéos (Vidéothèque)
Bibliothèque vidéo centrale : Toutes les vidéos uploadées ou référencées sont centralisées.
Upload et transcodage : Si upload direct, prévoir un transcodage automatique pour une diffusion optimale sur tous les appareils.
Association aux fiches : Interface pour lier une vidéo à une ou plusieurs fiches (ex: une vidéo "Journée portes ouvertes" peut être liée à un Établissement et à plusieurs Filières).
Statistiques vues : Nombre de vues par vidéo, temps de visionnage moyen (pour évaluer l'engagement).
5.2.3. Gestion des quiz (Module 3.1)
Constructeur de quiz visuel :
Interface "drag & drop" pour créer des questions et organiser les arbres de décision.
Types de questions supportées : choix unique, choix multiples, échelle de Likert, texte libre.
Gestion des conditions : "Si l'utilisateur répond X à la question Y, alors lui poser la question Z".
Gestion des parcours par profil : Interface pour définir les questions spécifiques à chaque parcours (Nouveau Bachelier, Réorientation, Nouveau Bepcien).
Association des résultats : Pour chaque combinaison de réponses, possibilité d'associer des suggestions de Filières/Métiers (liens vers les fiches).
5.3. Gestion des Utilisateurs et Conseillers
Ce sous-module permet de gérer les comptes des utilisateurs finaux et des conseillers.
5.3.1. Gestion des utilisateurs finaux
Liste complète des utilisateurs : Filtrable par rôle, date d'inscription, niveau d'études, etc.
Vue détaillée d'un utilisateur : Accès à son profil, ses documents, son historique (quiz, analyses, échanges, favoris). Respect de la confidentialité : les administrateurs n'ont accès qu'aux données nécessaires à leur mission.
Actions possibles :
Suspension temporaire d'un compte (en cas de non-respect des CGU).
Suppression définitive d'un compte (à la demande de l'utilisateur ou après décision).
Envoi d'une notification (email) à un utilisateur ou à un groupe d'utilisateurs.
Gestion des signalements : Si un utilisateur signale un abus (message inapproprié, etc.), interface pour gérer ces signalements.
5.3.2. Gestion des conseillers (Ressources humaines)
Création de comptes conseillers : Interface dédiée pour créer un compte "conseiller" avec choix des permissions.
Gestion des profils conseillers :
Spécialités (handicap, reconversion, décrochage, etc.).
Disponibilités (pour l'agenda de rendez-vous).
Charge de travail maximale (nombre de questions/rendez-vous par jour).
Suivi de l'activité des conseillers :
Tableau de bord individuel : nombre de questions traitées, délai moyen de réponse, satisfaction des utilisateurs.
File d'attente globale : Vue d'ensemble des questions en attente et des conseillers disponibles.
5.4. Modération des Interactions
Ce sous-module garantit la qualité et la bienveillance des échanges sur la plateforme.
5.4.1. Modération de la FAQ collaborative
File d'attente des propositions : Liste des questions posées par les utilisateurs via "Je n'ai pas trouvé ma réponse" et proposées pour intégrer la FAQ.
Actions :
Accepter la question et y associer une réponse (création d'une nouvelle entrée FAQ).
Refuser la question (trop spécifique, hors sujet) avec possibilité d'envoyer un message explicatif à l'utilisateur.
Modifier la question pour la rendre plus générique avant publication.
5.4.2. Modération des échanges
Alertes automatiques : Détection de mots-clés inappropriés dans les messages (insultes, harcèlement) et mise en quarantaine du message pour modération.
Signalements utilisateurs : Si un utilisateur signale une réponse d'un conseiller comme inappropriée, interface pour le responsable des conseillers pour examiner l'échange et prendre les mesures nécessaires.

5.5.Pilotage et Statistiques 
Ce sous-module fournit les indicateurs clés pour piloter la plateforme et mesurer son impact.
5.5.1. Statistiques d'audience
Fréquentation globale : Nombre de visiteurs uniques, pages vues, temps passé sur le site.
Fiches les plus consultées : Top des Séries, Filières, Métiers, Établissements (pour identifier les centres d'intérêt des jeunes).
Provenance des utilisateurs : Répartition par ville/région.
Appareils utilisés : Mobile vs Desktop (pour optimiser l'expérience).
5.5.2. Statistiques des diagnostics (Module 3)
Quiz : Nombre de quiz complétés, répartition par parcours (Bac, BEPC, Réorientation), profils les plus fréquents.
Analyse académique : Nombre d'analyses réalisées, matières fortes/faibles les plus fréquentes.
Recommandations : Top des filières et métiers suggérés par l'algorithme.
5.5.3. Statistiques de l'accompagnement (Module 4)
FAQ : Questions les plus recherchées sans résultat (pour créer de nouvelles entrées), taux de satisfaction.
Messagerie : Nombre de questions posées, délai moyen de réponse, taux de résolution.
Rendez-vous : Nombre de rendez-vous pris, par type (téléphone, visio, physique), taux de présence/annulation.
5.5.4. Rapports exportables
Génération de rapports PDF/Excel pour les réunions d'équipe ou les rapports aux financeurs/partenaires.
Possibilité de programmer des rapports automatiques (ex: rapport mensuel envoyé par email).
5.6. Paramétrages Système
Ce sous-module permet de configurer les aspects techniques et fonctionnels de la plateforme.
Gestion des rôles et permissions : Créer de nouveaux rôles, modifier les droits associés à chaque rôle.
Paramètres des notifications : Configurer les templates d'emails et de SMS envoyés automatiquement (confirmation d'inscription, rappel de rendez-vous, etc.).
Gestion des filtres de modération : Configurer la liste des mots-clés à surveiller.
Sauvegardes : Planification des sauvegardes automatiques de la base de données et des fichiers.
Logs d'audit : Consultation exhaustive de toutes les actions effectuées dans le back-office (pour traçabilité et sécurité).
5.7. Intégration avec les autres modules
Avec le Module 1 (Profil) : Gestion des comptes utilisateurs, consultation des profils.
Avec le Module 2 (Bibliothèque) : Création et mise à jour de l'ensemble des fiches.
Avec le Module 3 (Diagnostic) : Création et modification des quiz, consultation des statistiques de diagnostic.
Avec le Module 4 (Accompagnement) : Gestion des conseillers, modération des échanges, consultation des statistiques d'accompagnement.
5.8. Spécificités techniques à noter pour les développeurs
Interface responsive : Le back-office doit être utilisable sur tablette (les gestionnaires de contenu peuvent être amenés à travailler en déplacement).
Performance : Les listes (utilisateurs, fiches) doivent être paginées et filtrables pour éviter des temps de chargement trop longs.
Sécurité renforcée :
2FA obligatoire.
Timeout de session court.
Journalisation exhaustive (logs) conservée longtemps.
API interne : Le back-office doit consommer les mêmes APIs que le front-end, garantissant une cohérence des données.
Mode maintenance : Possibilité de basculer la plateforme en "mode maintenance" (accessible uniquement aux admins) le temps d'une mise à jour importante.


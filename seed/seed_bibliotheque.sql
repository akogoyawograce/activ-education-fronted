-- seed_bibliotheque.sql — FAQ, séries, filières, métiers, établissements
BEGIN;

-- FAQ
INSERT INTO entrees_faq (tracking_id, question, reponse, categorie, est_publie, nb_vues, created_by, created_at) VALUES
  (gen_random_uuid(), 'Comment créer un compte élève ?', 'Téléchargez l application et suivez les étapes d inscription.', 'Inscription', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Qu est-ce que le test RIASEC ?', 'Questionnaire d orientation selon 6 profils : Réaliste, Investigateur, Artistique, Social, Entreprenant, Conventionnel.', 'Orientation', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Comment prendre rendez-vous avec un conseiller ?', 'Allez dans Messages, sélectionnez un conseiller et proposez un créneau.', 'Rendez-vous', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Les résultats sont-ils fiables ?', 'Le RIASEC est un outil reconnu. Il ne remplace pas un conseiller.', 'Orientation', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Comment modifier mon profil ?', 'Rendez-vous dans la section Profil.', 'Compte', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Puis-je passer le test plusieurs fois ?', 'Oui, l historique est conservé.', 'Diagnostic', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Comment sont protégées mes données ?', 'Stockage sécurisé, jamais partagées sans consentement.', 'Confidentialité', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Que faire si j oublie mon mot de passe ?', 'Utilisez Mot de passe oublié sur l écran de connexion.', 'Connexion', true, 0, 'seed', '2026-05-23 10:40:18');

-- Séries
INSERT INTO fiches (tracking_id, titre, resume, contenu, est_publie, nb_consultations, created_by, created_at) VALUES
  (gen_random_uuid(), 'Série C (Mathématiques)', 'Scientifique axée sur les mathématiques.', 'La série C prépare aux études en maths, physique, informatique, ingénierie.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Série D (Sciences expérimentales)', 'Scientifique axée sur les SVT.', 'La série D prépare aux carrières en santé, agronomie, environnement.', true, 0, 'seed', '2026-05-23 10:40:18');

INSERT INTO fiches_serie (id, code, duree)
SELECT id, 'C', '3 ans' FROM fiches WHERE titre LIKE 'Série C%';
INSERT INTO fiches_serie (id, code, duree)
SELECT id, 'D', '3 ans' FROM fiches WHERE titre LIKE 'Série D%';

-- Filières
INSERT INTO fiches (tracking_id, titre, resume, contenu, est_publie, nb_consultations, created_by, created_at) VALUES
  (gen_random_uuid(), 'Médecine Générale', 'Devenir médecin.', 'Études de 7 à 10 ans. Stages hospitaliers, spécialisation.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Génie Informatique', 'Développer des solutions informatiques.', 'Formation d ingénieurs en systèmes complexes.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Droit des Affaires', 'Conseiller juridique.', 'Prépare aux carrières juridiques en entreprise.', true, 0, 'seed', '2026-05-23 10:40:18');

INSERT INTO fiches_filiere (id, duree, niveau_requis, conditions_admission, programme, debouches_metiers, domaine) VALUES
  ((SELECT id FROM fiches WHERE titre = 'Médecine Générale'), '7-10 ans', 'Bac+1 validé', 'Concours après 1ère année.', 'PACES/LAS, stages.', 'Médecin généraliste, spécialiste.', 'Santé'),
  ((SELECT id FROM fiches WHERE titre = 'Génie Informatique'), '5 ans', 'Bac C, D, E', 'Concours ou dossier.', 'Algo, prog, BD, réseaux, IA.', 'Développeur, DevOps, architecte.', 'Technologie'),
  ((SELECT id FROM fiches WHERE titre = 'Droit des Affaires'), '5 ans', 'Bac toutes séries', 'Dossier.', 'Droit civil, commercial, fiscal.', 'Juriste, avocat, notaire.', 'Droit');

-- Métiers
INSERT INTO fiches (tracking_id, titre, resume, contenu, est_publie, nb_consultations, created_by, created_at) VALUES
  (gen_random_uuid(), 'Médecin Généraliste', 'Soigner et diagnostiquer.', 'Premier recours pour les soins de santé.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Développeur Full-Stack', 'Créer des applications.', 'Conçoit et développe frontend et backend.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Avocat', 'Défendre et conseiller.', 'Conseille et défend devant les tribunaux.', true, 0, 'seed', '2026-05-23 10:40:18');

INSERT INTO fiches_metier (id, secteur, missions, competences, formations_acces, debouches_togo, fourchette_salaire) VALUES
  ((SELECT id FROM fiches WHERE titre = 'Médecin Généraliste'), 'Santé', 'Diagnostiquer, prescrire, suivre.', 'Analyse, rigueur, écoute.', 'Doctorat en Médecine.', 'Hôpitaux, cliniques.', '300 000 - 800 000 FCFA'),
  ((SELECT id FROM fiches WHERE titre = 'Développeur Full-Stack'), 'Technologie', 'Concevoir, développer, déployer.', 'JS/TS, React, Node, SQL, Git.', 'Licence/Master Informatique.', 'Startups, entreprises.', '200 000 - 600 000 FCFA'),
  ((SELECT id FROM fiches WHERE titre = 'Avocat'), 'Justice', 'Conseiller, rédiger, plaider.', 'Expression, argumentation.', 'Master Droit + CAPA.', 'Cabinets, services juridiques.', '250 000 - 700 000 FCFA');

-- Établissements
INSERT INTO fiches (tracking_id, titre, resume, contenu, est_publie, nb_consultations, created_by, created_at) VALUES
  (gen_random_uuid(), 'Université de Lomé (UL)', 'Plus grande université publique du Togo.', 'Formations en sciences, droit, économie, lettres, médecine.', true, 0, 'seed', '2026-05-23 10:40:18'),
  (gen_random_uuid(), 'Institut Africain d Informatique (IAI)', 'École spécialisée en informatique.', 'Licence/Master en Génie Informatique, Data Science.', true, 0, 'seed', '2026-05-23 10:40:18');

INSERT INTO fiches_etablissement (id, ville, type_etablissement, site_web, adresse, contacts, offre_formation, est_public) VALUES
  ((SELECT id FROM fiches WHERE titre = 'Université de Lomé (UL)'), 'Lomé', 'UNIVERSITE', 'https://univ-lome.tg', 'BP: 1515 Lomé, Togo', '+228 22 25 38 45', 'Sciences, Droit, Économie, Lettres, Médecine', true),
  ((SELECT id FROM fiches WHERE titre = 'Institut Africain d Informatique (IAI)'), 'Lomé', 'ECOLE_SUPERIEURE', 'https://iaitogo.tg', 'Lomé, Togo', '+228 22 21 47 57', 'Génie Informatique, Sécurité, Data Science', true);

-- Relations ManyToMany
INSERT INTO serie_filiere (serie_id, filiere_id)
SELECT s.id, f.id FROM fiches_serie s, fiches_filiere f
WHERE s.id = (SELECT id FROM fiches WHERE titre LIKE 'Série C%') AND f.id = (SELECT id FROM fiches WHERE titre = 'Médecine Générale')
ON CONFLICT DO NOTHING;
INSERT INTO serie_filiere (serie_id, filiere_id)
SELECT s.id, f.id FROM fiches_serie s, fiches_filiere f
WHERE s.id = (SELECT id FROM fiches WHERE titre LIKE 'Série D%') AND f.id = (SELECT id FROM fiches WHERE titre = 'Médecine Générale')
ON CONFLICT DO NOTHING;
INSERT INTO serie_filiere (serie_id, filiere_id)
SELECT s.id, f.id FROM fiches_serie s, fiches_filiere f
WHERE s.id = (SELECT id FROM fiches WHERE titre LIKE 'Série C%') AND f.id = (SELECT id FROM fiches WHERE titre = 'Génie Informatique')
ON CONFLICT DO NOTHING;

INSERT INTO filiere_metier (metier_id, filiere_id)
SELECT m.id, f.id FROM fiches_metier m, fiches_filiere f
WHERE m.id = (SELECT id FROM fiches WHERE titre = 'Médecin Généraliste') AND f.id = (SELECT id FROM fiches WHERE titre = 'Médecine Générale')
ON CONFLICT DO NOTHING;
INSERT INTO filiere_metier (metier_id, filiere_id)
SELECT m.id, f.id FROM fiches_metier m, fiches_filiere f
WHERE m.id = (SELECT id FROM fiches WHERE titre = 'Développeur Full-Stack') AND f.id = (SELECT id FROM fiches WHERE titre = 'Génie Informatique')
ON CONFLICT DO NOTHING;
INSERT INTO filiere_metier (metier_id, filiere_id)
SELECT m.id, f.id FROM fiches_metier m, fiches_filiere f
WHERE m.id = (SELECT id FROM fiches WHERE titre = 'Avocat') AND f.id = (SELECT id FROM fiches WHERE titre = 'Droit des Affaires')
ON CONFLICT DO NOTHING;

INSERT INTO etablissement_filiere (etablissement_id, filiere_id)
SELECT e.id, f.id FROM fiches_etablissement e, fiches_filiere f
WHERE e.id = (SELECT id FROM fiches WHERE titre = 'Université de Lomé (UL)') AND f.id = (SELECT id FROM fiches WHERE titre = 'Médecine Générale')
ON CONFLICT DO NOTHING;
INSERT INTO etablissement_filiere (etablissement_id, filiere_id)
SELECT e.id, f.id FROM fiches_etablissement e, fiches_filiere f
WHERE e.id = (SELECT id FROM fiches WHERE titre = 'Institut Africain d Informatique (IAI)') AND f.id = (SELECT id FROM fiches WHERE titre = 'Génie Informatique')
ON CONFLICT DO NOTHING;

COMMIT;

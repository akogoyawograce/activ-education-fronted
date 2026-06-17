-- seed_users.sql — Utilisateurs, profils, rôles
-- Mot de passe admin (tous sauf eleve1/parent1) : admin123
-- Mot de passe eleve1 : pass123
-- Mot de passe parent1 : parent123
BEGIN;

INSERT INTO utilisateurs (tracking_id, email, mot_de_passe_hash, nom, prenom, telephone, est_actif, date_inscription, created_by, created_at) VALUES
  (gen_random_uuid(), 'superadmin@activ-education.com', '$2b$10$9IsOcmYbgLMVAe0q5fU5VOXTxDYh1za285JuL6h53idCpwGAXi5xG', 'Admin', 'Super', '+22890000001', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'moderateur@activ-education.com', '$2b$10$9IsOcmYbgLMVAe0q5fU5VOXTxDYh1za285JuL6h53idCpwGAXi5xG', 'Modérateur', 'Admin', '+22890000002', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'gestionnaire@activ-education.com', '$2b$10$9IsOcmYbgLMVAe0q5fU5VOXTxDYh1za285JuL6h53idCpwGAXi5xG', 'Gestionnaire', 'Admin', '+22890000003', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'conseiller1@activ-education.com', '$2b$10$9IsOcmYbgLMVAe0q5fU5VOXTxDYh1za285JuL6h53idCpwGAXi5xG', 'Kodjo', 'Jean', '+22890000004', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'conseiller2@activ-education.com', '$2b$10$9IsOcmYbgLMVAe0q5fU5VOXTxDYh1za285JuL6h53idCpwGAXi5xG', 'Lawson', 'Marie', '+22890000005', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'eleve1@activ-education.com', '$2b$10$1QU2PN6Ie8RWj92QwcWFc.JDYilf.Un3VZzNAKZv6ov.ba9pIpWiK', 'Koffi', 'Akossiwa', '+22890000006', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53'),
  (gen_random_uuid(), 'parent1@activ-education.com', '$2b$10$oQgIupN31YEiZdgxFz/KD.HxDv5pFQ/4WY3Jd7i9YM5xWoCpbzzKK', 'Koffi', 'Mensah', '+22890000007', true, '2026-05-23 10:40:53', 'seed', '2026-05-23 10:40:53');

INSERT INTO administrateurs (id, niveau_acces) VALUES
  ((SELECT id FROM utilisateurs WHERE email = 'superadmin@activ-education.com'), 'SUPER_ADMIN'),
  ((SELECT id FROM utilisateurs WHERE email = 'moderateur@activ-education.com'), 'MODERATEUR'),
  ((SELECT id FROM utilisateurs WHERE email = 'gestionnaire@activ-education.com'), 'GESTIONNAIRE_CONSEILLER');

INSERT INTO conseillers (id, specialites, biographie, qualifications, annees_experience, charge_travail) VALUES
  ((SELECT id FROM utilisateurs WHERE email = 'conseiller1@activ-education.com'), 'Orientation scolaire, Psychologie', 'Conseiller spécialisé dans l orientation des lycéens.', 'Master en Psychologie de l Éducation', 5, 0),
  ((SELECT id FROM utilisateurs WHERE email = 'conseiller2@activ-education.com'), 'Orientation professionnelle, Bilan de compétences', 'Experte en reconversion professionnelle.', 'Master en Conseil en Orientation', 8, 0);

INSERT INTO eleves (id, niveau, type_apprenant, etablissement, filiere) VALUES
  ((SELECT id FROM utilisateurs WHERE email = 'eleve1@activ-education.com'), 'Terminale', 'LYCEEN', 'Lycée de Tokoin', 'Série C');

INSERT INTO parents (id) VALUES ((SELECT id FROM utilisateurs WHERE email = 'parent1@activ-education.com'));

INSERT INTO utilisateur_roles (utilisateur_id, role_id)
SELECT u.id, r.id FROM utilisateurs u, roles r
WHERE u.email = ANY(ARRAY['superadmin@activ-education.com','moderateur@activ-education.com','gestionnaire@activ-education.com']) AND r.nom = 'ROLE_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO utilisateur_roles (utilisateur_id, role_id)
SELECT u.id, r.id FROM utilisateurs u, roles r
WHERE u.email = ANY(ARRAY['conseiller1@activ-education.com','conseiller2@activ-education.com']) AND r.nom = 'ROLE_CONSEILLER'
ON CONFLICT DO NOTHING;

INSERT INTO utilisateur_roles (utilisateur_id, role_id)
SELECT u.id, r.id FROM utilisateurs u, roles r
WHERE u.email = 'eleve1@activ-education.com' AND r.nom = 'ROLE_ELEVE'
ON CONFLICT DO NOTHING;

INSERT INTO utilisateur_roles (utilisateur_id, role_id)
SELECT u.id, r.id FROM utilisateurs u, roles r
WHERE u.email = 'parent1@activ-education.com' AND r.nom = 'ROLE_PARENT'
ON CONFLICT DO NOTHING;

INSERT INTO parent_enfants (parent_id, eleve_id)
SELECT p.id, e.id FROM parents p, eleves e
WHERE p.id = (SELECT id FROM utilisateurs WHERE email = 'parent1@activ-education.com')
  AND e.id = (SELECT id FROM utilisateurs WHERE email = 'eleve1@activ-education.com')
ON CONFLICT DO NOTHING;

COMMIT;

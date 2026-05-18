# API Endpoints (Swagger)

Ci-dessous la liste exhaustive des 179 endpoints exposés par l'API Backend, extraite directement de la documentation OpenAPI (Swagger).

## Seuils d'admission
- **[POST]** `/api/v1/seuils-admission` : Créer un seuil d'admission
- **[GET]** `/api/v1/seuils-admission/{trackingId}` : Récupérer un seuil par UUID
- **[PUT]** `/api/v1/seuils-admission/{trackingId}` : Modifier un seuil d'admission
- **[DELETE]** `/api/v1/seuils-admission/{trackingId}` : Supprimer un seuil d'admission

## Matrices de Score
- **[GET]** `/api/v1/score-matrices` : Lister toutes les matrices (paginé)
- **[POST]** `/api/v1/score-matrices` : Créer une matrice de score
- **[GET]** `/api/v1/score-matrices/{trackingId}` : Récupérer une matrice par UUID
- **[PUT]** `/api/v1/score-matrices/{trackingId}` : Modifier une matrice de score
- **[DELETE]** `/api/v1/score-matrices/{trackingId}` : Supprimer une matrice de score

## Quiz et Diagnostic
- **[GET]** `/api/v1/quiz` : Lister les quiz actifs (paginé)
- **[POST]** `/api/v1/quiz` : Créer un quiz
- **[GET]** `/api/v1/quiz/{trackingId}` : Récupérer un quiz par UUID
- **[PUT]** `/api/v1/quiz/{trackingId}` : Modifier un quiz
- **[DELETE]** `/api/v1/quiz/{trackingId}` : Désactiver un quiz (soft-delete)
- **[GET]** `/api/v1/quiz/{quizTrackingId}/questions` : Lister toutes les questions d'un quiz
- **[POST]** `/api/v1/quiz/{quizTrackingId}/questions` : Ajouter une question à un quiz
- **[GET]** `/api/v1/questions/{trackingId}` : Récupérer une question par UUID
- **[PUT]** `/api/v1/questions/{trackingId}` : Modifier une question
- **[DELETE]** `/api/v1/questions/{trackingId}` : Supprimer une question
- **[GET]** `/api/v1/questions/{questionTrackingId}/reponses` : Lister toutes les options de réponse d'une question
- **[POST]** `/api/v1/questions/{questionTrackingId}/reponses` : Ajouter une option de réponse à une question
- **[GET]** `/api/v1/reponses/{trackingId}` : Récupérer une option de réponse par son UUID
- **[PUT]** `/api/v1/reponses/{trackingId}` : Modifier une option de réponse
- **[DELETE]** `/api/v1/reponses/{trackingId}` : Supprimer une option de réponse
- **[POST]** `/api/v1/resultats-diagnostic` : Enregistrer un résultat de diagnostic
- **[GET]** `/api/v1/resultats-diagnostic/{trackingId}` : Récupérer un résultat par UUID
- **[DELETE]** `/api/v1/resultats-diagnostic/{trackingId}` : Supprimer un résultat

## Utilisateurs - Élèves
- **[GET]** `/api/v1/eleves` : Lister tous les élèves actifs (paginé)
- **[POST]** `/api/v1/eleves` : Inscrire un nouvel élève
- **[GET]** `/api/v1/eleves/{trackingId}` : Récupérer un élève par son UUID
- **[PUT]** `/api/v1/eleves/{trackingId}` : Modifier le profil d'un élève
- **[DELETE]** `/api/v1/eleves/{trackingId}` : Désactiver un compte élève
- **[GET]** `/api/v1/eleves/{eleveTrackingId}/notes` : Lister toutes les notes d'un élève
- **[POST]** `/api/v1/eleves/{eleveTrackingId}/notes` : Ajouter une note à un élève
- **[GET]** `/api/v1/eleves/{eleveTrackingId}/notes/pagine` : Lister les notes d'un élève (paginé)
- **[GET]** `/api/v1/eleves/{eleveTrackingId}/resultats-diagnostic` : Historique paginé des résultats de diagnostic d'un élève
- **[GET]** `/api/v1/eleves/{eleveTrackingId}/resultats-diagnostic/dernier` : Dernier résultat d'un élève pour un quiz donné

## Utilisateurs - Conseillers
- **[GET]** `/api/v1/conseillers` : Lister tous les conseillers actifs (paginé)
- **[POST]** `/api/v1/conseillers` : Créer un nouveau conseiller
- **[GET]** `/api/v1/conseillers/disponibles` : Lister les conseillers disponibles
- **[GET]** `/api/v1/conseillers/{trackingId}` : Récupérer un conseiller par UUID
- **[PUT]** `/api/v1/conseillers/{trackingId}` : Modifier le profil d'un conseiller
- **[DELETE]** `/api/v1/conseillers/{trackingId}` : Désactiver un compte conseiller
- **[GET]** `/api/v1/conseillers/{conseillerTrackingId}/disponibilites` : Lister tous les créneaux d'un conseiller
- **[POST]** `/api/v1/conseillers/{conseillerTrackingId}/disponibilites` : Ajouter un créneau de disponibilité
- **[GET]** `/api/v1/conseillers/{conseillerTrackingId}/disponibilites/pagine` : Créneaux paginés d'un conseiller
- **[GET]** `/api/v1/conseillers/{conseillerTrackingId}/disponibilites/jour/{jourSemaine}` : Créneaux d'un conseiller pour un jour donné

## Utilisateurs - Parents
- **[GET]** `/api/v1/parents` : Lister tous les parents actifs (paginé)
- **[POST]** `/api/v1/parents` : Créer un nouveau parent
- **[GET]** `/api/v1/parents/{trackingId}` : Récupérer un parent par UUID
- **[PUT]** `/api/v1/parents/{trackingId}` : Modifier le profil d'un parent
- **[DELETE]** `/api/v1/parents/{trackingId}` : Désactiver un compte parent
- **[GET]** `/api/v1/parents/par-eleve/{eleveTrackingId}` : Récupérer les parents d'un élève
- **[POST]** `/api/v1/parents/{trackingId}/enfants/{eleveTrackingId}` : Rattacher un élève à un parent
- **[DELETE]** `/api/v1/parents/{trackingId}/enfants/{eleveTrackingId}` : Retirer le lien entre un parent et un élève

## Administrateurs
- **[GET]** `/api/v1/administrateurs` : Lister tous les administrateurs actifs (paginé)
- **[POST]** `/api/v1/administrateurs` : Créer un administrateur
- **[GET]** `/api/v1/administrateurs/{trackingId}` : Récupérer un administrateur par UUID
- **[PUT]** `/api/v1/administrateurs/{trackingId}` : Modifier un administrateur
- **[DELETE]** `/api/v1/administrateurs/{trackingId}` : Désactiver un compte administrateur

## Notes
- **[GET]** `/api/v1/notes/{trackingId}` : Récupérer une note par son UUID
- **[PUT]** `/api/v1/notes/{trackingId}` : Modifier une note
- **[DELETE]** `/api/v1/notes/{trackingId}` : Supprimer une note

## Créneaux et Rendez-vous
- **[GET]** `/api/v1/disponibilites/{trackingId}` : Récupérer un créneau par son UUID
- **[PUT]** `/api/v1/disponibilites/{trackingId}` : Modifier un créneau de disponibilité
- **[DELETE]** `/api/v1/disponibilites/{trackingId}` : Supprimer un créneau
- **[POST]** `/api/v1/rendez-vous` : Planifier un rendez-vous
- **[GET]** `/api/v1/rendez-vous/{trackingId}` : Récupérer un rendez-vous par UUID
- **[PUT]** `/api/v1/rendez-vous/{trackingId}` : Modifier un rendez-vous
- **[PATCH]** `/api/v1/rendez-vous/{trackingId}/terminer` : Marquer un rendez-vous comme terminé
- **[PATCH]** `/api/v1/rendez-vous/{trackingId}/annuler` : Annuler un rendez-vous
- **[GET]** `/api/v1/rendez-vous/eleve/{eleveTrackingId}` : Rendez-vous d'un élève
- **[GET]** `/api/v1/rendez-vous/eleve/{eleveTrackingId}/statut/{statut}` : RDV d'un élève filtrés par statut
- **[GET]** `/api/v1/rendez-vous/eleve/{eleveTrackingId}/pagine` : Rendez-vous d'un élève (paginés)
- **[GET]** `/api/v1/rendez-vous/conseiller/{conseillerTrackingId}` : Rendez-vous d'un conseiller
- **[GET]** `/api/v1/rendez-vous/conseiller/{conseillerTrackingId}/statut/{statut}` : RDV d'un conseiller filtrés par statut
- **[GET]** `/api/v1/rendez-vous/conseiller/{conseillerTrackingId}/pagine` : Rendez-vous d'un conseiller (paginés)

## Bibliothèque - Séries
- **[GET]** `/api/v1/bibliotheque/series` : Lister toutes les fiches séries (paginé)
- **[POST]** `/api/v1/bibliotheque/series` : Créer une nouvelle fiche série
- **[GET]** `/api/v1/bibliotheque/series/{trackingId}` : Récupérer une fiche série par son trackingId
- **[PUT]** `/api/v1/bibliotheque/series/{trackingId}` : Modifier une fiche série existante
- **[DELETE]** `/api/v1/bibliotheque/series/{trackingId}` : Supprimer une fiche série
- **[GET]** `/api/v1/bibliotheque/series/recherche` : Rechercher des séries par mot-clé
- **[GET]** `/api/v1/bibliotheque/series/public` : Lister les fiches séries publiques (paginé)
- **[GET]** `/api/v1/bibliotheque/series/non-public` : Lister les fiches séries non publiques (paginé)

## Bibliothèque - Métiers
- **[GET]** `/api/v1/bibliotheque/metiers` : Lister toutes les fiches métiers (paginé)
- **[POST]** `/api/v1/bibliotheque/metiers` : Créer une nouvelle fiche métier (sans médias)
- **[POST]** `/api/v1/bibliotheque/metiers/avec-medias` : Créer une nouvelle fiche métier (avec médias)
- **[GET]** `/api/v1/bibliotheque/metiers/{trackingId}` : Récupérer une fiche métier par son trackingId
- **[PUT]** `/api/v1/bibliotheque/metiers/{trackingId}` : Modifier une fiche métier existante
- **[DELETE]** `/api/v1/bibliotheque/metiers/{trackingId}` : Supprimer une fiche métier
- **[PUT]** `/api/v1/bibliotheque/metiers/{trackingId}/medias` : Remplacer les médias d'une fiche métier
- **[POST]** `/api/v1/bibliotheque/metiers/{trackingId}/medias` : Ajouter des médias à une fiche métier
- **[GET]** `/api/v1/bibliotheque/metiers/secteurs` : Lister tous les secteurs contenant des métiers
- **[GET]** `/api/v1/bibliotheque/metiers/secteur/{secteur}` : Lister les métiers par secteur
- **[GET]** `/api/v1/bibliotheque/metiers/recherche` : Rechercher des métiers par mot-clé
- **[GET]** `/api/v1/bibliotheque/metiers/public` : Lister les fiches métiers publiques (paginé)
- **[GET]** `/api/v1/bibliotheque/metiers/non-public` : Lister les fiches métiers non publiques (paginé)

## Bibliothèque - Filières
- **[GET]** `/api/v1/bibliotheque/filieres` : Lister toutes les fiches filières (paginé)
- **[POST]** `/api/v1/bibliotheque/filieres` : Créer une nouvelle fiche filière (sans médias)
- **[POST]** `/api/v1/bibliotheque/filieres/avec-medias` : Créer une nouvelle fiche filière (avec médias)
- **[GET]** `/api/v1/bibliotheque/filieres/{trackingId}` : Récupérer une fiche filière par son trackingId
- **[PUT]** `/api/v1/bibliotheque/filieres/{trackingId}` : Modifier une fiche filière existante
- **[DELETE]** `/api/v1/bibliotheque/filieres/{trackingId}` : Supprimer une fiche filière
- **[PUT]** `/api/v1/bibliotheque/filieres/{trackingId}/medias` : Remplacer les médias d'une fiche filière
- **[POST]** `/api/v1/bibliotheque/filieres/{trackingId}/medias` : Ajouter des médias à une fiche filière
- **[GET]** `/api/v1/bibliotheque/filieres/recherche` : Rechercher des filières par mot-clé
- **[GET]** `/api/v1/bibliotheque/filieres/public` : Lister les fiches filières publiques (paginé)
- **[GET]** `/api/v1/bibliotheque/filieres/non-public` : Lister les fiches filières non publiques (paginé)
- **[GET]** `/api/v1/bibliotheque/filieres/domaines` : Lister tous les domaines contenant des filières
- **[GET]** `/api/v1/bibliotheque/filieres/domaine/{domaine}` : Lister les filières par domaine
- **[GET]** `/api/v1/filieres/{filiereTrackingId}/seuils-admission` : Seuils d'admission d'une filière

## Bibliothèque - Établissements
- **[GET]** `/api/v1/bibliotheque/etablissements` : Lister toutes les fiches établissements (paginé)
- **[POST]** `/api/v1/bibliotheque/etablissements` : Créer une nouvelle fiche établissement (sans médias)
- **[POST]** `/api/v1/bibliotheque/etablissements/avec-medias` : Créer une nouvelle fiche établissement (avec médias)
- **[GET]** `/api/v1/bibliotheque/etablissements/{trackingId}` : Récupérer une fiche établissement par son trackingId
- **[PUT]** `/api/v1/bibliotheque/etablissements/{trackingId}` : Modifier une fiche établissement existante
- **[DELETE]** `/api/v1/bibliotheque/etablissements/{trackingId}` : Supprimer une fiche établissement
- **[PUT]** `/api/v1/bibliotheque/etablissements/{trackingId}/medias` : Remplacer les médias d'une fiche établissement
- **[POST]** `/api/v1/bibliotheque/etablissements/{trackingId}/medias` : Ajouter des médias à une fiche établissement
- **[GET]** `/api/v1/bibliotheque/etablissements/villes` : Lister toutes les villes contenant des établissements
- **[GET]** `/api/v1/bibliotheque/etablissements/ville/{ville}` : Lister les établissements par ville
- **[GET]** `/api/v1/bibliotheque/etablissements/type/{type}` : Lister les établissements par type
- **[GET]** `/api/v1/bibliotheque/etablissements/recherche` : Rechercher des établissements par mot-clé
- **[GET]** `/api/v1/bibliotheque/etablissements/public` : Lister les fiches établissements publiques (paginé)
- **[GET]** `/api/v1/bibliotheque/etablissements/non-public` : Lister les fiches établissements non publiques (paginé)

## Bibliothèque - FAQ & Favoris
- **[GET]** `/api/v1/bibliotheque/faq` : Lister toutes les entrées FAQ publiées (paginé)
- **[POST]** `/api/v1/bibliotheque/faq` : Créer une nouvelle entrée FAQ
- **[GET]** `/api/v1/bibliotheque/faq/{trackingId}` : Récupérer une entrée FAQ par son trackingId
- **[PUT]** `/api/v1/bibliotheque/faq/{trackingId}` : Modifier une entrée FAQ existante
- **[DELETE]** `/api/v1/bibliotheque/faq/{trackingId}` : Supprimer une entrée FAQ
- **[GET]** `/api/v1/bibliotheque/faq/recherche-ia` : Recherche sémantique + RAG via l'IA Gemini
- **[GET]** `/api/v1/bibliotheque/faq/categories` : Lister toutes les catégories uniques utilisées
- **[GET]** `/api/v1/bibliotheque/faq/categorie/{categorie}` : Lister les entrées FAQ par catégorie
- **[POST]** `/api/v1/bibliotheque/favoris` : Ajouter une fiche aux favoris
- **[GET]** `/api/v1/bibliotheque/favoris/{trackingId}` : Récupérer un favori par son trackingId
- **[DELETE]** `/api/v1/bibliotheque/favoris/{trackingId}` : Supprimer un favori
- **[GET]** `/api/v1/bibliotheque/favoris/utilisateur/{utilisateurTrackingId}` : Lister les favoris d'un utilisateur

## Bibliothèque - Analytics & IA
- **[GET]** `/api/v1/bibliotheque/recherche-fiche-ia/globale` : Recherche sémantique globale via l'IA Gemini
- **[GET]** `/api/v1/bibliotheque/analytics/tendances` : Récupérer la liste des fiches les plus consultées sur les 7 derniers jours
- **[GET]** `/api/v1/bibliotheque/analytics/similaires/{trackingId}` : Récupérer les fiches similaires à une fiche spécifique
- **[GET]** `/api/v1/bibliotheque/analytics/recentes/{utilisateurTrackingId}` : Récupérer la liste des fiches récemment consultées par un utilisateur
- **[GET]** `/api/v1/admin/bibliotheque/recherches-orphelines/frequentes` : Récupérer la liste des recherches qui n'ont rien donné, par ordre de fréquence

## Notifications & Historique d'Utisalisateurs
- **[GET]** `/api/v1/notifications/{trackingId}` : Récupérer une notification par son UUID
- **[DELETE]** `/api/v1/notifications/{trackingId}` : Supprimer une notification
- **[PATCH]** `/api/v1/notifications/{trackingId}/lire` : Marquer une notification comme lue
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications` : Lister toutes les notifications d'un utilisateur
- **[POST]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications` : Envoyer une notification à un utilisateur
- **[PATCH]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications/tout-lire` : Marquer toutes les notifications comme lues
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications/pagine` : Notifications paginées d'un utilisateur
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications/non-lues` : Récupérer les notifications non lues d'un utilisateur
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/notifications/compteur` : Compter les notifications non lues
- **[GET]** `/api/v1/historique/{trackingId}` : Récupérer une entrée d'historique par son UUID
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/historique` : Lister tout l'historique d'un utilisateur
- **[POST]** `/api/v1/utilisateurs/{utilisateurTrackingId}/historique` : Enregistrer une entrée d'historique
- **[DELETE]** `/api/v1/utilisateurs/{utilisateurTrackingId}/historique` : Purger l'historique d'un utilisateur
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/historique/pagine` : Historique paginé d'un utilisateur
- **[GET]** `/api/v1/utilisateurs/{utilisateurTrackingId}/historique/action` : Filtrer l'historique par type d'action

## Messages & Conversations
- **[GET]** `/api/v1/messages/{trackingId}` : Récupérer un message par son UUID
- **[DELETE]** `/api/v1/messages/{trackingId}` : Supprimer un message
- **[GET]** `/api/v1/messages/conversation` : Obtenir la conversation entre deux utilisateurs
- **[PATCH]** `/api/v1/messages/conversation/lire` : Marquer une conversation comme lue
- **[POST]** `/api/v1/utilisateurs/{expediteurTrackingId}/messages` : Envoyer un message
- **[GET]** `/api/v1/utilisateurs/{expediteurTrackingId}/messages/envoyes` : Messages envoyés par un utilisateur (paginés)
- **[GET]** `/api/v1/utilisateurs/{destinataireTrackingId}/messages/recus` : Messages reçus d'un utilisateur (paginés)
- **[GET]** `/api/v1/utilisateurs/{destinataireTrackingId}/messages/non-lus/compteur` : Compter les messages non lus

## Fichiers & Médias
- **[POST]** `/files/upload/{fileType}` : Upload un fichier
- **[POST]** `/files/upload/multiple/{fileType}` : Upload plusieurs fichiers
- **[DELETE]** `/files/{fileType}/{fileName}` : Supprimer un fichier
- **[GET]** `/files/url/{fileType}/{fileName}` : Obtenir l'URL d'un fichier
- **[GET]** `/files/stream/{fileType}/{fileName}` : Streamer un fichier
- **[GET]** `/files/presigned-url/{fileType}/{fileName}` : Générer une URL pré-signée
- **[GET]** `/files/pdf/thumbnail/{fileName}` : Générer un thumbnail PDF
- **[GET]** `/files/pdf/text/{fileName}` : Extraire le texte d'un PDF
- **[GET]** `/files/metadata/{fileType}/{fileName}` : Obtenir les métadonnées d'un fichier
- **[GET]** `/files/list/{fileType}` : Lister les fichiers
- **[GET]** `/files/exists/{fileType}/{fileName}` : Vérifier l'existence d'un fichier
- **[GET]** `/files/download/{fileType}/{fileName}` : Télécharger un fichier

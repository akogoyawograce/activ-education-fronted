# Mission : Enrichir les fiches établissements du Togo dans l'application Activ Education

Tu es assistant spécialiste des établissements d'enseignement supérieur au Togo. Tu dois enrichir **165 fiches établissements** déjà créées dans l'application Activ Education avec les informations manquantes suivantes.

L'API contient actuellement 338 entrées, dont 165 uniques (les 173 restantes sont des doublons).

## Répartition par type

- **ECOLE_SUPERIEURE** : 219
- **UNIVERSITE** : 34
- **CENTRE_FORMATION_PROFESSIONNELLE** : 32
- **AUTRE** : 26
- **GRANDE_ECOLE** : 17
- **LYCEE** : 10

## Données à fournir pour CHAQUE établissement

Pour chaque établissement, fournis au format structuré suivant :

### [Nom de l'établissement]
- **Description enrichie** (2-3 phrases, attractive pour un lycéen, qui présente les atouts de l'établissement)
- **Ville** (vérifier/corriger si nécessaire)
- **Adresse complète**
- **Site web officiel** (URL complète https://...)
- **Contacts** (téléphone, email)
- **Offre de formation détaillée** (liste des filières, diplômes proposés : Licence, Master, Doctorat, BTS, etc.)
- **Filières associées** (parmi la liste ci-dessous, lesquelles correspondent)
- **Type** (UNIVERSITE, GRANDE_ECOLE, ECOLE_SUPERIEURE, etc.)
- **Niveau** (Licence, Master, Doctorat, etc.)
- **Est public ?** (Oui/Non)
- **Image / Logo** (propose une requête de recherche d'image pour trouver le logo ou une photo de l'établissement sur Google Images)
- **Réseaux sociaux** (pages Facebook, LinkedIn, etc. si existants)
- **Particularités** (réputation, classement, partenariats internationaux, etc.)


## Liste des filières disponibles dans l'application

1. Agronomie
2. Anglais
3. Arts Plastiques
4. Banque et Assurance
5. Biologie
6. Communication et Journalisme
7. Droit
8. Enseignement Primaire
9. Finance et Comptabilité
10. Gestion des Entreprises
11. Génie Civil
12. Génie Informatique
13. Génie Mécanique
14. Génie Électrique
15. Géographie
16. Histoire
17. Informatique
18. Lettres Modernes
19. Mathématiques Appliquées
20. Médecine
21. Odontologie
22. Pharmacie
23. Physique-Chimie
24. Psychologie
25. Sciences Environnementales
26. Sciences Forestières
27. Sciences Infirmières
28. Sciences Politiques
29. Sciences de l'Éducation
30. Sociologie
31. Tourisme et Hôtellerie
32. Économie

## Liste des établissements à enrichir

Total : **165 établissements**

### 1. American Institute of Commonwealth (AIC-Togo)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé proposant des formations aux standards internationaux, programmes bilingues.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes bilingues en Management, Informatique, Finance, Relations Internationales.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 2. CEFIP
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation et d'insertion professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Métiers du Tertiaire, Services, Commerce.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 3. Centre de Formation Bancaire du Togo (CFBT)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé spécialisé dans la formation aux métiers de la banque et de la finance.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Banque, Finance, Assurance, Microfinance. Programmes certifiants.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 4. Centre de Formation et de Perfectionnement (CFP)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Bureautique, comptabilité, informatique
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 5. Centre de Formation Supérieure SartenMode (CFS-SartenMode)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation supérieure en mode et couture.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Stylisme, Couture, Mode, Design de Mode.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 6. Centre de Perfectionnement aux Techniques Économiques et Commerciales (CPTEC)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de perfectionnement en techniques économiques et commerciales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Techniques Commerciales, Gestion, Comptabilité, Marketing.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 7. Centre Informatique de Formation et d'Orientation Professionnelle (CIFOP)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation en informatique et orientation professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique, Bureautique, Orientation Professionnelle.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 8. Centre International de Recherche et d'Étude des Langues (CIREL-VB)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Centre public spécialisé dans l'enseignement et la recherche en langues, situé à Village du Bénin. Rattaché à l'Université de Lomé.
- **Ville** : Lomé
- **Adresse** : Village du Bénin
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 56 74
- **Offre formation** : Formation en langues et linguistique. Programmes de Licence et Master en Anglais, Allemand, Espagnol, Français Langue Étrangère, Linguistique Appliquée. Recherche en didactique des langues et linguistique africaine.
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : Communication et Journalisme

### 9. Centre Omnithérapeutique Africain (COA)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation en médecine et thérapies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Médecine Traditionnelle, Phytothérapie, Bien-être, Santé Naturelle.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 10. CIB-INTA
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation en informatique, bureautique et nouvelles technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique, Bureautique, Maintenance, Réseaux, Développement Web.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 11. DEFITECH Togo
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en technologies et innovation.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Développement Web et Mobile, Design Digital, Marketing Digital, Infographie.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 12. Ecole Supérieure de l'Aéronautique et des Technologies Togo (ESAT-TOGO)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée dans les métiers de l'aéronautique et des hautes technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Aéronautique, Maintenance Aéronautique, Logistique Aérienne, Technologies Avancées.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 13. ESAM
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École supérieure privée des affaires et de management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Marketing, Finance, Comptabilité, Ressources Humaines.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 14. ESFP-FIMAC
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École supérieure privée de formation professionnelle FIMAC.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Comptabilité, Gestion, Marketing.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 15. ESTECA
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École supérieure privée de technologie et de commerce.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Commerce, Gestion, Informatique de Gestion, Marketing.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 16. Faculté de Théologie des Assemblées de Dieu (FATAD)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Faculté privée de théologie.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Théologie, Sciences Bibliques, Pastorale, Éducation Chrétienne.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 17. FORMATEC
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation technique.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations techniques en Informatique, Électronique, Maintenance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 18. Global University School of Science and Technology (GUST)
- **Type** : UNIVERSITE
- **Description actuelle** : Université privée spécialisée en sciences, technologies et innovation.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences et Technologies: Informatique, Intelligence Artificielle, Data Science, Biotechnologies, Sciences de l'Ingénieur.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 19. Groupe IHERIS
- **Type** : UNIVERSITE
- **Description actuelle** : Groupe d'enseignement supérieur privé proposant des formations en management, technologies et sciences.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Licences et Masters en Management, Informatique, Finance, Marketing, Communication, Ressources Humaines, Hôtellerie et Tourisme.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme, Tourisme et Hôtellerie

### 20. Haute Technologie d'Informatique et Bureautique Atlantis (HTIB-ATLANTIS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de hautes technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique, Bureautique, Technologies de l'Information.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 21. Haute École de Technologies et de Management des Lacs (HETML)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Haute école privée de technologies et management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Technologies, Management, Informatique, Gestion.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 22. Heritage International University Institute (HIUI)
- **Type** : UNIVERSITE
- **Description actuelle** : Institut universitaire privé international.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes internationaux en Management, Finance, Informatique, Commerce.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 23. Hôtel École Avenida
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : École hôtelière privée.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Hôtellerie, Restauration, Tourisme, Arts Culinaires.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 24. Hôtel École Concordia
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : École hôtelière privée formant aux métiers de l'hôtellerie, de la restauration et du tourisme.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Hôtellerie, Restauration, Cuisine, Services Hôteliers, Tourisme.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 25. Hôtel École La Savoureuse (HES)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : École hôtelière privée.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Hôtellerie, Restauration, Cuisine, Pâtisserie, Services Hôteliers.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 26. Institut Africain d'Administration et d'Études Commerciales (IAEC)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Institut privé spécialisé en administration des affaires et études commerciales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 00 00
- **Offre formation** : Formations en Administration des Affaires, Commerce International, Marketing, Gestion des Ressources Humaines, Finance, Comptabilité. Licence (3 ans), Master (2 ans).
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 27. Institut Africain de Développement Sanitaire et Social (IADSS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation dans les domaines sanitaire et social.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Santé Publique, Développement Social, Assistance Sociale, Gestion Sanitaire.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 28. Institut Africain des Sciences, des Technologies et des Métiers (IASTM)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de sciences et technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences, Technologies, Métiers Techniques, Informatique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 29. Institut Africain Le Leadership
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en leadership.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Leadership, Management, Développement Personnel, Communication.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 30. Institut Consortium Saint John Révélation
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Théologie, Management, Développement Personnel.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 31. Institut d'Ingénierie Hôtelière et du Tourisme (IIHT)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé d'hôtellerie et tourisme.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Hôtellerie, Tourisme, Restauration, Gestion Hôtelière.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 32. Institut de Formation aux Métiers de la Sécurité Sociale (IFOMESS-Kara)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation aux métiers de la sécurité sociale, situé à Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sécurité Sociale, Protection Sociale, Gestion des Organismes Sociaux.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 33. Institut de Formation aux Normes et Technologies de l'Informatique (IFNTI-Sokodé)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en informatique situé à Sokodé.
- **Ville** : Sokodé
- **Adresse** : Sokodé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique, Réseaux, Développement, Maintenance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 34. Institut de Formation en Actuariat et Finance (IFA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en actuariat et finance.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Actuariat, Finance Quantitative, Statistique, Gestion des Risques.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 35. Institut de Formation en Gestion (IFG)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Management, Ressources Humaines, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 36. Institut de Formation et de Recherche pour le Développement Durable (IFORDD)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de recherche et formation en développement durable.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Développement Durable, Environnement, Écologie, Gestion des Ressources.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Géographie, Sciences Environnementales

### 37. Institut de Formation Technique et Supérieure (IFTS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation technique et professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations techniques en Informatique, Gestion, Comptabilité, Secrétariat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 38. Institut de Génie Biomédical de Lomé (IGEB)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé spécialisé en génie biomédical.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Génie Biomédical, Maintenance Hospitalière, Équipements Médicaux.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 39. Institut de Recherche en Sciences de la Santé (ISOR-TOGO)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de recherche et formation en santé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences de la Santé, Soins Infirmiers, Paramédical.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 40. Institut de Recherche et de Formation en Développement Local (IRFODEL)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de recherche et formation en développement local.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Développement Local, Décentralisation, Gouvernance Locale, Projets.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 41. Institut de Technologie IPNET IT
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de technologies de l'information.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Réseaux, Sécurité Informatique, Développement, Administration Système.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 42. Institut des Arts et Technologies de l'Image (IATI)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé d'arts et technologies de l'image.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Arts Visuels, Photographie, Vidéo, Design Graphique, Multimédia.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 43. Institut des Hautes Études de Relations Internationales et Stratégiques (IHERIS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de relations internationales et stratégie.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Relations Internationales, Stratégie, Diplomatie, Sécurité Internationale, Géopolitique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 44. Institut des Sciences Technologies et Arts (ISTA-Kara)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de sciences, technologies et arts situé à Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences, Technologies, Arts, Design.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 45. Institut des Technologies Avancées (JUMAU-ITA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de technologies avancées.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Technologies Avancées, Informatique, Robotique, Intelligence Artificielle.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 46. Institut ELATSA
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation supérieure.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Lettres, Langues, Traduction, Communication.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 47. Institut IAI-TOGO
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé d'intelligence artificielle et d'informatique.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique, Intelligence Artificielle, Data Science, Développement.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 48. Institut National de la Jeunesse et des Sports (INJS)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Formation aux métiers du sport.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 40 38
- **Offre formation** : Éducation physique, coaching sportif
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 49. Institut Polytechnique des Bâtiments et des Travaux Publics (IPBTP)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation aux métiers du BTP.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Bâtiment, Travaux Publics, Topographie, Génie Civil, Architecture.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 50. Institut Régional d'Enseignement Supérieur et de Recherche en Développement Culturel
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé dédié à la recherche et l'enseignement en développement culturel.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Développement Culturel, Gestion du Patrimoine, Industries Culturelles, Tourisme Culturel.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie, Histoire

### 51. Institut Supérieur Agata Carelli (ISAC)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Paramédical, Puériculture, Soins Infirmiers.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 52. Institut Supérieur d'Administration, des Sciences Économiques et de Gestion (ISAGES)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé d'administration et économie.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Administration, Sciences Économiques, Gestion des Entreprises.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 53. Institut Supérieur d'Études Générales (SUP IEG)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé d'études générales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences, Lettres, Droit, Économie.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 54. Institut Supérieur de Bâtiment Ayin'a (ISBA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation aux métiers du bâtiment.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Bâtiment, Construction, Architecture, Génie Civil.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 55. Institut Supérieur de Droit et d'Interprétariat (ISDI)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé spécialisé dans les formations juridiques et l'interprétariat.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Droit, Sciences Juridiques, Interprétariat, Traduction, Relations Internationales.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 56. Institut Supérieur de Gestion (ISG)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de gestion et de commerce.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 60 17
- **Offre formation** : Gestion, marketing, RH, finance
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 57. Institut Supérieur de Management Adonaï (ISM Adonaï)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Comptabilité, Marketing, Ressources Humaines.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 58. Institut Supérieur de Management et de Développement (ISMAD)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de management et développement.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Développement Durable, Projets, Gouvernance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 59. Institut Supérieur de Management et de l'Entrepreneuriat (ISME)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en management et entrepreneuriat.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 90 01 11 11
- **Offre formation** : Formations en Management, Entrepreneuriat, Marketing, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 60. Institut Supérieur de Management Mgr Bakpessi (Kara)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé situé à Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Gestion, Comptabilité.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 61. Institut Supérieur de Philosophie et des Sciences Humaines Don Bosco (ISDB)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé confessionnel formant en philosophie et sciences humaines.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Philosophie, Sciences Humaines, Théologie, Éducation, Psychologie.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 62. Institut Supérieur des Langues et des Affaires (ISLA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation en langues et commerce international.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Langues Étrangères Appliquées, Commerce International, Traduction, Relations Internationales.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 63. Institut Supérieur des Sciences Psychologiques et de l'Humain (ISPSH)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé de psychologie et sciences humaines.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Psychologie, Sociologie, Sciences de l'Éducation, Travail Social.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 64. Institut Supérieur des Sciences Économiques et Commerciales (ISSEC-KOUVAHEY)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé de sciences économiques et commerciales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences Économiques, Commerce, Marketing, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 65. Institut Supérieur des Technologies et de Management (ISTM)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé de technologies et management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Technologies, Management, Informatique, Réseaux.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 66. Institut Supérieur La Maîtrise
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Comptabilité, Marketing, Secrétariat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 67. Institut Supérieur Le Technocrate
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Techniques Commerciales, Informatique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 68. Institut Supérieur Privé de Management (UPM-TOGO)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Gestion, Marketing, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 69. Institut supérieur Privé de Management du Togo (IPM-Togo)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de management et de gestion des entreprises.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Gestion des Entreprises, Marketing, Ressources Humaines, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 70. Institut Technique Bonita Haus
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de formation technique et professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations techniques: Hôtellerie, Tourisme, Restauration, Arts Culinaires.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 71. Institut Universitaire Global Wealth
- **Type** : UNIVERSITE
- **Description actuelle** : Institut universitaire privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes en Finance, Management, Entrepreneuriat, Commerce International.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 72. Institut Universitaire Lucas University College
- **Type** : UNIVERSITE
- **Description actuelle** : Institut universitaire privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes universitaires en Gestion, Informatique, Droit, Communication.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 73. Institut Universitaire Nobel (IUN)
- **Type** : UNIVERSITE
- **Description actuelle** : Institut universitaire privé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Informatique, Marketing, Communication.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 74. Institut Upsilon Collège de Paris Supérieur
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut supérieur privé, antenne du Collège de Paris.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Marketing, Finance, Ressources Humaines.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 75. Institute of Strategy and Leadership (ISL)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé dédié au leadership, à la stratégie et au management. Fondé par le Groupe DWDG.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : https://isl.education
- **Contacts** : Non renseignés
- **Offre formation** : Masters en Stratégie d'Entreprise, Intelligence Artificielle, Management, Leadership. Formation hybride (en ligne et présentiel). Stages et projets consulting.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 76. International School of Technology and Business (ISTB)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École internationale privée alliant technologie et commerce. Programmes bilingues français/anglais.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes bilingues en Technologies de l'Information, Business Management, Finance Internationale, Marketing Digital.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 77. ISC College (CIBC)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : College privé de formation supérieure.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Commerce, Informatique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 78. Knowbridge University Institute (Sokodé)
- **Type** : UNIVERSITE
- **Description actuelle** : Institut universitaire privé situé à Sokodé.
- **Ville** : Sokodé
- **Adresse** : Sokodé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Informatique, Commerce, Entrepreneuriat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 79. Lomé Business School (LBS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Business school privée offrant des formations en management, commerce et entrepreneuriat.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Programmes en Management, Commerce International, Entrepreneuriat, Marketing Digital, Finance.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 80. Lycée d'Adidogomé
- **Type** : LYCEE
- **Description actuelle** : Lycée public situé à Adidogomé (Lomé).
- **Ville** : Lomé
- **Adresse** : Adidogomé, Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 81. Lycée d'Atakpamé
- **Type** : LYCEE
- **Description actuelle** : Lycée public de la ville d'Atakpamé.
- **Ville** : Atakpamé
- **Adresse** : Atakpamé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 82. Lycée de Bè
- **Type** : LYCEE
- **Description actuelle** : Lycée public du quartier de Bè à Lomé.
- **Ville** : Lomé
- **Adresse** : Bè, Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 83. Lycée de Kara
- **Type** : LYCEE
- **Description actuelle** : Principal lycée de la ville de Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 84. Lycée de Kégué
- **Type** : LYCEE
- **Description actuelle** : Important lycée public dans la banlieue de Lomé.
- **Ville** : Lomé
- **Adresse** : Kégué, Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 85. Lycée de Sokodé
- **Type** : LYCEE
- **Description actuelle** : Lycée public de Sokodé, région Centrale.
- **Ville** : Sokodé
- **Adresse** : Sokodé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 86. Lycée de Tokoin
- **Type** : LYCEE
- **Description actuelle** : Grand lycée public du centre-ville de Lomé.
- **Ville** : Lomé
- **Adresse** : Tokoin, Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries A, B, C, D
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 87. Lycée Technique d'Atakpamé
- **Type** : LYCEE
- **Description actuelle** : Lycée technique de la région des Plateaux.
- **Ville** : Atakpamé
- **Adresse** : Atakpamé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries F, G
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 88. Lycée Technique de Kara
- **Type** : LYCEE
- **Description actuelle** : Lycée technique de la région de la Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries F, G
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 89. Lycée Technique de Lomé
- **Type** : LYCEE
- **Description actuelle** : Principal lycée technique du Togo.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Séries F1, F2, F3, F4, G1, G2, G3
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 90. Social and Inclusive Business Institute of Togo (SIBI-Togo)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de business social et inclusif.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Entrepreneuriat Social, Business Inclusif, Développement Durable.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 91. Univers du Leadership International de XOESE (Univers XOESE)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Institut privé de leadership et de développement personnel.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Leadership, Développement Personnel, Management, Communication.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 92. Université Catholique de l'Afrique de l'Ouest (UCAO)
- **Type** : UNIVERSITE
- **Description actuelle** : Université privée catholique.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Sciences humaines, droit, économie
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 93. Université Catholique de l'Afrique de l'Ouest - Unité Universitaire du Togo (UCAO-UUT)
- **Type** : UNIVERSITE
- **Description actuelle** : Université privée catholique membre du réseau UCAO. Formations en sciences sociales, juridiques et économiques.
- **Ville** : Lomé
- **Adresse** : BP 20258, Lomé
- **Site web** : https://www.ucao-uut.tg
- **Contacts** : +228 22 21 46 65 / info@ucao-uut.tg
- **Offre formation** : Facultés: Droit, Sciences Économiques et de Gestion, Sciences Sociales, Lettres et Sciences Humaines. Licence (3 ans), Master (2 ans). Filières: Droit des Affaires, Économie, Gestion des Entreprises, Sociologie, Psychologie, Communication, Sciences Politiques.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 94. Université de Kara
- **Type** : UNIVERSITE
- **Description actuelle** : Deuxième université publique du Togo, située dans la région de la Kara.
- **Ville** : Kara
- **Adresse** : Kara
- **Site web** : https://univ-kara.tg
- **Contacts** : +228 26 61 10 67
- **Offre formation** : Sciences, lettres, droit, économie, agronomie
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 95. Université de Kara (UK)
- **Type** : UNIVERSITE
- **Description actuelle** : Deuxième université publique du Togo, située dans la région de la Kara depuis 2004. Elle dessert tout le nord du pays.
- **Ville** : Kara
- **Adresse** : BP 43, Kara
- **Site web** : https://www.univ-kara.tg
- **Contacts** : +228 26 60 16 00 / contact@univ-kara.tg
- **Offre formation** : Facultés: Sciences et Techniques, Lettres et Sciences Humaines, Droit et Sciences Politiques, Sciences Économiques et de Gestion. Licence (3 ans), Master (2 ans), Doctorat (3 ans). Filières: Informatique, Mathématiques, Physique-Chimie, Biologie, Lettres Modernes, Anglais, Sociologie, Géographie, Droit, Économie, Gestion.
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : Géographie, Histoire, Agronomie

### 96. Université de Lomé
- **Type** : UNIVERSITE
- **Description actuelle** : La plus grande université du Togo. Plus de 60 000 étudiants.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : https://univ-lome.tg
- **Contacts** : +228 22 25 59 00
- **Offre formation** : Toutes les disciplines (sciences, lettres, droit, économie, médecine)
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 97. Université de Lomé (UL)
- **Type** : UNIVERSITE
- **Description actuelle** : Première université publique du Togo, fondée en 1970. Compte plusieurs facultés : Sciences, Lettres, Droit, Économie, Médecine, et écoles doctorales.
- **Ville** : Lomé
- **Adresse** : BP 1515, Boulevard Eyadema
- **Site web** : https://www.univ-lome.tg
- **Contacts** : +228 22 22 29 61 / contact@univ-lome.tg
- **Offre formation** : Facultés: Sciences, Lettres et Sciences Humaines, Droit, Sciences Économiques et de Gestion, Médecine, Sciences de la Santé. Écoles: École Supérieure d'Agronomie, Institut National des Sciences de l'Éducation. Programmes de Licence (3 ans), Master (2 ans), Doctorat (3 ans). Domaines: Sciences Exactes, Sciences Humaines, Droit, Économie, Santé, Agronomie.
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : Sciences Forestières, Sciences Environnementales, Histoire, Arts Plastiques, Tourisme et Hôtellerie, Enseignement Primaire, Agronomie, Géographie, Communication et Journalisme

### 98. Université des Sciences de la Santé
- **Type** : UNIVERSITE
- **Description actuelle** : Spécialisée dans les formations médicales et paramédicales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 42 60
- **Offre formation** : Médecine, pharmacie, odontologie, soins infirmiers
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 99. Université des Sciences et Technologies du Togo (UST-TG)
- **Type** : UNIVERSITE
- **Description actuelle** : Université privée des sciences et technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences et Technologies, Informatique, Ingénierie.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 100. Université UBLT
- **Type** : UNIVERSITE
- **Description actuelle** : Université privée au Togo.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences, Technologies, Gestion, Droit.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 101. Université WASCAL
- **Type** : UNIVERSITE
- **Description actuelle** : Université ouest-africaine spécialisée en sciences du climat.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Climatologie, environnement
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 102. École Africaine des Métiers de l'Architecture et de l'Urbanisme (EAMAU)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : École inter-africaine spécialisée dans les métiers de l'architecture, de l'urbanisme et du développement territorial.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Architecture, Urbanisme, Aménagement du Territoire, Développement Durable.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Géographie

### 103. École de Finance
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée dans les métiers de la finance.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Finance, Banque, Assurance, Comptabilité, Gestion Financière.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 104. École des Cadres
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de formation des cadres d'entreprise.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Administration, Gestion des Entreprises.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 105. École des Hautes Études de Commerce et de Gestion (HECOGU)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de commerce et de gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Commerce, Gestion, Marketing, Finance, Audit.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 106. École des Hautes Études de Sciences et Technologies (HEST)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de sciences et technologies.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Sciences et Technologies, Informatique, Mathématiques, Physique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 107. École des Micro-Entrepreneurs du Centre (EMC-Sokodé)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'entrepreneuriat située à Sokodé.
- **Ville** : Sokodé
- **Adresse** : Sokodé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Entrepreneuriat, Microfinance, Gestion de Projets, Développement Local.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 108. École Maritime du Togo (EMARITO)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée dans les métiers de la mer et du transport maritime.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Navigation Maritime, Logistique Portuaire, Transport International, Gestion Maritime.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 109. École Nationale d'Administration (ENA)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Forme les hauts fonctionnaires de l'État togolais.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 21 30 63
- **Offre formation** : Administration publique, diplomatie
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 110. École Nationale d'Administration (ENA) - Togo
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée formant aux métiers de l'administration publique et privée.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Administration Publique, Gestion des Collectivités, RH, Finances Publiques.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 111. École Nationale des Auxiliaires Médicaux (ENAM) de Lomé
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École publique de formation des auxiliaires médicaux (infirmiers, sages-femmes, techniciens de santé).
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formation des professionnels de santé: Infirmier Diplômé d'État, Sage-Femme, Technicien de Laboratoire, Technicien de Radiologie.
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 112. École Nationale Supérieure (ENS) d'Atakpamé
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École publique de formation des enseignants du secondaire, située à Atakpamé. Forme des professeurs certifiés pour les lycées et collèges.
- **Ville** : Atakpamé
- **Adresse** : BP 10, Atakpamé
- **Site web** : Non renseigné
- **Contacts** : +228 27 70 01 32
- **Offre formation** : Formation des enseignants du secondaire. Filières: Mathématiques, Physique-Chimie, SVT, Lettres Modernes, Anglais, Histoire-Géographie. Licence d'Enseignement (3 ans), Master Enseignement (2 ans).
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : Enseignement Primaire, Histoire, Géographie

### 113. École Polytechnique de Lomé
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Formation d'ingénieurs de haut niveau.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : +228 22 25 59 00
- **Offre formation** : Génie civil, électrique, mécanique, informatique
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 114. École Supérieure d'Administration et de Gestion (ESCA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'administration et de gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Administration, Gestion, Comptabilité, Marketing.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 115. École Supérieure d'Administration et de Gestion Notre Dame de l'Église (ESAG-NDE)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée confessionnelle d'administration et de gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Administration, Gestion, Comptabilité, Informatique de Gestion.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 116. École Supérieure d'Agronomie (ESA)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Formation aux métiers de l'agriculture et de l'environnement.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Agronomie, sciences forestières, élevage
- **Niveau** : Non renseigné
- **Statut** : Public
- **Filières** : À déterminer

### 117. École Supérieure d'Architecture et de Topographie (ESTABAT)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée formant dans les domaines de l'architecture, de la topographie et du bâtiment.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Architecture, Topographie, Génie Civil, Urbanisme, Design d'intérieur.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques, Géographie

### 118. École Supérieure d'Audit et de Management (ESAM)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'audit et de management.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Audit, Management, Finance, Comptabilité, Contrôle de Gestion.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 119. École Supérieure d'Esthétique Appliquée Pharm-A-Peau (ESEA-Q'LS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'esthétique et de soins.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Esthétique, Cosmétologie, Soins de la Peau, Bien-être.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 120. École Supérieure d'Informatique et de Gestion (ESIG GLOBAL SUCCESS)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée en informatique et gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique de Gestion, Développement Web, Comptabilité, Marketing Digital.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 121. École Supérieure d'Informatique, de Business et d'Administration (ESIBA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'informatique, business et administration.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Informatique de Gestion, Business Administration, Marketing.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 122. École Supérieure d'Ingénieurs d'Aného (ESIA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée d'ingénieurs située à Aného, spécialisée dans les formations techniques et scientifiques.
- **Ville** : Aného
- **Adresse** : Aného
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations d'ingénieurs et techniciens supérieurs. Filières: Génie Civil, Génie Électrique, Génie Informatique, Énergies Renouvelables.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 123. École Supérieure de Commerce et de l'Économie Numérique (ESCEN)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de commerce axée sur l'économie numérique.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Commerce, Économie Numérique, Marketing Digital, E-commerce, Gestion.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 124. École Supérieure de Communication et de Gestion (ESCG-Tsévié)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de communication et gestion située à Tsévié.
- **Ville** : Tsévié
- **Adresse** : Tsévié
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Communication, Gestion des Entreprises, Marketing, Comptabilité.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 125. École Supérieure de Formation Professionnelle (CFP ANCILA)
- **Type** : CENTRE_FORMATION_PROFESSIONNELLE
- **Description actuelle** : Centre privé de formation professionnelle.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations professionnelles en Métiers Techniques, Services, Artisanat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 126. École Supérieure de Gestion et d'Informatique (ESGIS)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Grande école privée spécialisée en gestion, informatique et technologies. L'un des plus grands établissements privés du Togo.
- **Ville** : Lomé
- **Adresse** : BP 80665, Lomé
- **Site web** : https://www.esgis.tg
- **Contacts** : +228 22 21 60 60 / info@esgis.tg
- **Offre formation** : Écoles: ESGIS Management, ESGIS Informatique, ESGIS Communication. Programmes: Licence (3 ans), Master (2 ans), MBA. Filières: Informatique de Gestion, Génie Logiciel, Réseaux et Télécommunications, Marketing, Finance, Comptabilité, Audiovisuel, Design Graphique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme, Arts Plastiques

### 127. École Supérieure de Management (ESMA)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de management et de gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Management, Ressources Humaines, Marketing, Finance, Entrepreneuriat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 128. École Supérieure de Relations Internationales et de Diplomatie (ESRID)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de relations internationales.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Relations Internationales, Diplomatie, Géopolitique, Droit International.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 129. École Supérieure de Technologie et de Gestion (ESTEG)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de technologie et de gestion.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Technologie, Gestion, Informatique, Commerce.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 130. École Supérieure des Affaires (ESA)
- **Type** : GRANDE_ECOLE
- **Description actuelle** : Grande école privée de commerce et de gestion. Propose des programmes en management, finance et entrepreneuriat.
- **Ville** : Lomé
- **Adresse** : BP 81170, Lomé
- **Site web** : https://www.esa.tg
- **Contacts** : +228 22 21 35 00 / contact@esa.tg
- **Offre formation** : Programmes: Licence en Commerce et Gestion (3 ans), Master en Management des Entreprises (2 ans), MBA. Filières: Marketing, Finance d'Entreprise, Ressources Humaines, Logistique, Commerce International, Entrepreneuriat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 131. École Supérieure des Arts de la Mode et des Arts Plastiques (ESAMOD)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée dans les métiers de la mode, du design et des arts plastiques.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Stylisme, Création de Mode, Design Textile, Arts Plastiques, Design Graphique.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 132. École Supérieure des Arts et Sciences du Numérique (ESASN)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée dans les arts et sciences du numérique.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Arts Numériques, Design Digital, Animation 3D, Développement Web, Multimédia.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 133. École Supérieure des Ponts et Chaussées (ESPC)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée spécialisée en génie civil, topographie et travaux publics.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Génie Civil, Ponts et Chaussées, Topographie, Bâtiment et Travaux Publics.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques

### 134. École Supérieure des Techniques Biologiques
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : Formation privée en biologie et santé.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Biologie, analyses médicales
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 135. École Supérieure des Techniques et Arts de la Communication (ESTAC)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de communication et de techniques médiatiques.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Communication, Journalisme, Marketing Digital, Relations Publiques, Publicité.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Communication et Journalisme

### 136. École Supérieure des Études Cinématographiques (ESEC)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de cinéma et d'audiovisuel.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Réalisation Cinématographique, Production Audiovisuelle, Montage, Scénarisation.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Arts Plastiques, Communication et Journalisme

### 137. École Supérieure du Tourisme et d'Hôtellerie Stella Matutina (ESTH-SM)
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de tourisme et d'hôtellerie.
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Tourisme, Hôtellerie, Gestion Hôtelière, Restauration, Événementiel.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Tourisme et Hôtellerie

### 138. École Supérieure Le Miel de Kpové-Zion
- **Type** : ECOLE_SUPERIEURE
- **Description actuelle** : École privée de formation supérieure.
- **Ville** : Kpové
- **Adresse** : Kpové
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Formations en Gestion, Agriculture, Développement Rural, Entrepreneuriat.
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : Agronomie

### 139. École Supérieure Multinationale des Télécommunications (ESMT) - Antenne Togo
- **Type** : GRANDE_ECOLE
- **Description actuelle** : École supérieure multinationale spécialisée dans les télécommunications (antenne togolaise).
- **Ville** : Lomé
- **Adresse** : Lomé
- **Site web** : https://www.esmt.sn
- **Contacts** : +228 22 21 00 00
- **Offre formation** : Formations en Télécommunications, Réseaux Informatiques, Cybersécurité, Technologies Mobiles. Licence (3 ans), Master (2 ans).
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 140. Établissement Agou
- **Type** : AUTRE
- **Description actuelle** : Préfecture d'Agou, région des Plateaux
- **Ville** : Agou
- **Adresse** : Agou
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 141. Établissement Akposso
- **Type** : AUTRE
- **Description actuelle** : Préfecture d'Akposso, région des Plateaux
- **Ville** : Akposso
- **Adresse** : Akposso
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 142. Établissement Amlamé
- **Type** : AUTRE
- **Description actuelle** : Préfecture d'Ogou, région des Plateaux
- **Ville** : Amlamé
- **Adresse** : Amlamé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 143. Établissement Aného
- **Type** : AUTRE
- **Description actuelle** : Préfecture des Lacs, région Maritime
- **Ville** : Aného
- **Adresse** : Aného
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 144. Établissement Badou
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Wawa, région des Plateaux
- **Ville** : Badou
- **Adresse** : Badou
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 145. Établissement Bafilo
- **Type** : AUTRE
- **Description actuelle** : Préfecture d'Assoli, région Centrale
- **Ville** : Bafilo
- **Adresse** : Bafilo
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 146. Établissement Bassar
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Bassar, région Kara
- **Ville** : Bassar
- **Adresse** : Bassar
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 147. Établissement Cinkassé
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Cinkassé, région des Savanes
- **Ville** : Cinkassé
- **Adresse** : Cinkassé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 148. Établissement Danyi
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Danyi, région des Plateaux
- **Ville** : Danyi
- **Adresse** : Danyi
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 149. Établissement Dapaong
- **Type** : AUTRE
- **Description actuelle** : Préfecture de la Tône, région des Savanes
- **Ville** : Dapaong
- **Adresse** : Dapaong
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 150. Établissement Elavagnon
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Moyen-Mono, région des Plateaux
- **Ville** : Elavagnon
- **Adresse** : Elavagnon
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 151. Établissement Kandé
- **Type** : AUTRE
- **Description actuelle** : Préfecture de la Doufelgou, région Kara
- **Ville** : Kandé
- **Adresse** : Kandé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 152. Établissement Kpalimé
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Kloto, région des Plateaux
- **Ville** : Kpalimé
- **Adresse** : Kpalimé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 153. Établissement Kévé
- **Type** : AUTRE
- **Description actuelle** : Préfecture de l'Avé, région Maritime
- **Ville** : Kévé
- **Adresse** : Kévé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 154. Établissement Mango
- **Type** : AUTRE
- **Description actuelle** : Préfecture de l'Oti, région Kara
- **Ville** : Mango
- **Adresse** : Mango
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 155. Établissement Mô
- **Type** : AUTRE
- **Description actuelle** : Préfecture de la Mô, région Centrale
- **Ville** : Mô
- **Adresse** : Mô
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 156. Établissement Niamtougou
- **Type** : AUTRE
- **Description actuelle** : Préfecture de la Doufelgou, région Kara
- **Ville** : Niamtougou
- **Adresse** : Niamtougou
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 157. Établissement Notsé
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Haho, région des Plateaux
- **Ville** : Notsé
- **Adresse** : Notsé
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 158. Établissement Pagouda
- **Type** : AUTRE
- **Description actuelle** : Préfecture de la Kozah, région Kara
- **Ville** : Pagouda
- **Adresse** : Pagouda
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 159. Établissement Sansanné-Mango
- **Type** : AUTRE
- **Description actuelle** : Préfecture de l'Oti, région Kara
- **Ville** : Sansanné-Mango
- **Adresse** : Sansanné-Mango
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 160. Établissement Sotouboua
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Sotouboua, région Centrale
- **Ville** : Sotouboua
- **Adresse** : Sotouboua
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 161. Établissement Tabligbo
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Yoto, région Maritime
- **Ville** : Tabligbo
- **Adresse** : Tabligbo
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 162. Établissement Tandjouaré
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Tandjouaré, région des Savanes
- **Ville** : Tandjouaré
- **Adresse** : Tandjouaré
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 163. Établissement Tchamba
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Tchamba, région Centrale
- **Ville** : Tchamba
- **Adresse** : Tchamba
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 164. Établissement Tsévié
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Zio, région Maritime
- **Ville** : Tsévié
- **Adresse** : Tsévié
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

### 165. Établissement Vogan
- **Type** : AUTRE
- **Description actuelle** : Préfecture de Vo, région Maritime
- **Ville** : Vogan
- **Adresse** : Vogan
- **Site web** : Non renseigné
- **Contacts** : Non renseignés
- **Offre formation** : Non renseignée
- **Niveau** : Non renseigné
- **Statut** : Privé
- **Filières** : À déterminer

---

## Instructions importantes

1. Sois le plus précis possible (URLs valides, informations vérifiées)
2. Pour les images, donne une requête Google Images précise (ex: "Université de Lomé logo officiel")
3. Si tu ne connais pas une information avec certitude, indique "À vérifier" plutôt que d'inventer
4. Privilégie les sources officielles (sites web gouvernementaux, annuaires officiels)
5. Les filières proposées doivent correspondre à l'offre réelle de l'établissement
6. Pour chaque établissement, réponds avec une fiche détaillée complète

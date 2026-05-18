# Activ Education — Flutter App

Plateforme d'orientation scolaire et professionnelle pour le Togo.

---

## 📁 Structure du projet

```
lib/
├── main.dart                          # Entry point + routing
├── theme/
│   ├── app_theme.dart                 # Couleurs, typographie, ThemeData
│   └── app_routes.dart                # Constantes de routes
├── widgets/
│   └── common_widgets.dart            # Composants réutilisables
└── screens/
    ├── splash/
    │   └── splash_screen.dart         # Écran de chargement animé
    ├── onboarding/
    │   └── onboarding_screen.dart     # 3 slides d'introduction
    └── auth/
        ├── profile_setup_screen.dart  # Sélection du rôle + classe + ville
        ├── register_screen.dart       # Formulaire inscription (étape 1)
        ├── register_preferences_screen.dart  # Matières + style (étape 2)
        └── login_screen.dart          # Connexion (email/Google)
```

---

## 🎨 Design Tokens

| Token         | Valeur       | Usage                  |
|---------------|--------------|------------------------|
| `primary`     | `#3D35D9`    | Bleu principal, boutons, accents |
| `accent`      | `#FFA800`    | Orange CTA, highlights |
| `background`  | `#FFFFFF`    | Fond blanc             |
| `backgroundGrey` | `#F4F5F9` | Fond gris léger        |
| `textDark`    | `#1A1A2E`    | Titres                 |
| `textMedium`  | `#6B7280`    | Corps de texte         |
| `cardBorder`  | `#E5E7EB`    | Bordures de cartes     |

**Font:** Nunito (Regular, Medium, SemiBold, Bold, ExtraBold)

---

## 🔀 Flux de navigation

```
SplashScreen (2.8s)
    └─► OnboardingScreen (3 slides)
            ├─► [Suivant x3] ──► ProfileSetupScreen
            │                         └─► RegisterScreen
            │                               └─► RegisterPreferencesScreen
            │                                       └─► HomeScreen (à venir)
            └─► [Passer / J'ai déjà un compte] ──► LoginScreen
                                                        └─► HomeScreen (à venir)
```

---

## 🧩 Composants réutilisables (`common_widgets.dart`)

| Composant           | Usage                                      |
|---------------------|--------------------------------------------|
| `PrimaryButton`     | Bouton orange CTA (avec loader)            |
| `OutlineButton`     | Bouton outline bleu                        |
| `AppTextField`      | Champ de saisie avec label                 |
| `DotIndicator`      | Points de pagination onboarding            |
| `SocialButton`      | Bouton connexion Google/Facebook           |
| `DividerWithText`   | Séparateur "ou continuer avec email"       |
| `StepProgressBar`   | Barre de progression multi-étapes          |

---

## 🚀 Installation

```bash
# 1. Télécharger la police Nunito
# https://fonts.google.com/specimen/Nunito
# Placer dans assets/fonts/

# 2. Créer les dossiers assets
mkdir -p assets/{fonts,images,icons,animations}

# 3. Installer les dépendances
flutter pub get

# 4. Lancer
flutter run
```

---

## 📡 Endpoints à connecter (Module 1 – Auth)

> À remplir avec les endpoints Swagger une fois disponibles

```
POST /api/auth/register          # Inscription
POST /api/auth/login             # Connexion email/phone
POST /api/auth/google            # Connexion Google
POST /api/auth/refresh           # Refresh token
GET  /api/users/me               # Profil connecté
PUT  /api/users/me               # Mise à jour profil
POST /api/auth/forgot-password   # Mot de passe oublié
POST /api/auth/reset-password    # Réinitialisation
```

---

## 📋 Modules à développer ensuite

- [ ] **Module 1** — Dashboard élève + Profil + Historique
- [ ] **Module 2** — Bibliothèque (Séries, Filières, Métiers, Établissements)
- [ ] **Module 3** — Quiz d'orientation + Analyse de notes
- [ ] **Module 4** — Messagerie + Rendez-vous
- [ ] **Back-office Web** — Dashboard Conseiller + Admin (React)

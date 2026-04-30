# Guide d'installation — Activ Education Flutter

## Étape 1 — Créer le projet Flutter

```bash
# Dans ton terminal, va dans ton dossier de travail
cd ~/frontend

# Crée le projet Flutter (si pas encore fait)
flutter create activ_education
cd activ_education
```

---

## Étape 2 — Structure exacte des dossiers à créer

```bash
# Créer TOUS les dossiers nécessaires
mkdir -p lib/theme
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/widgets
mkdir -p lib/screens/splash
mkdir -p lib/screens/onboarding
mkdir -p lib/screens/auth
mkdir -p lib/screens/home
mkdir -p lib/screens/explorer
mkdir -p assets/fonts
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/animations
```

---

## Étape 3 — Copier les fichiers générés

Voici le positionnement EXACT de chaque fichier :

```
activ_education/
├── pubspec.yaml                    ← REMPLACER par le fichier fourni
│
├── assets/
│   └── fonts/
│       ├── Nunito-Regular.ttf      ← Télécharger sur fonts.google.com
│       ├── Nunito-Medium.ttf
│       ├── Nunito-SemiBold.ttf
│       ├── Nunito-Bold.ttf
│       └── Nunito-ExtraBold.ttf
│
└── lib/
    ├── main.dart                   ← REMPLACER
    │
    ├── theme/
    │   ├── app_theme.dart          ← COPIER
    │   └── app_routes.dart         ← COPIER
    │
    ├── models/
    │   └── models.dart             ← COPIER
    │
    ├── services/
    │   └── api_service.dart        ← COPIER
    │
    ├── widgets/
    │   ├── common_widgets.dart     ← COPIER
    │   └── bottom_nav.dart         ← COPIER
    │
    └── screens/
        ├── main_scaffold.dart      ← COPIER
        │
        ├── splash/
        │   └── splash_screen.dart  ← COPIER
        │
        ├── onboarding/
        │   └── onboarding_screen.dart ← COPIER
        │
        ├── auth/
        │   ├── profile_setup_screen.dart       ← COPIER
        │   ├── register_screen.dart             ← COPIER
        │   ├── register_preferences_screen.dart ← COPIER
        │   ├── login_screen.dart                ← COPIER
        │   ├── forgot_password_screen.dart      ← COPIER
        │   └── otp_screen.dart                  ← COPIER
        │
        ├── home/
        │   └── dashboard_bachelier.dart ← COPIER
        │
        └── explorer/
            ├── explorer_screen.dart     ← COPIER
            └── fiche_detail_screen.dart ← COPIER
```

---

## Étape 4 — Supprimer le main.dart par défaut

```bash
# Supprimer le contenu de lib/ généré par Flutter
rm lib/main.dart
# Puis coller les fichiers fournis
```

---

## Étape 5 — Installer les dépendances

```bash
# Dans le dossier activ_education/
flutter pub get
```

---

## Étape 6 — Télécharger la police Nunito

1. Aller sur https://fonts.google.com/specimen/Nunito
2. Cliquer **Download family**
3. Extraire le zip
4. Copier ces 5 fichiers dans `assets/fonts/` :
   - `Nunito-Regular.ttf`
   - `Nunito-Medium.ttf`
   - `Nunito-SemiBold.ttf`
   - `Nunito-Bold.ttf`
   - `Nunito-ExtraBold.ttf`

---

## Étape 7 — Lancer l'app

```bash
flutter run
# Choisir Chrome (web) ou Linux (desktop)
```

---

## Dépannage — Erreurs fréquentes

### ❌ "Couldn't resolve package 'dio'"
```bash
flutter pub get
# Si ça ne marche pas :
flutter clean
flutter pub get
```

### ❌ "No such file or directory"
Vérifier que le fichier est bien dans le bon dossier.
Exemple : `splash_screen.dart` doit être dans `lib/screens/splash/`
PAS dans `lib/screens/`

### ❌ "AppColors isn't defined"
Le fichier `app_theme.dart` n'est pas dans `lib/theme/`
→ Vérifier l'emplacement : `lib/theme/app_theme.dart`

### ❌ "AppBottomNav isn't defined"
Le fichier `bottom_nav.dart` n'est pas dans `lib/widgets/`
→ Vérifier l'emplacement : `lib/widgets/bottom_nav.dart`

### ❌ Font rendering issues
S'assurer que les fichiers .ttf sont bien dans `assets/fonts/`
et que le `pubspec.yaml` les référence correctement.

---

## Commandes utiles

```bash
flutter doctor          # Vérifier l'installation Flutter
flutter pub get         # Installer les dépendances
flutter clean           # Nettoyer le cache
flutter run -d chrome   # Lancer sur Chrome
flutter run -d linux    # Lancer sur Linux desktop
flutter build web       # Build production web
flutter build apk       # Build APK Android
```

#!/bin/bash
# =============================================================
# Script de correction de la structure du projet Flutter
# Activ Education
# Exécuter depuis la racine du projet : ~/frontend/activ_education/
# =============================================================

echo "🔧 Correction de la structure des fichiers..."

# 1. Créer les bons dossiers à la racine de lib/
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

echo "✅ Dossiers créés"

# 2. Si les fichiers sont dans lib/screens/theme/ → les déplacer
if [ -f "lib/screens/theme/app_theme.dart" ]; then
  mv lib/screens/theme/app_theme.dart lib/theme/app_theme.dart
  echo "✅ app_theme.dart déplacé → lib/theme/"
fi

if [ -f "lib/screens/theme/app_routes.dart" ]; then
  mv lib/screens/theme/app_routes.dart lib/theme/app_routes.dart
  echo "✅ app_routes.dart déplacé → lib/theme/"
fi

# 3. Si les fichiers sont dans lib/screens/widgets/ → les déplacer
if [ -f "lib/screens/widgets/common_widgets.dart" ]; then
  mv lib/screens/widgets/common_widgets.dart lib/widgets/common_widgets.dart
  echo "✅ common_widgets.dart déplacé → lib/widgets/"
fi

if [ -f "lib/screens/widgets/bottom_nav.dart" ]; then
  mv lib/screens/widgets/bottom_nav.dart lib/widgets/bottom_nav.dart
  echo "✅ bottom_nav.dart déplacé → lib/widgets/"
fi

# 4. Si les fichiers sont dans lib/screens/services/ → les déplacer
if [ -f "lib/screens/services/api_service.dart" ]; then
  mv lib/screens/services/api_service.dart lib/services/api_service.dart
  echo "✅ api_service.dart déplacé → lib/services/"
fi

# 5. Si les fichiers sont dans lib/screens/models/ → les déplacer
if [ -f "lib/screens/models/models.dart" ]; then
  mv lib/screens/models/models.dart lib/models/models.dart
  echo "✅ models.dart déplacé → lib/models/"
fi

# 6. Supprimer les dossiers vides mal placés
rm -rf lib/screens/theme
rm -rf lib/screens/widgets
rm -rf lib/screens/services
rm -rf lib/screens/models

echo ""
echo "📁 Structure finale vérifiée :"
find lib -name "*.dart" | sort

echo ""
echo "🚀 Lancement de flutter pub get..."
flutter pub get

echo ""
echo "✅ Terminé ! Lance maintenant : flutter run"

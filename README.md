# Flutter Boilerplate

Boilerplate Flutter réutilisable basé sur une vraie application de production. Il garde les fondations utiles: authentification, mode invité, onboarding, thèmes, multilingue, préférences, notifications, connectivité, client API et widgets partagés.

## Ce que contient le boilerplate

- Architecture `core / features / shared`
- Navigation et state management avec GetX
- Thèmes clair, sombre et système persistés localement
- Localisation français, anglais et arabe
- Onboarding avec résolution de navigation
- Authentification, OTP, reset password et mode invité
- Préférences via `SharedPreferences`
- Stockage sécurisé du token via `flutter_secure_storage`
- Client HTTP Dio avec headers, multipart, téléchargement, intercepteurs auth/connectivité
- Notifications Firebase Cloud Messaging et notifications locales
- Connectivité avec écran hors ligne
- Widgets réutilisables: boutons, champs, app bar, états vides/erreur, loaders, bottom sheets, badges
- Noyau de features volontairement réduit: app shell, home, auth, onboarding, profil, notifications, connectivité

## Structure

```text
lib/
  core/
    constants/       # routes, endpoints, config, images, textes de marque
    controllers/     # theme/language controllers
    localization/    # fr, en, ar
    network/         # ApiClient Dio
    preferences/     # AppPreferences
    services/        # auth, notifications, Google auth, connectivité
    theme/           # couleurs, typographies, ThemeData
  features/          # modules applicatifs
  shared/widgets/    # UI kit réutilisable
```

## Démarrage

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

Les fichiers `env/dev.json` et `env/prod.json` fournis sont des exemples avec placeholders. Remplace les valeurs `APP_*` par celles de ton backend.

## Configuration à personnaliser

- Nom/package Dart: `pubspec.yaml`
- App id Android: `android/app/build.gradle.kts`
- Nom affiché Android/iOS: `AndroidManifest.xml`, `ios/Runner/Info.plist`
- Constantes de marque: `lib/core/constants/string.dart`
- Variables d'environnement: `lib/core/constants/api.dart`, `env/*.json`
- Routes: `lib/core/constants/routes.dart`, `lib/core/routes/app_routes.dart`
- Endpoints backend: `lib/core/constants/endpoint.dart`
- Logos/images: `assets/images/` et `lib/core/constants/images.dart`
- Langues: `lib/core/localization/app_translations.dart`

## Langues

Le boilerplate supporte:

- Français: `fr_FR`
- Anglais: `en_US`
- Arabe: `ar_EG`

L'arabe utilise un fallback anglais complet dans `ar_translation.dart`, avec les clés principales déjà traduites. Tu peux enrichir ce fichier au fur et à mesure sans risquer de casser l'interface.

## Environnement

Variables attendues:

```json
{
  "APP_API_BASE_URL": "https://api.example.com/api/v1/",
  "APP_BASE_IMAGE_URL": "https://example.com/sliders/",
  "APP_API_KEY": "replace-me",
  "APP_BASE_ONBOARDING_IMAGE_URL": "https://example.com/onboarding/",
  "APP_BASE_BANNER_IMAGE_URL": "https://example.com/banner/",
  "APP_BASE_PRODUCT_IMAGE_URL": "https://example.com/",
  "APP_GOOGLE_CLIENT_ID": "replace-me",
  "APP_GOOGLE_API_KEY": "replace-me"
}
```

## Qualité

```bash
dart analyze
flutter test
```

## Notes

Pour créer une nouvelle application, garde `core` et `shared`, puis ajoute progressivement tes domaines dans `features`.

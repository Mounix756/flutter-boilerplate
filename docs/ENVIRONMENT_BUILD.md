# Configuration et build par environnement

Ce guide explique comment configurer les valeurs d'environnement du boilerplate sans embarquer de secrets dans le code source.

## Principe

L'application lit sa configuration depuis des variables Dart compile-time avec `String.fromEnvironment`.

Les valeurs sont injectees avec:

```bash
--dart-define=KEY=value
```

ou, plus pratique:

```bash
--dart-define-from-file=env/dev.json
```

Le dossier `env/` contient des fichiers locaux ignores par Git. Ils ne doivent jamais etre pousses dans le depot.

## Fichiers importants

- `lib/core/constants/api.dart`: configuration locale utilisee par l'app. Ce fichier est ignore par Git.
- `lib/core/constants/api.example.dart`: template versionne, sans vraies cles.
- `env/dev.json`: valeurs locales de developpement. Ce fichier est ignore par Git.
- `.gitignore`: ignore `/env/*.json` et `lib/core/constants/api.dart`.

## Variables attendues

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

Toutes les URLs doivent etre en HTTPS. En release, les valeurs critiques doivent etre fournies au build, sinon l'application leve une erreur de configuration.

## Lancer en developpement

Creer ou mettre a jour le fichier local:

```bash
env/dev.json
```

Puis lancer:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Pour lancer sur un device precis:

```bash
flutter run -d <device-id> --dart-define-from-file=env/dev.json
```

## Build Android

APK:

```bash
flutter build apk --release --dart-define-from-file=env/prod.json
```

App Bundle Play Store:

```bash
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

`env/prod.json` doit rester local ou etre genere par la CI/CD depuis des secrets proteges.

## Build iOS

```bash
flutter build ios --release --dart-define-from-file=env/prod.json
```

Pour une archive App Store, utiliser ensuite Xcode ou l'outil CI/CD habituel avec les memes variables injectees au build Flutter.

## Production avec CI/CD

En production, ne stockez pas `env/prod.json` dans Git.

Approche recommandee:

1. Ajouter chaque valeur dans le gestionnaire de secrets CI/CD.
2. Generer `env/prod.json` pendant le job de build.
3. Lancer `flutter build ... --dart-define-from-file=env/prod.json`.
4. Supprimer le fichier genere a la fin du job si la plateforme CI ne nettoie pas automatiquement le workspace.

Exemple conceptuel:

```bash
mkdir -p env
printf '%s' "$APP_PROD_DART_DEFINES_JSON" > env/prod.json
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

La variable `APP_PROD_DART_DEFINES_JSON` doit contenir le JSON complet et etre marquee comme secret dans la CI.

## Rotation des cles

Les anciennes cles qui ont deja ete presentes dans le code doivent etre considerees exposees.

Actions recommandees:

- Regenerer les anciennes cles API exposees.
- Restreindre ou regenerer les cles Google Cloud.
- Restreindre les cles Google par package Android, SHA-1, bundle id iOS, APIs et quotas.
- Regenerer ou proteger les webhooks n8n derriere un backend proxy.

## Verifications avant publication

Avant un build release:

```bash
dart analyze
flutter test
```

Verifier aussi:

- `env/prod.json` n'est pas versionne.
- Les URLs de production sont en HTTPS.
- Les cles Google sont restreintes cote Google Cloud.
- Les valeurs de prod ne sont pas affichees dans les logs CI.

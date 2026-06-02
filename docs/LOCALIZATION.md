# Localisation et multilingue

Documentation du système de traduction du boilerplate.

## Langues supportées

L'application supporte 3 langues:

1. Français (`fr_FR`) - langue par défaut
2. English (`en_US`)
3. العربية (`ar_EG`) - arabe

## Architecture

```text
lib/core/localization/
├── app_translations.dart
└── languages/
    ├── fr_translation.dart
    ├── en_translation.dart
    └── ar_translation.dart
```

Le contrôleur est dans:

```text
lib/core/controllers/language_controller.dart
```

## Utilisation

```dart
Text('welcome'.tr)
```

Avec paramètres:

```dart
'hello_user'.trParams({'name': 'John'})
```

## Changer la langue

```dart
LanguageController.to.changeLanguage('fr_FR');
LanguageController.to.changeLanguage('en_US');
LanguageController.to.changeLanguage('ar_EG');
```

Depuis l'interface: Profil -> Langue -> sélectionner la langue.

## Ajouter une clé

Ajoute la clé dans:

- `fr_translation.dart`
- `en_translation.dart`
- `ar_translation.dart`

`ar_translation.dart` étend le dictionnaire anglais avec `...enTranslation`; une clé oubliée reste donc affichable en anglais plutôt qu'en clé brute.

## Bonnes pratiques

- Utiliser `.tr` au lieu de texte en dur pour les libellés visibles.
- Garder des clés descriptives: `login_subtitle`, `empty_state_title`, etc.
- Tester les écrans avec les trois langues, surtout les textes longs.
- Pour l'arabe, vérifier l'alignement et les débordements sur mobile.

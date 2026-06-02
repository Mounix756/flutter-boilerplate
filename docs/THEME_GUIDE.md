# Guide d'utilisation des thèmes - Flutter Boilerplate

Ce document explique comment utiliser correctement les thèmes (clair/sombre) dans l'application Flutter Boilerplate.

---

## Table des matières

- [Architecture des thèmes](#architecture-des-thèmes)
- [Utilisation dans les widgets](#utilisation-dans-les-widgets)
- [Bonnes pratiques](#bonnes-pratiques)
- [Exemples complets](#exemples-complets)
- [Erreurs courantes](#erreurs-courantes)

---

## Architecture des thèmes

### Fichiers principaux

1. **`lib/core/theme/app_colors.dart`** : Définition des couleurs
2. **`lib/core/theme/app_text_styles.dart`** : Styles de texte
3. **`lib/core/theme/app_theme.dart`** : Configuration des thèmes
4. **`lib/core/controllers/theme_controller.dart`** : Gestion du mode thème

---

## Utilisation dans les widgets

### Récupérer le thème actuel

Toujours récupérer le thème au début de la méthode `build()` :

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  
  // Votre widget ici
}
```

### Utiliser les couleurs

#### **Convention importante : Utiliser withAlpha au lieu de withOpacity**

Pour des raisons de performance et de cohérence, toujours utiliser `withAlpha` au lieu de `withOpacity`.

```dart
// BIEN : Utiliser withAlpha (valeur de 0 à 255)
color: AppColors.primary.withAlpha(76)  // 30% d'opacité
color: AppColors.primary.withAlpha(127) // 50% d'opacité
color: AppColors.primary.withAlpha(178) // 70% d'opacité

// MAL : Ne pas utiliser withOpacity
color: AppColors.primary.withOpacity(0.3)
```

**Table de conversion courante** :
- 10% → `withAlpha(25)`
- 20% → `withAlpha(51)`
- 30% → `withAlpha(76)`
- 40% → `withAlpha(102)`
- 50% → `withAlpha(127)`
- 60% → `withAlpha(153)`
- 70% → `withAlpha(178)`
- 80% → `withAlpha(204)`
- 90% → `withAlpha(229)`

#### **BIEN** : Utiliser colorScheme et AppColors

```dart
// Pour les couleurs primaires/secondaires
Container(
  color: colorScheme.primary,
  child: Text(
    'Texte',
    style: TextStyle(color: colorScheme.onPrimary),
  ),
)

// Pour les couleurs de surface
Container(
  color: colorScheme.surface,
  // ...
)

// Pour le fond de l'écran
Scaffold(
  backgroundColor: theme.scaffoldBackgroundColor,
  // ...
)

// Pour les couleurs de texte
Text(
  'Texte principal',
  style: TextStyle(
    color: isDarkMode
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight,
  ),
)

Text(
  'Texte secondaire',
  style: TextStyle(
    color: isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
  ),
)
```

#### **MAL** : Couleurs hardcodées

```dart
// NE PAS FAIRE
Container(
  color: Colors.white,  // Ne s'adapte pas au thème
  child: Text(
    'Texte',
    style: TextStyle(color: Colors.black),  // Illisible en mode sombre
  ),
)
```

### Utiliser les styles de texte

#### **BIEN** : Utiliser textTheme

```dart
// Grands titres
Text(
  'Titre principal',
  style: textTheme.displayLarge,
)

// Sous-titres
Text(
  'Sous-titre',
  style: textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)

// Corps de texte
Text(
  'Description',
  style: textTheme.bodyLarge?.copyWith(
    color: isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
  ),
)

// Petits textes
Text(
  'Note',
  style: textTheme.bodySmall,
)
```

#### **MAL** : Styles hardcodés

```dart
// NE PAS FAIRE
Text(
  'Titre',
  style: TextStyle(
    fontSize: 32,  // Pas cohérent avec le design system
    fontWeight: FontWeight.bold,
    color: Colors.black,  // Ne s'adapte pas
  ),
)
```

---

## Bonnes pratiques

### 1. Structure recommandée pour chaque page

```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Récupérer le thème
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // 2. Configurer la barre de statut
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        // 3. Utiliser le thème
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildBody(colorScheme, textTheme, isDarkMode),
      ),
    );
  }
  
  Widget _buildBody(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    // Votre contenu ici
    return Container();
  }
}
```

### 2. Boutons

```dart
// Bouton primaire
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: colorScheme.primary,
    foregroundColor: AppColors.white,
    elevation: 8,
    shadowColor: colorScheme.primary.withOpacity(0.4),
  ),
  child: Text('Bouton primaire'),
)

// Bouton secondaire
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: isDarkMode
        ? AppColors.surfaceDark
        : AppColors.surfaceLight,
    foregroundColor: isDarkMode
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight,
    elevation: 0,
  ),
  child: Text('Bouton secondaire'),
)

// Bouton texte
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: colorScheme.primary,
  ),
  child: Text('Bouton texte'),
)
```

### 3. Cards et Containers

```dart
// Card avec ombre adaptée
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: colorScheme.primary.withAlpha(25),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Text('Contenu'),
)
```

### 4. Dividers et séparateurs

```dart
Divider(
  color: isDarkMode
      ? AppColors.textSecondaryDark.withAlpha(76)
      : AppColors.textSecondaryLight.withAlpha(76),
  thickness: 1,
)
```

### 5. Images et logos

Pour les logos sur fond coloré, utiliser un conteneur avec la couleur de surface :

```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: colorScheme.surface,  // S'adapte au thème
    borderRadius: BorderRadius.circular(24),
  ),
  child: Image.asset('assets/logos/logo.png'),
)
```

---

## Exemples complets

### Exemple 1 : Page simple

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

class SimplePage extends StatelessWidget {
  const SimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Ma Page',
            style: textTheme.titleLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Titre principal',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Description avec texte secondaire',
                style: textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text('Action'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Exemple 2 : Card avec contenu

```dart
Widget _buildCard(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
      BoxShadow(
        color: isDarkMode
            ? Colors.black26
            : colorScheme.primary.withAlpha(25),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titre de la card',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Description de la card',
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    ),
  );
}
```

---

## Erreurs courantes

### Erreur 1 : Utiliser des couleurs hardcodées

```dart
// MAL
Container(
  color: Colors.white,
  child: Text('Texte', style: TextStyle(color: Colors.black)),
)

// BIEN
Container(
  color: colorScheme.surface,
  child: Text(
    'Texte',
    style: textTheme.bodyLarge,
  ),
)
```

### Erreur 2 : Ne pas vérifier isDarkMode

```dart
// MAL
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
  ),
)

// BIEN
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: isDarkMode
          ? AppColors.textSecondaryDark.withOpacity(0.3)
          : AppColors.textSecondaryLight.withOpacity(0.3),
    ),
  ),
)
```

### Erreur 3 : Styles de texte en dur

```dart
// MAL
Text(
  'Titre',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)

// BIEN
Text(
  'Titre',
  style: textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

---

## Couleurs disponibles

### AppColors

```dart
// Couleurs principales
AppColors.primary          // Couleur primaire (bleu)
AppColors.secondary        // Couleur secondaire
AppColors.accent          // Couleur d'accent

// Couleurs de fond
AppColors.backgroundLight  // Fond clair
AppColors.backgroundDark   // Fond sombre

// Couleurs de surface
AppColors.surfaceLight     // Surface claire (blanc)
AppColors.surfaceDark      // Surface sombre

// Couleurs de texte
AppColors.textPrimaryLight   // Texte principal clair
AppColors.textSecondaryLight // Texte secondaire clair
AppColors.textPrimaryDark    // Texte principal sombre
AppColors.textSecondaryDark  // Texte secondaire sombre

// Couleurs d'état
AppColors.success  // Vert (succès)
AppColors.error    // Rouge (erreur)
AppColors.warning  // Orange (avertissement)
AppColors.info     // Bleu (information)
```

### ColorScheme (via theme)

```dart
colorScheme.primary       // Couleur primaire
colorScheme.secondary     // Couleur secondaire
colorScheme.surface       // Couleur de surface
colorScheme.error         // Couleur d'erreur
colorScheme.onPrimary     // Texte sur primaire
colorScheme.onSurface     // Texte sur surface
```

---

## TextTheme disponible

```dart
textTheme.displayLarge    // 57px - Très grand titre
textTheme.displayMedium   // 45px - Grand titre
textTheme.displaySmall    // 36px - Titre
textTheme.headlineLarge   // 32px - En-tête large
textTheme.headlineMedium  // 28px - En-tête moyen
textTheme.headlineSmall   // 24px - En-tête petit
textTheme.titleLarge      // 22px - Titre large
textTheme.titleMedium     // 16px - Titre moyen
textTheme.titleSmall      // 14px - Titre petit
textTheme.bodyLarge       // 16px - Corps large
textTheme.bodyMedium      // 14px - Corps moyen
textTheme.bodySmall       // 12px - Corps petit
textTheme.labelLarge      // 14px - Label large
textTheme.labelMedium     // 12px - Label moyen
textTheme.labelSmall      // 11px - Label petit
```

---

## Changer le thème

### Dans les paramètres

```dart
import 'package:flutter_boilerplate/core/controllers/theme_controller.dart';

// Changer le thème
ThemeController.to.setThemeMode(0); // Système
ThemeController.to.setThemeMode(1); // Clair
ThemeController.to.setThemeMode(2); // Sombre

// Vérifier le mode actuel
bool isDark = ThemeController.to.isDarkMode(context);
int currentMode = ThemeController.to.themeMode;
```

---

## Ressources

- [Material Design 3](https://m3.material.io/)
- [Flutter ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html)

---

**Dernière mise à jour** : 2025-01-08


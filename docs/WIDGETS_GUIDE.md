# Guide des widgets réutilisables - Flutter Boilerplate

Ce document présente les widgets réutilisables disponibles dans `lib/shared/widgets/`.

---

## Table des matières

- [AppButton](#appbutton)
- [AppTextField](#apptextfield)
- [LoadingIndicator](#loadingindicator)
- [ErrorMessageWidget](#errormessagewidget)
- [OtpInputField](#otpinputfield)

---

## AppButton

**Fichier** : `lib/shared/widgets/app_button.dart`

### Description

Widget de bouton réutilisable adapté au thème de l'application. Supporte trois types de boutons avec adaptation automatique au mode clair/sombre.

### Types de boutons

```dart
enum AppButtonType {
  primary,    // Bouton avec fond coloré et élévation
  secondary,  // Bouton avec bordure et fond transparent
  text,       // Bouton texte sans fond ni bordure
}
```

### Propriétés

| Propriété | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `label` | `String` | Texte du bouton (requis) | - |
| `onPressed` | `VoidCallback?` | Action au clic | `null` |
| `type` | `AppButtonType` | Type de bouton | `primary` |
| `icon` | `IconData?` | Icône avant le label | `null` |
| `isLoading` | `bool` | Affiche un indicateur de chargement | `false` |
| `width` | `double?` | Largeur personnalisée | `double.infinity` |
| `height` | `double` | Hauteur du bouton | `56.0` |
| `backgroundColor` | `Color?` | Couleur de fond personnalisée | `null` |
| `foregroundColor` | `Color?` | Couleur du texte personnalisée | `null` |
| `animationDelay` | `int?` | Délai d'animation en ms | `null` |
| `borderRadius` | `double` | Rayon de bordure | `16.0` |

### Exemples

#### Bouton primaire

```dart
AppButton(
  label: "S'inscrire",
  icon: Icons.person_add_rounded,
  onPressed: () => register(),
  type: AppButtonType.primary,
)
```

#### Bouton secondaire

```dart
AppButton(
  label: 'Se connecter',
  icon: Icons.login_rounded,
  onPressed: () => login(),
  type: AppButtonType.secondary,
)
```

#### Bouton texte

```dart
AppButton(
  label: 'Continuer sans compte',
  icon: Icons.arrow_forward_rounded,
  onPressed: () => continueAsGuest(),
  type: AppButtonType.text,
  height: 48,
)
```

#### Bouton avec chargement

```dart
AppButton(
  label: 'Connexion',
  onPressed: _isLoading ? null : () => login(),
  isLoading: _isLoading,
  type: AppButtonType.primary,
)
```

#### Bouton avec animation

```dart
AppButton(
  label: 'Valider',
  onPressed: () => submit(),
  animationDelay: 500,  // Apparaît après 500ms
)
```

### Adaptation au thème

Le bouton s'adapte automatiquement au thème clair/sombre :

#### Bouton Primary

| Élément | Mode clair | Mode sombre |
|---------|------------|-------------|
| Fond | `colorScheme.primary` (bleu) | `colorScheme.primary` (bleu) |
| Texte/Icône | `white` | `white` |
| Élévation | 8 | 8 |
| Ombre | `primary.withAlpha(102)` | `primary.withAlpha(102)` |
| Fond (désactivé) | `surfaceLight.withAlpha(127)` | `surfaceDark.withAlpha(127)` |
| Texte (désactivé) | `textSecondaryLight.withAlpha(127)` | `textSecondaryDark.withAlpha(127)` |

**Note** : Le texte et les icônes sont toujours blancs sur fond primaire pour un contraste optimal.

#### Bouton Secondary

| Élément | Mode clair | Mode sombre |
|---------|------------|-------------|
| Fond | `surfaceLight` | `surfaceDark` |
| Texte | `colorScheme.onSurface` | `colorScheme.onSurface` |
| Bordure | `textSecondaryLight.withAlpha(76)` | `textSecondaryDark.withAlpha(76)` |
| Élévation | 0 | 0 |
| Texte (désactivé) | `textSecondaryLight.withAlpha(127)` | `textSecondaryDark.withAlpha(127)` |

#### Bouton Text

| Élément | Mode clair | Mode sombre |
|---------|------------|-------------|
| Texte | `colorScheme.primary` | `colorScheme.primary` |
| Texte (désactivé) | `textSecondaryLight.withAlpha(127)` | `textSecondaryDark.withAlpha(127)` |

**Note** : Le bouton utilise `colorScheme.onPrimary`, `colorScheme.onSurface` pour garantir un bon contraste automatique.

---

## AppTextField

**Fichier** : `lib/shared/widgets/app_text_field.dart`

### Description

Champ de texte réutilisable avec style cohérent et fonctionnalités intégrées.

### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `controller` | `TextEditingController` | Contrôleur du champ (requis) |
| `label` | `String` | Label du champ (requis) |
| `prefixIcon` | `IconData` | Icône préfixe (requis) |
| `isPassword` | `bool` | Champ mot de passe |
| `obscureText` | `bool` | Masquer le texte |
| `onTogglePassword` | `VoidCallback?` | Toggle visibilité |
| `validator` | `FormFieldValidator?` | Validation |
| `keyboardType` | `TextInputType` | Type de clavier |
| `maxLines` | `int?` | Nombre de lignes |
| `hintText` | `String?` | Texte d'aide |
| `enabled` | `bool` | Activer/désactiver |

### Exemples

#### Champ email

```dart
AppTextField(
  controller: _emailController,
  label: 'Email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    return null;
  },
)
```

#### Champ mot de passe

```dart
AppTextField(
  controller: _passwordController,
  label: 'Mot de passe',
  prefixIcon: Icons.lock,
  isPassword: true,
  obscureText: _obscurePassword,
  onTogglePassword: () {
    setState(() => _obscurePassword = !_obscurePassword);
  },
)
```

---

## LoadingIndicator

**Fichier** : `lib/shared/widgets/loading_indicator.dart`

### Description

Indicateur de chargement personnalisé adapté au thème.

### Propriétés

| Propriété | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `size` | `double` | Taille du cercle | `24.0` |
| `strokeWidth` | `double` | Épaisseur du trait | `2.0` |
| `color` | `Color?` | Couleur personnalisée | Couleur du thème |

### Exemples

```dart
// Indicateur par défaut
const LoadingIndicator()

// Indicateur personnalisé
LoadingIndicator(
  size: 40,
  strokeWidth: 3,
  color: AppColors.primary,
)

// Dans un bouton
if (isLoading)
  const LoadingIndicator(size: 20, strokeWidth: 2)
else
  const Text('Charger')
```

---

## ErrorMessageWidget

**Fichier** : `lib/shared/widgets/error_message_widget.dart`

### Description

Widget pour afficher les messages d'erreur avec style cohérent.

### Propriétés

| Propriété | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `message` | `String` | Message d'erreur (requis) | - |
| `icon` | `IconData?` | Icône personnalisée | `Icons.error_outline` |

### Exemples

```dart
// Message d'erreur simple
ErrorMessageWidget(
  message: 'Une erreur est survenue',
)

// Message avec icône personnalisée
ErrorMessageWidget(
  message: 'Connexion impossible',
  icon: Icons.wifi_off,
)

// Affichage conditionnel
if (errorMessage != null)
  ErrorMessageWidget(message: errorMessage!)
```

### Adaptation au thème

S'adapte automatiquement avec :
- Fond : `colorScheme.error.withAlpha(26)`
- Bordure : `colorScheme.error.withAlpha(79)`
- Icône et texte : `colorScheme.error`

---

## OtpInputField

**Fichier** : `lib/shared/widgets/otp_input_field.dart`

### Description

Champ de saisie de code OTP (One-Time Password) avec formatage automatique.

### Propriétés

Vérifier le fichier pour les propriétés exactes.

### Exemple

```dart
OtpInputField(
  controller: _otpController,
  length: 6,
  onCompleted: (code) {
    verifyOtp(code);
  },
)
```

---

## CustomAppBar

**Fichier** : `lib/shared/widgets/custom_app_bar.dart`

### Description

AppBar réutilisable adaptée au thème avec support de sous-titre, icônes et actions personnalisées.

### Variantes

#### CustomAppBar (basique)

AppBar standard avec personnalisation complète.

**Propriétés** :

| Propriété | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `title` | `String` | Titre de l'AppBar (requis) | - |
| `subtitle` | `String?` | Sous-titre optionnel | `null` |
| `leading` | `Widget?` | Widget à gauche | `null` |
| `actions` | `List<Widget>?` | Actions à droite | `null` |
| `backgroundColor` | `Color?` | Couleur de fond | `colorScheme.surface` |
| `elevation` | `double` | Élévation | `0` |
| `centerTitle` | `bool` | Centrer le titre | `false` |
| `titleIcon` | `Widget?` | Widget icône du titre | `null` |

**Exemple** :
```dart
CustomAppBar(
  title: 'Ma Page',
  subtitle: 'Description',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () => search(),
    ),
  ],
)
```

#### CustomAppBarWithAvatar

Variante spécialisée avec avatar circulaire et statut.

**Propriétés** :

| Propriété | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `title` | `String` | Titre (requis) | - |
| `subtitle` | `String` | Sous-titre (requis) | - |
| `statusColor` | `Color?` | Couleur du statut | `null` |
| `avatarIcon` | `IconData` | Icône de l'avatar | `Icons.smart_toy` |
| `actions` | `List<Widget>?` | Actions | `null` |

**Exemple** :
```dart
CustomAppBarWithAvatar(
  title: 'Assistant Kodjo AI',
  subtitle: 'En ligne',
  statusColor: AppColors.success,
  avatarIcon: Icons.smart_toy,
)
```

---

## Créer un nouveau widget réutilisable

### Structure recommandée

```dart
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

/// Description du widget.
///
/// Détails sur l'utilisation et le comportement.
///
/// Exemple :
/// ```dart
/// MyWidget(
///   param: 'value',
/// )
/// ```
class MyWidget extends StatelessWidget {
  /// Description du paramètre
  final String param;

  const MyWidget({
    super.key,
    required this.param,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      // Implémentation
    );
  }
}
```

### Conventions à respecter

1. **Documentation complète** avec description et exemple
2. **Adaptation au thème** via `Theme.of(context)`
3. **Utiliser `withAlpha`** au lieu de `withOpacity`
4. **Paramètres nommés** avec `required` si obligatoire
5. **Valeurs par défaut** sensées pour les paramètres optionnels
6. **Const constructor** si possible
7. **Tests unitaires** pour les widgets complexes

---

## Bonnes pratiques

### Composition vs héritage

Préférer la composition :

```dart
// BIEN
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Mon bouton',
      // Personnalisation
    );
  }
}

// MAL (éviter d'hériter de widgets Flutter)
class MyButton extends ElevatedButton {
  // ...
}
```

### Widgets paramétrables

Rendre les widgets flexibles avec des paramètres optionnels :

```dart
class MyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;  // Optionnel
  final VoidCallback? onTap;  // Optionnel
  final Color? customColor;  // Optionnel

  const MyWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.customColor,
  });
}
```

### Séparation des responsabilités

Un widget = une responsabilité :

```dart
// BIEN : Séparation claire
class UserCard extends StatelessWidget {
  // Affiche les infos utilisateur
}

class UserAvatar extends StatelessWidget {
  // Affiche uniquement l'avatar
}

// Utilisation
UserCard(
  avatar: UserAvatar(...),
  // ...
)
```

---

## Performance

### Widgets const

```dart
// BIEN : Widget const réutilisable
class MyIcon extends StatelessWidget {
  const MyIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.home);
  }
}

// Usage
const MyIcon()  // Peut être const
```

### Éviter les rebuilds inutiles

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // NE PAS créer de nouvelles instances à chaque build
    final theme = Theme.of(context);  // OK
    
    return Container(
      // Utiliser theme
    );
  }
}
```

---

## Tests

### Tester un widget

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';

void main() {
  testWidgets('AppButton affiche le label correctement', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Test',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('AppButton est désactivé quand onPressed est null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Test',
            onPressed: null,
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    
    expect(button.onPressed, isNull);
  });
}
```

---

## Checklist pour créer un widget

- [ ] Documentation complète avec description et exemple
- [ ] Paramètres bien documentés
- [ ] Adaptation au thème (colorScheme, textTheme)
- [ ] Utilisation de `withAlpha` au lieu de `withOpacity`
- [ ] Valeurs par défaut sensées
- [ ] Const constructor si possible
- [ ] Gestion des états (loading, disabled, etc.)
- [ ] Tests unitaires pour la logique complexe
- [ ] Accessibilité (Semantics, tooltips)

---

## Ressources

- [CODE_CONVENTIONS.md](./CODE_CONVENTIONS.md) : Conventions de code
- [THEME_GUIDE.md](./THEME_GUIDE.md) : Guide des thèmes
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

---

**Dernière mise à jour** : 2025-01-08


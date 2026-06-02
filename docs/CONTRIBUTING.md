# Guide de Contribution - Flutter Boilerplate

Ce document décrit les règles et conventions à suivre pour contribuer au projet Flutter Boilerplate.

## Table des matières

- [Règles de Commit](#règles-de-commit)
- [Règles de Push](#règles-de-push)
- [Conventions de Nommage](#conventions-de-nommage)
- [Structure des Branches](#structure-des-branches)
- [Processus de Review](#processus-de-review)

---

## Règles de Commit

### Format des Messages de Commit

Les messages de commit doivent suivre le format **Conventional Commits** :

```
<type>(<scope>): <description>

[corps optionnel]

[footer optionnel]
```

### Types de Commit

- **feat** : Nouvelle fonctionnalité
- **fix** : Correction de bug
- **docs** : Documentation uniquement
- **style** : Changements de formatage (espace, point-virgule, etc.)
- **refactor** : Refactorisation du code sans changement de fonctionnalité
- **perf** : Amélioration des performances
- **test** : Ajout ou modification de tests
- **chore** : Tâches de maintenance (dépendances, configuration, etc.)
- **ci** : Changements dans la configuration CI/CD
- **build** : Changements dans le système de build

### Exemples de Messages de Commit

```bash
# Bon
feat(product): ajout de la fiche détaillée produit
feat(auth): ajout du renouvellement de session
fix(theme): correction du mode sombre
feat(vendor): ajout du dashboard vendeur
docs(api): mise à jour de la documentation des endpoints
refactor(product): simplification du service de recherche
chore(deps): mise à jour de get et flutter

# Mauvais
fix bug
update
changements
WIP
```

### Règles Importantes

1. **Toujours commencer par un type** en minuscules
2. **Utiliser le présent de l'indicatif** : "ajoute" et non "ajouté"
3. **Ne pas terminer par un point** dans la description courte
4. **Limiter la description à 72 caractères** si possible
5. **Utiliser le corps pour expliquer le "pourquoi"** si nécessaire

### Exemple Complet

```bash
feat(product): ajout du comparateur de produits

- Implémentation de l'écran de comparaison
- Affichage côte à côte des spécifications techniques
- Gestion de la sélection de 2 à 3 produits
- Export PDF des comparaisons

Closes #123
```

---

## Règles de Push

### Avant de Pousser

1. **Vérifier que le code compile** :
   ```bash
   flutter analyze
   flutter test
   ```

2. **Vérifier qu'il n'y a pas de conflits** :
   ```bash
   git fetch origin
   git rebase origin/main  # ou votre branche principale
   ```

3. **Vérifier les fichiers sensibles** :
   - Ne jamais pousser `lib/core/constants/api.dart`
   - Vérifier qu'aucune clé API n'est dans le code
   - Vérifier les fichiers `.env` s'ils existent

### Processus de Push

1. **Créer une branche** pour votre fonctionnalité :
   ```bash
   git checkout -b feat/nom-de-la-fonctionnalite
   ```

2. **Faire des commits réguliers** avec des messages clairs

3. **Pousser la branche** :
   ```bash
   git push origin feat/nom-de-la-fonctionnalite
   ```

4. **Créer une Pull Request** sur GitHub

### Règles Importantes

- **Ne jamais pousser directement sur `main` ou `master`**
- **Toujours créer une branche** pour vos modifications
- **Pousser régulièrement** pour sauvegarder votre travail
- **Ne pas pousser de code cassé** ou non testé

---

## Conventions de Nommage

### Branches Git

Format : `<type>/<description-courte>`

- `feat/catalogue-produits`
- `feat/session-refresh`
- `fix/calcul-frais-livraison`
- `refactor/product-service`
- `docs/api-endpoints`

### Fichiers et Dossiers

- **Fichiers Dart** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Variables et fonctions** : `camelCase`
- **Constantes** : `UPPER_SNAKE_CASE`

### Exemples

```dart
// Fichier : product_controller.dart
class ProductController {
  static const String API_BASE_URL = 'https://api.example.com';
  
  final String _privateVariable = 'value';
  
  void publicMethod() {
    // ...
  }
}
```

---

## Structure des Branches

### Branches Principales

- **`main`** : Branche principale, toujours stable
- **`develop`** : Branche de développement (si applicable)

### Branches de Fonctionnalité

- **`feat/*`** : Nouvelles fonctionnalités
- **`fix/*`** : Corrections de bugs
- **`refactor/*`** : Refactorisations
- **`docs/*`** : Documentation
- **`chore/*`** : Tâches de maintenance

### Exemple de Workflow

```bash
# 1. Créer une branche depuis main
git checkout main
git pull origin main
git checkout -b feat/nouvelle-fonctionnalite

# 2. Développer et committer
git add .
git commit -m "feat(product): ajout de la recherche avancée"

# 3. Pousser la branche
git push origin feat/nouvelle-fonctionnalite

# 4. Créer une Pull Request sur GitHub
```

---

## Processus de Review

### Avant de Créer une Pull Request

1. **Vérifier que tout fonctionne localement**
2. **S'assurer que les tests passent**
3. **Vérifier qu'il n'y a pas de conflits**
4. **Mettre à jour la documentation** si nécessaire

### Contenu d'une Pull Request

- **Titre clair** : `feat(auth): ajout du renouvellement de session`
- **Description détaillée** :
  - Ce qui a été fait
  - Pourquoi cela a été fait
  - Comment tester
  - Captures d'écran si applicable

### Exemple de Description de PR

```markdown
## Description
Ajout du renouvellement de session avec stockage sécurisé du token.

## Changements
- Utilisation de SharedPreferences pour la sauvegarde locale
- Synchronisation automatique avec le backend à la connexion
- Gestion des erreurs d'expiration de session
- Redirection vers le flux auth si nécessaire

## Tests
- [x] Tests unitaires passent
- [x] Testé manuellement sur Android et iOS
- [x] Vérification de la persistance après redémarrage
- [x] Test de synchronisation avec le backend

## Captures d'écran
[Si applicable]
```

---

## Fichiers à Ne Jamais Commiter

- `lib/core/constants/api.dart` (contient les clés API)
- Fichiers `.env` ou de configuration locale
- Clés privées ou secrets
- Fichiers de build (`build/`, `.dart_tool/`)
- Fichiers de cache

**Note** : Utiliser `api.example.dart` comme modèle pour les autres développeurs.

---

## Scopes Recommandés pour Flutter Boilerplate

Pour faciliter la navigation dans l'historique, utilisez ces scopes :

- `product` : Catalogue et fiches produits
- `auth` : Authentification
- `order` : Commandes
- `theme` : Thèmes
- `vendor` : Espace vendeur
- `auth` : Authentification
- `user` : Profil utilisateur
- `delivery` : Livraison et logistique
- `search` : Recherche et filtres
- `review` : Avis et notations
- `messaging` : Messagerie
- `ui` : Composants UI réutilisables
- `routes` : Navigation
- `api` : Services API

---

## Ressources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)


---

## Questions ?

Si vous avez des questions sur les conventions, n'hésitez pas à :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement
- Consulter la documentation du projet

---

**Dernière mise à jour** : 2025-01-26


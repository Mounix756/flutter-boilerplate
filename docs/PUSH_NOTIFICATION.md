# Implémentation des Notifications Push
## Application E-commerce Flutter avec Firebase Cloud Messaging

---

## 1. Objectif

Mettre en place un système de notifications push :
- **Robuste** : gestion des erreurs et cas limites
- **Scalable** : architecture extensible pour de futurs besoins
- **Sécurisé** : gestion des tokens et authentification
- **Orienté UX** : expérience utilisateur optimale
- **Conforme** : respect des bonnes pratiques Android et iOS

### Cas d'usage e-commerce

- Suivi de commandes (statut, expédition, livraison)
- Promotions ciblées et offres spéciales
- Notifications transactionnelles (paiement, confirmation)
- Alertes de stock et disponibilité
- Rappels et notifications de service

---

## 2. Principe UX : Gestion intelligente des permissions

### 2.1 Problème du prompt système immédiat

**Problématique** : Le prompt natif affiché dès l'installation de l'application :

> « Souhaitez-vous autoriser cette application à envoyer des notifications ? »

**Conséquences** :
- Taux de refus élevé (utilisateur non informé de la valeur)
- Aucun contexte métier fourni
- Mauvaise expérience utilisateur
- Perte d'opportunité de réengagement

### 2.2 Approche professionnelle recommandée (Soft Prompt)

**Règle fondamentale** : Ne jamais demander la permission au lancement de l'application.

**Stratégie recommandée** :

1. **Afficher un écran explicatif interne** (soft prompt) avant la demande système
2. **Expliquer la valeur métier** : pourquoi les notifications sont utiles
3. **Déclencher le prompt système** uniquement après action utilisateur explicite
4. **Respecter le choix utilisateur** : ne pas redemander si refusé

### 2.3 Exemple d'interface utilisateur (soft prompt)

```
┌─────────────────────────────────┐
│  Restez informé                 │
│                                 │
│  Recevez des notifications sur :│
│  • l'état de vos commandes      │
│  • les promotions exclusives   │
│  • les nouveautés produits      │
│                                 │
│  [Activer les notifications]    │
│  [Plus tard]                    │
└─────────────────────────────────┘
```

---

## 3. Stack technique

- **Flutter** : 3.x
- **Firebase Cloud Messaging** : Service de notifications push
- **flutter_local_notifications** : Affichage des notifications locales
- **Backend sécurisé** : Firebase Admin SDK pour l'envoi

---

## 4. Dépendances Flutter

Ajouter les dépendances suivantes dans `pubspec.yaml` :

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^17.0.0
```

---

## 5. Initialisation Firebase

### 5.1 Configuration dans main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configuration du handler pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}
```

---

## 6. Architecture recommandée

Structure de fichiers proposée :

```
lib/
 ├── main.dart
 ├── app.dart
└── notifications/
    ├── notification_service.dart      # Service principal de notifications
    ├── permission_manager.dart        # Gestion des permissions
    └── notification_handler.dart      # Gestion de la navigation métier
```

---

## 7. Gestion professionnelle des permissions

### 7.1 permission_manager.dart

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionManager {
  static final _messaging = FirebaseMessaging.instance;

  /// Demande la permission de notification à l'utilisateur
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Vérifie si la permission est accordée
  static Future<bool> isGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Vérifie le statut actuel de la permission
  static Future<AuthorizationStatus> getStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }
}
```

---

## 8. Service de notifications

### 8.1 notification_service.dart

```dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_handler.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  /// Initialise le service de notifications
  static Future<void> initialize() async {
    await _initLocalNotifications();
    _initHandlers();
    await _syncToken();
  }

  /// Initialise les notifications locales
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _local.initialize(
      settings,
        onDidReceiveNotificationResponse: (response) {
      if (response.payload != null) {
        NotificationHandler.handle(jsonDecode(response.payload!));
      }
      },
    );
  }

  /// Initialise les handlers Firebase Messaging
  static void _initHandlers() {
    // Notification reçue lorsque l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_onForeground);

    // Notification cliquée lorsque l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => NotificationHandler.handle(msg.data),
    );

    // Vérifier si l'app a été ouverte via une notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        NotificationHandler.handle(message.data);
      }
    });
  }

  /// Gère les messages en arrière-plan
  static void handleBackgroundMessage(RemoteMessage message) {
    // Analytics, synchronisation silencieuse, etc.
    // Cette méthode est appelée dans un isolate séparé
  }

  /// Gère les notifications au premier plan
  static void _onForeground(RemoteMessage message) {
    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.data['title'] ?? 'Notification',
      message.data['body'] ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'orders',
          'Commandes',
          channelDescription: 'Notifications concernant vos commandes',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Synchronise le token FCM avec le backend
  static Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      // Envoyer le token au backend pour l'associer à l'utilisateur
      // Exemple : await ApiService.updateFcmToken(token);
    }

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      // Mettre à jour le token côté backend
      // Exemple : await ApiService.updateFcmToken(newToken);
    });
  }

  /// Supprime le token FCM
  static Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }
}
```

---

## 9. Navigation métier

### 9.1 notification_handler.dart

```dart
import 'package:flutter/material.dart';

class NotificationHandler {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Gère la navigation selon le type de notification
  static void handle(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final screen = data['screen'] as String?;

    switch (type) {
      case 'ORDER_STATUS':
        final orderId = data['order_id'] as String?;
        if (orderId != null) {
        navigatorKey.currentState?.pushNamed(
          '/order/details',
            arguments: orderId,
          );
        }
        break;

      case 'PROMOTION':
        if (screen != null) {
          navigatorKey.currentState?.pushNamed(screen);
        }
        break;

      case 'PRODUCT':
        final productId = data['product_id'] as String?;
        if (productId != null) {
          navigatorKey.currentState?.pushNamed(
            '/product/details',
            arguments: productId,
        );
        }
        break;

      default:
        // Navigation par défaut ou log
        break;
    }
  }
}
```

---

## 10. Payload Backend (Data Only)

### 10.1 Format recommandé

Utiliser des notifications **data-only** pour un contrôle total côté client :

```json
{
  "token": "FCM_TOKEN_UTILISATEUR",
  "data": {
    "type": "ORDER_STATUS",
    "title": "Commande expédiée",
    "body": "Votre commande #12345 est en route",
    "order_id": "12345",
    "screen": "/order/details"
  }
}
```

### 10.2 Types de notifications supportés

- `ORDER_STATUS` : Mise à jour du statut d'une commande
- `PROMOTION` : Promotion ou offre spéciale
- `PRODUCT` : Nouveau produit ou alerte stock
- `PAYMENT` : Notification transactionnelle
- `MESSAGE` : Message du vendeur ou support

---

## 11. Backend Node.js (Firebase Admin)

### 11.1 Exemple d'envoi de notification

```javascript
const admin = require('firebase-admin');

// Initialisation (une seule fois)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Envoi d'une notification
async function sendOrderStatusNotification(userToken, orderId, status) {
  try {
    await admin.messaging().send({
      token: userToken,
  data: {
        type: 'ORDER_STATUS',
        title: 'Commande expédiée',
    body: `Commande #${orderId} expédiée`,
    order_id: orderId,
        screen: '/order/details',
      },
    });
  } catch (error) {
    console.error('Erreur envoi notification:', error);
  }
}
```

### 11.2 Envoi en masse (topics)

```javascript
// S'abonner à un topic côté Flutter
await FirebaseMessaging.instance.subscribeToTopic('promotions');

// Envoyer à un topic côté backend
await admin.messaging().send({
  topic: 'promotions',
  data: {
    type: 'PROMOTION',
    title: 'Promotion flash',
    body: 'Réduction de 20% sur tous les PC portables',
    screen: '/promotions',
  },
});
```

---

## 12. Bonnes pratiques

### 12.1 Gestion des permissions

- **Soft prompt** avant permission système
- Explication claire de la valeur métier
- Respect du choix utilisateur
- Ne pas redemander si refusé

### 12.2 Notifications

- **Data-only notifications** pour un contrôle total
- Gestion des trois états : foreground, background, terminated
- Deep-linking contrôlé et sécurisé
- Payload structuré et typé

### 12.3 Sécurité

- **Token géré côté backend** uniquement
- Clés serveur jamais exposées
- Validation des Madonnées reçues
- Logs et monitoring des erreurs

### 12.4 Expérience utilisateur

- Notifications non intrusives
- Contenu pertinent et personnalisé
- Actions claires (navigation, boutons)
- Gestion des erreurs silencieuse

---

## 13. Erreurs critiques à éviter

### 13.1 Permissions

- **Prompt système au lancement** : taux de refus élevé
- Redemander la permission après refus sans contexte
- Ignorer le statut de permission

### 13.2 Sécurité

- **Envoi depuis Flutter** : utiliser le backend uniquement
- **Clé serveur exposée** : jamais dans le code client
- Tokens non sécurisés ou non validés

### 13.3 Architecture

- **Logique métier dans les notifications** : séparer les responsabilités
- Pas de gestion du refus utilisateur
- Handlers non testés ou incomplets
- Deep-linking non sécurisé

### 13.4 Expérience utilisateur

- Notifications trop fréquentes
- Contenu non personnalisé
- Pas de gestion des erreurs réseau
- Navigation cassée ou non fonctionnelle

---

## 14. Évolutions possibles

### 14.1 Fonctionnalités avancées

- **Notifications silencieuses** : synchronisation en arrière-plan
- **Actions dans les notifications** : boutons d'action rapide
- **Notifications groupées** : regroupement par type
- **Notifications programmées** : envoi différé

### 14.2 Analytics et optimisation

- **Feature flags** : activation/désactivation progressive
- **A/B testing** : optimisation du taux d'engagement
- **Analytics de conversion** : suivi e-commerce
- **Segmentation** : notifications ciblées par profil

### 14.3 Intégrations

- **Webhooks** : intégration avec services externes
- **Templates** : notifications pré-configurées
- **Multilingue** : notifications localisées
- **Rich media** : images et vidéos dans les notifications

---

## 15. Configuration Android

### 15.1 android/app/src/main/AndroidManifest.xml

```xml
<manifest>
  <application>
    <!-- Notification channel pour Android 8.0+ -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="orders" />
  </application>
</manifest>
```

### 15.2 android/app/build.gradle

```gradle
dependencies {
  implementation platform('com.google.firebase:firebase-bom:32.0.0')
  implementation 'com.google.firebase:firebase-messaging'
}
```

---

## 16. Configuration iOS

### 16.1 ios/Runner/Info.plist

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### 16.2 Capabilities

Activer les notifications push dans Xcode :
- Target → Signing & Capabilities → + Capability → Push Notifications

---

## 17. Tests

### 17.1 Tests unitaires

```dart
test('NotificationPermissionManager - requestPermission', () async {
  final granted = await NotificationPermissionManager.requestPermission();
  expect(granted, isA<bool>());
});
```

### 17.2 Tests d'intégration

- Tester les trois états de l'application (foreground, background, terminated)
- Vérifier la navigation après clic sur notification
- Valider la synchronisation du token

---

## 18. Monitoring et logs

### 18.1 Logs recommandés

- Échec d'envoi de notification
- Changement de token FCM
- Erreurs de permission
- Navigation après notification
- Taux d'engagement (clics, ouvertures)

### 18.2 Métriques à suivre

- Taux d'acceptation des permissions
- Taux d'ouverture des notifications
- Taux de conversion (notification → action)
- Taux de désabonnement

---

## 19. Conclusion

Une implémentation professionnelle de notifications push ne se limite pas à la technique. Elle combine :

- **UX** : expérience utilisateur optimale et non intrusive
- **Sécurité** : gestion sécurisée des tokens et données
- **Scalabilité** : architecture extensible et maintenable
- **Contrôle métier** : logique centralisée et testable

Cette approche garantit une intégration robuste des notifications push dans l'application e-commerce, améliorant l'engagement utilisateur et la rétention.

---

## 20. Ressources

- [Documentation Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Best Practices - Push Notifications](https://developer.apple.com/notifications/)

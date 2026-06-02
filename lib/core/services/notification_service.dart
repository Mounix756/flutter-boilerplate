import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_boilerplate/core/notifications/notification_handler.dart';
import 'package:flutter_boilerplate/core/notifications/notification_permission_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service centralisé pour gérer les notifications push (FCM) + affichage local.
///
/// Design “pro” (cf `docs/PUSH_NOTIFICATION.md`) :
/// - Ne **pas** déclencher le prompt système au lancement (soft prompt via UI)
/// - Gérer foreground / background / terminated
/// - Afficher une notification locale en foreground (data-only recommandé)
/// - Centraliser la navigation métier à partir du payload
/// - Mémoriser le token localement + écouter les refresh
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Channel Android utilisé par défaut (doit matcher le Manifest).
  ///
  /// IMPORTANT: sur Android, un channel est "figé" après création (son, importance…).
  /// Si vous changez ces paramètres, il faut **changer l'id** (ou supprimer le channel
  /// dans les réglages / réinstaller l'app).
  static const String androidDefaultChannelId = 'default_channel_v2';

  static const String _prefsLastFcmTokenKey = 'last_fcm_token';
  static bool _initialized = false;

  /// Handler appelé quand un message arrive en background/terminated.
  /// Important: exécuté dans un isolate séparé → pas de navigation UI ici.
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    try {
      // Assure l'initialisation Flutter dans l'isolate background.
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      // Si le backend envoie des messages "data-only", Android n'affiche rien par défaut.
      // IMPORTANT: si `message.notification != null`, Android affichera souvent déjà la
      // notification système → éviter les doublons.
      if (message.notification == null) {
        await _ensureLocalNotificationsForBackground();
        await _showLocalNotificationFromMessage(message);
      }
    } catch (_) {
      // Erreur silencieuse: ne pas crasher l’isolate background
    }
  }

  /// Initialise les notifications (sans demander la permission).
  ///
  /// À appeler après `Firebase.initializeApp()`.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();
    _initFirebaseHandlers();
    await _cacheCurrentToken();
    _listenTokenRefresh();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      // IMPORTANT: ne pas déclencher le prompt système ici
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.trim().isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          NotificationHandler.handle(data);
        } catch (_) {
          // payload invalide → ignorer
        }
      },
    );

    // Android: créer le channel par défaut (Android 8+)
    const androidChannel = AndroidNotificationChannel(
      androidDefaultChannelId,
      'Notifications',
      description: 'Notifications Flutter Boilerplate',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // iOS: data-only en foreground → on affiche en local, donc pas besoin d’alert système
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  static void _initFirebaseHandlers() {
    // Notification reçue quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Notification cliquée quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      if (msg.data.isNotEmpty) {
        NotificationHandler.handle(msg.data);
      }
    });

    // App ouverte depuis une notification (terminated)
    _messaging.getInitialMessage().then((msg) {
      if (msg != null && msg.data.isNotEmpty) {
        NotificationHandler.handle(msg.data);
      }
    });
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    // Ne pas afficher si permission non accordée (iOS/Android 13+)
    final granted = await NotificationPermissionManager.isGranted();
    if (!granted) {
      return;
    }

    // Data-only recommandé, fallback sur message.notification
    final title =
        (message.data['title'] as String?) ?? message.notification?.title;
    final body = (message.data['body'] as String?) ?? message.notification?.body;

    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    final payload = jsonEncode(message.data);

    await _showLocalNotification(
      title: title ?? 'Notification',
      body: body ?? '',
      payload: payload,
    );
  }

  static Future<void> _ensureLocalNotificationsForBackground() async {
    // Dans l'isolate background, on ré-initialise minimalement le plugin.
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    try {
      await _local.initialize(settings: settings);
    } catch (_) {
      // Ignorer: certains devices/versions peuvent refuser l'init dans certains états
    }

    // S'assurer que le channel existe (Android 8+)
    const androidChannel = AndroidNotificationChannel(
      androidDefaultChannelId,
      'Notifications',
      description: 'Notifications Flutter Boilerplate',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    try {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    } catch (_) {
      // Ignorer
    }
  }

  static (String? title, String? body) _extractTitleBody(RemoteMessage message) {
    final title = (message.data['title'] as String?)?.trim();
    final body = (message.data['body'] as String?)?.trim();

    final fallbackTitle = message.notification?.title?.trim();
    final fallbackBody = message.notification?.body?.trim();

    return (
      (title != null && title.isNotEmpty) ? title : fallbackTitle,
      (body != null && body.isNotEmpty) ? body : fallbackBody,
    );
  }

  static Future<void> _showLocalNotificationFromMessage(
    RemoteMessage message,
  ) async {
    final (title, body) = _extractTitleBody(message);
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final payload = jsonEncode(message.data);
    await _showLocalNotification(
      title: title ?? 'Notification',
      body: body ?? '',
      payload: payload,
    );
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          androidDefaultChannelId,
          'Notifications',
          channelDescription: 'Notifications Flutter Boilerplate',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Applique des subscriptions "topics" (optionnel) en fonction des préférences.
  ///
  /// Remarque: ceci nécessite une stratégie backend “topic-based”.
  static Future<void> applyTopicPreferences() async {
    final granted = await NotificationPermissionManager.isGranted();
    if (!granted) return;

    final prefs = await SharedPreferences.getInstance();
    final orders = prefs.getBool('notif_orders') ?? true;
    final promotions = prefs.getBool('notif_promotions') ?? true;
    final messages = prefs.getBool('notif_messages') ?? true;
    final stock = prefs.getBool('notif_stock') ?? true;

    await _setTopicEnabled('orders', orders);
    await _setTopicEnabled('promotions', promotions);
    await _setTopicEnabled('messages', messages);
    await _setTopicEnabled('stock', stock);
  }

  static Future<void> _setTopicEnabled(String topic, bool enabled) async {
    try {
      if (enabled) {
        await _messaging.subscribeToTopic(topic);
      } else {
        await _messaging.unsubscribeFromTopic(topic);
      }
    } catch (_) {
      // Erreur silencieuse (réseau / config)
    }
  }

  static Future<void> _cacheCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsLastFcmTokenKey, token);
    } catch (_) {
      // Erreur silencieuse
    }
  }

  static void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      if (newToken.trim().isEmpty) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsLastFcmTokenKey, newToken);
      } catch (_) {
        // Erreur silencieuse
      }
    });
  }

  /// Supprime le token FCM local (utile lors d’une déconnexion).
  ///
  /// Sans endpoint backend de “deregister”, c’est le meilleur moyen côté app
  /// d’éviter de continuer à recevoir des pushes pour l’ancien compte.
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsLastFcmTokenKey);
    } catch (_) {
      // Erreur silencieuse
    }
  }
}

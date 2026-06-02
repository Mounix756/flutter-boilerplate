import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestion “pro” des permissions notifications (soft prompt).
///
/// Règle: ne pas demander la permission au lancement.
/// La permission est demandée via une action utilisateur explicite (ex: settings).
class NotificationPermissionManager {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _prefsPromptedKey = 'notif_permission_prompted';

  static Future<AuthorizationStatus> getStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  static Future<bool> isGranted() async {
    final status = await getStatus();
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  static Future<bool> wasPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsPromptedKey) ?? false;
  }

  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsPromptedKey, true);
  }

  /// Demande la permission système.
  ///
  /// À appeler uniquement après un “soft prompt” (UI) et une action utilisateur.
  static Future<bool> requestPermission() async {
    await markPrompted();
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}


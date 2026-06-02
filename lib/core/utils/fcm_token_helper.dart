import 'package:firebase_messaging/firebase_messaging.dart';

/// Helper pour récupérer le token FCM (Firebase Cloud Messaging).
///
/// Fournit une méthode simple et sécurisée pour obtenir le token FCM
/// qui sera utilisé pour les notifications push.
class FcmTokenHelper {
  /// Récupère le token FCM actuel.
  ///
  /// Retourne :
  /// - [String?] : Le token FCM ou null si une erreur survient
  ///
  /// Exemple :
  /// ```dart
  /// final token = await FcmTokenHelper.getToken();
  /// if (token != null) {
  ///   // Utiliser le token
  /// }
  /// ```
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      // En cas d'erreur, retourner null plutôt que de lancer une exception
      // pour ne pas bloquer le processus d'inscription
      return null;
    }
  }
}

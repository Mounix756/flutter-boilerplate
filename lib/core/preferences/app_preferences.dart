import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion des préférences de l'application.
///
/// Utilise SharedPreferences pour persister les données localement
/// comme l'état de l'onboarding et la configuration utilisateur.
class AppPreferences {
  /// Clé pour stocker si l'utilisateur a vu l'onboarding
  static const String _onboardingSeenKey = 'onboarding_seen';

  /// Clé pour stocker si l'utilisateur a complété l'onboarding
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Clé pour stocker si l'utilisateur a choisi le mode invité
  static const String _guestModeKey = 'guest_mode';

  /// Vérifie si l'utilisateur a déjà vu l'onboarding.
  ///
  /// Retourne `true` si l'onboarding a été vu, `false` sinon.
  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  /// Vérifie si l'utilisateur a complété l'onboarding.
  ///
  /// Retourne `true` si l'onboarding a été complété, `false` sinon.
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marque l'onboarding comme vu et complété.
  ///
  /// Persiste l'information pour que l'utilisateur ne voie plus
  /// l'onboarding lors des prochains lancements de l'application.
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Vérifie si l'utilisateur a choisi le mode invité.
  ///
  /// Retourne `true` si l'utilisateur a choisi de continuer sans compte.
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  /// Active le mode invité (continuer sans compte).
  ///
  /// Persiste le choix pour éviter de redemander à chaque lancement.
  static Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, value);
  }

  /// Réinitialise les préférences d'onboarding.
  ///
  /// Utile pour le développement ou permettre à l'utilisateur
  /// de revoir l'onboarding.
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, false);
    await prefs.setBool(_onboardingCompletedKey, false);
  }

  /// Réinitialise toutes les préférences de l'application.
  ///
  /// Supprime l'onboarding et le mode invité.
  /// Utile pour la déconnexion complète ou le reset de l'app.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_boilerplate/core/localization/app_translations.dart';

/// Contrôleur de gestion de la langue de l'application.
///
/// Permet de changer la langue entre francais, anglais et arabe.
/// Les préférences sont persistées localement avec SharedPreferences.
///
/// Utilisation :
/// ```dart
/// // Récupérer le contrôleur
/// final langController = LanguageController.to;
///
/// // Changer la langue
/// langController.changeLanguage('fr_FR');
/// langController.changeLanguage('en_US');
/// langController.changeLanguage('ar_EG');
///
/// // Obtenir la langue actuelle
/// String current = langController.currentLanguage;
/// ```
class LanguageController extends GetxController {
  /// Getter statique pour accéder au contrôleur depuis n'importe où
  static LanguageController get to => Get.find();

  /// Clé de stockage dans SharedPreferences
  static const String _languageKey = 'app_language';

  /// Code de la langue actuelle
  final _currentLanguage = AppLanguages.french.obs;

  /// Retourne le code de la langue actuelle
  String get currentLanguage => _currentLanguage.value;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  /// Charge la langue sauvegardée depuis les préférences.
  ///
  /// Si aucune langue n'est sauvegardée, utilise le français par défaut.
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      _currentLanguage.value = savedLanguage;
      final locale = _getLocaleFromLanguageCode(savedLanguage);
      await Get.updateLocale(locale);
    }
  }

  /// Change la langue de l'application.
  ///
  /// Paramètres :
  /// - [languageCode] : Code de la langue (fr_FR, en_US, ar_EG)
  ///
  /// Met à jour l'interface et persiste le choix localement.
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage.value = languageCode;

    final locale = _getLocaleFromLanguageCode(languageCode);
    await Get.updateLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    update();
  }

  /// Convertit un code de langue en Locale Flutter.
  ///
  /// Exemples :
  /// - 'fr_FR' → Locale('fr', 'FR')
  /// - 'en_US' → Locale('en', 'US')
  /// - 'ar_EG' -> Locale('ar', 'EG')
  Locale _getLocaleFromLanguageCode(String languageCode) {
    final parts = languageCode.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }
}

import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/localization/languages/fr_translation.dart';
import 'package:flutter_boilerplate/core/localization/languages/en_translation.dart';
import 'package:flutter_boilerplate/core/localization/languages/ar_translation.dart';

/// Configuration des traductions de l'application.
///
/// Gère les traductions pour :
/// - Français (fr_FR)
/// - Anglais (en_US)
/// - Arabe (ar_EG)
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': frTranslation,
    'en_US': enTranslation,
    'ar_EG': arTranslation,
  };
}

/// Langues disponibles dans l'application.
class AppLanguages {
  static const String french = 'fr_FR';
  static const String english = 'en_US';
  static const String arabic = 'ar_EG';

  /// Liste de toutes les langues supportées.
  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': french,
      'name': 'Français',
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },
    {
      'code': english,
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇬🇧',
    },
    {'code': arabic, 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇪🇬'},
  ];

  /// Obtient le nom de la langue depuis son code.
  static String getLanguageName(String code) {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => supportedLanguages[0],
    );
    return lang['nativeName'] ?? 'Français';
  }

  /// Obtient le drapeau de la langue depuis son code.
  static String getLanguageFlag(String code) {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => supportedLanguages[0],
    );
    return lang['flag'] ?? '🇫🇷';
  }
}

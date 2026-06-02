import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Contrôleur de gestion du thème de l'application.
///
/// Permet de basculer entre les modes clair, sombre et système.
/// Les préférences sont persistées localement avec SharedPreferences.
///
/// Utilisation :
/// ```dart
/// // Récupérer le contrôleur
/// final themeController = ThemeController.to;
///
/// // Changer le thème
/// themeController.setThemeMode(0); // Système
/// themeController.setThemeMode(1); // Clair
/// themeController.setThemeMode(2); // Sombre
///
/// // Vérifier le mode actuel
/// bool isDark = themeController.isDarkMode(context);
/// ```
class ThemeController extends GetxController with WidgetsBindingObserver {
  /// Getter statique pour accéder au contrôleur depuis n'importe où
  static ThemeController get to => Get.find();

  /// Mode de thème actif
  /// - 0 = Système (suit le thème de l'appareil)
  /// - 1 = Clair (toujours en mode clair)
  /// - 2 = Sombre (toujours en mode sombre)
  final _themeMode = 0.obs;

  /// Retourne le mode de thème actuel
  int get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    // Ajouter l'observateur pour détecter les changements de thème système
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    // Retirer l'observateur lors de la destruction du contrôleur
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    // Callback appelé automatiquement quand le thème système change
    if (_themeMode.value == 0) {
      // Rafraîchir l'interface uniquement si en mode système
      update();
    }
  }

  /// Charge le mode de thème depuis les préférences locales.
  ///
  /// Si aucune préférence n'est trouvée, utilise le mode système (0) par défaut.
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode.value = prefs.getInt('themeMode') ?? 0;
  }

  /// Définit le mode de thème et persiste le choix localement.
  ///
  /// Paramètres :
  /// - [mode] : 0 = Système, 1 = Clair, 2 = Sombre
  ///
  /// Exemple :
  /// ```dart
  /// ThemeController.to.setThemeMode(2); // Passer en mode sombre
  /// ```
  Future<void> setThemeMode(int mode) async {
    _themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode);
    update(); // Rafraîchir l'interface
  }

  /// Retourne le ThemeData approprié selon le mode actuel.
  ///
  /// Si le mode est système, détecte automatiquement le thème de l'appareil.
  ThemeData getTheme(BuildContext context) {
    switch (_themeMode.value) {
      case 1:
        return AppTheme.lightTheme;
      case 2:
        return AppTheme.darkTheme;
      default:
        // Mode système : utilise le thème de l'appareil
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }

  /// Vérifie si le mode sombre est actif.
  ///
  /// Retourne :
  /// - `true` si le mode sombre est actif
  /// - `false` si le mode clair est actif
  ///
  /// Prend en compte le mode système si celui-ci est sélectionné.
  bool isDarkMode(BuildContext context) {
    switch (_themeMode.value) {
      case 1:
        return false;
      case 2:
        return true;
      default:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

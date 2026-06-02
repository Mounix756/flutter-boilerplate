import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_boilerplate/core/routes/app_routes.dart';
import 'package:flutter_boilerplate/core/constants/string.dart';
import 'package:flutter_boilerplate/core/controllers/theme_controller.dart';
import 'package:flutter_boilerplate/core/controllers/language_controller.dart';
import 'package:flutter_boilerplate/core/localization/app_translations.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/features/onboarding/splash_page.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/services/notification_service.dart';
import 'package:flutter_boilerplate/core/services/connectivity_service.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
// import 'package:flutter_boilerplate/features/groups/data/repositories/group_repository.dart';
// import 'package:flutter_boilerplate/features/groups/controllers/group_controller.dart';

/// Point d'entree principal du boilerplate Flutter.
///
/// Initialise tous les services nécessaires :
/// - API Client et repositories
/// - Services d'authentification
/// - Contrôleurs globaux (theme, auth, profile)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporter.initialize();

  await initializeDateFormatting();

  // Initialisation Firebase (FCM)
  await Firebase.initializeApp();

  // Handler pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );

  // Initialiser la couche notifications (sans demander la permission)
  await NotificationService.initialize();

  // Initialisation des contrôleurs en premier
  Get.put(ThemeController());
  Get.put(LanguageController());

  // Initialisation du service de connectivité
  final connectivityService = ConnectivityService();
  Get.put(connectivityService);
  await connectivityService.init();

  // Initialisation du client API
  final apiClient = ApiClient();
  Get.put(apiClient);

  // Initialisation du service d'authentification
  try {
    await Get.putAsync(() => AuthService().init());
  } catch (e) {
    ErrorReporter.reportWarning(
      'AuthService initialization failed',
      error: e,
    );
  }

  // Initialisation des repositories et contrôleurs
  try {
    // Initialiser ProfileRepository et ProfileController
    final profileRepository = ProfileRepository(apiClient: apiClient);
    Get.put(profileRepository);
    Get.put(ProfileController(profileRepository: profileRepository));
  } catch (e) {
    ErrorReporter.reportWarning(
      'Profile dependencies initialization failed',
      error: e,
    );
  }

  runApp(const MyApp());
}

/// Widget racine du boilerplate Flutter.
///
/// Configure le MaterialApp avec :
/// - Les thèmes clair et sombre
/// - La gestion du mode thème (système, clair, sombre)
/// - Les routes de navigation
/// - La page de démarrage (SplashPage)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(), // Fallback au cas où
      builder: (themeController) {
        return GetBuilder<LanguageController>(
          init: LanguageController(), // Fallback au cas où
          builder: (languageController) {
            return GetMaterialApp(
              title: StringConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode == 0
                  ? ThemeMode.system
                  : (themeController.themeMode == 1
                        ? ThemeMode.light
                        : ThemeMode.dark),
              // Configuration de la localisation
              translations: AppTranslations(),
              locale: languageController.currentLanguage.isNotEmpty
                  ? _getLocaleFromCode(languageController.currentLanguage)
                  : const Locale('fr', 'FR'),
              fallbackLocale: const Locale('fr', 'FR'),
              // La page de démarrage est le SplashPage qui gère la logique de navigation
              home: const SplashPage(),
              getPages: AppPages.routes,
            );
          },
        );
      },
    );
  }

  /// Convertit un code de langue en Locale.
  Locale _getLocaleFromCode(String code) {
    final parts = code.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }
}

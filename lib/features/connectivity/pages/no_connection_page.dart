import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/services/connectivity_service.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';

/// Page affichée lorsque l'utilisateur n'a pas de connexion internet.
///
/// Cette page informe l'utilisateur du problème de connexion et lui propose
/// de vérifier sa connexion internet. Elle surveille automatiquement la
/// reconnexion et redirige l'utilisateur vers la page principale une fois
/// la connexion rétablie.
///
/// Le retour est désactivé tant que la connexion n'est pas rétablie pour
/// éviter d'afficher des pages avec des erreurs de chargement.
class NoConnectionPage extends StatefulWidget {
  const NoConnectionPage({super.key});

  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements de connectivité
    _connectivityService.isConnected.listen((isConnected) {
      if (isConnected && mounted) {
        // Rediriger vers la page d'accueil et rafraîchir les données
        _navigateToHomeAndRefresh();
      }
    });
  }

  /// Navigue vers la page d'accueil sans refaire d'appels API.
  /// Les données déjà chargées dans les contrôleurs seront utilisées.
  Future<void> _navigateToHomeAndRefresh() async {
    // Naviguer vers la page principale (qui affiche la page d'accueil)
    // Les contrôleurs utiliseront les données déjà en cache
    Get.offAllNamed(AppRoutes.app);
  }

  /// Empêche le retour tant que la connexion n'est pas rétablie.
  Future<bool> _onWillPop() async {
    // Vérifier la connexion avant de permettre le retour
    await _connectivityService.checkConnectivity();
    
    if (_connectivityService.isConnected.value) {
      return true; // Permettre le retour
    }
    
    // Afficher un message si l'utilisateur essaie de revenir sans connexion
    if (mounted) {
      ModernNotification.showWarning(
        context,
        'cannot_go_back_without_connection'.tr,
      );
    }
    
    return false; // Empêcher le retour
  }

  /// Construit le widget leading (logo) pour l'AppBar
  Widget _buildLeadingWidget(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return IconButton(
      icon: Image.asset(
        isDarkMode
            ? AppImages.logoWhiteWithoutBackground
            : AppImages.logoWithoutBackground,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.shopping_bag_outlined,
            color: colorScheme.primary,
            size: 28,
          );
        },
      ),
      onPressed: () async {
        final canPop = await _onWillPop();
        if (canPop && mounted) {
          Get.back();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final canPop = await _onWillPop();
          if (canPop && mounted) {
            Get.back();
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: CustomAppBar.getSystemUiOverlayStyle(context),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: "Flutter Boilerplate",
            leading: _buildLeadingWidget(context, theme, colorScheme),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Illustration principale avec animation
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            AppColors.primary.withAlpha(26),
                            AppColors.primary.withAlpha(13),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cercle externe animé
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Icône principale
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(38),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Titre
                  Text(
                    'no_connection_title'.tr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'no_connection_message'.tr,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Bouton de vérification
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: _isChecking
                            ? 'checking_connection'.tr
                            : (_connectivityService.isConnected.value
                                ? 'connection_restored'.tr
                                : 'check_connection'.tr),
                        onPressed: _isChecking ? null : _checkConnection,
                        isLoading: _isChecking,
                        icon: Icons.refresh_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Vérifie la connexion et met à jour l'état.
  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });
    
    await _connectivityService.checkConnectivity();
    
    setState(() {
      _isChecking = false;
    });
    
    if (_connectivityService.isConnected.value) {
      // La connexion est rétablie, rediriger vers la page d'accueil
      _navigateToHomeAndRefresh();
    } else {
      // Afficher un message indiquant que la connexion n'est toujours pas disponible
      if (mounted) {
        ModernNotification.showError(
          context,
          'still_no_connection'.tr,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page d'options d'authentification affichée après l'onboarding.
///
/// Propose à l'utilisateur trois choix :
/// - Se connecter à un compte existant
/// - Créer un nouveau compte
/// - Continuer sans compte (accès limité)
class AuthOptionsPage extends StatelessWidget {
  const AuthOptionsPage({super.key});

  /// Navigation vers la page de connexion.
  void _navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  /// Navigation vers la page d'inscription.
  void _navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  /// Continuer sans authentification (accès limité).
  ///
  /// Permet à l'utilisateur de parcourir l'application sans créer de compte,
  /// avec des fonctionnalités limitées (pas d'achat, pas de favoris, etc.).
  /// Mémorise ce choix pour ne pas redemander au prochain lancement.
  Future<void> _continueAsGuest() async {
    await AppPreferences.setGuestMode(true);
    Get.offAllNamed(AppRoutes.app);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 700;
              final logoSize = isSmallScreen ? 80.0 : 100.0;
              final logoPadding = isSmallScreen ? 16.0 : 20.0;
              final topSpacing = isSmallScreen ? 20.0 : 40.0;
              final titleSpacing = isSmallScreen ? 20.0 : 30.0;
              final subtitleSpacing = isSmallScreen ? 12.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: topSpacing,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - topSpacing * 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo et titre
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                                padding: EdgeInsets.all(logoPadding),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withAlpha(76),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  isDarkMode
                                      ? AppImages.logoWhiteWithoutBackground
                                      : AppImages.logoWithoutBackground,
                                  width: logoSize,
                                  height: logoSize,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(delay: 200.ms),

                          SizedBox(height: titleSpacing),

                          // Titre
                          Text(
                                'auth_welcome'.tr,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),

                          SizedBox(height: subtitleSpacing),

                          // Sous-titre
                          Text(
                                'auth_subtitle'.tr,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  height: 1.5,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 32 : 48),

                      // Boutons d'action
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bouton S'inscrire
                          AppButton(
                            label: 'sign_up'.tr,
                            icon: Icons.person_add_rounded,
                            onPressed: _navigateToRegister,
                            type: AppButtonType.primary,
                            animationDelay: 700,
                          ),

                          const SizedBox(height: 16),

                          // Bouton Se connecter
                          AppButton(
                            label: 'sign_in'.tr,
                            icon: Icons.login_rounded,
                            onPressed: _navigateToLogin,
                            type: AppButtonType.secondary,
                            animationDelay: 900,
                          ),

                          const SizedBox(height: 24),

                          // Ligne de séparation avec "ou"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark.withAlpha(
                                          76,
                                        )
                                      : AppColors.textSecondaryLight.withAlpha(
                                          76,
                                        ),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or'.tr,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark.withAlpha(
                                          76,
                                        )
                                      : AppColors.textSecondaryLight.withAlpha(
                                          76,
                                        ),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Bouton Continuer sans compte
                          AppButton(
                            label: 'continue_as_guest'.tr,
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _continueAsGuest,
                            type: AppButtonType.text,
                            animationDelay: 1300,
                            height: 48,
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Note explicative
                      Text(
                        'guest_mode_note'.tr,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark.withAlpha(178)
                              : AppColors.textSecondaryLight.withAlpha(178),
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 1500.ms, duration: 400.ms),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

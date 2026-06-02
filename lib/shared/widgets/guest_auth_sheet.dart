import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';

/// Résultat possible lors de la fermeture du sheet (bouton choisi).
enum GuestAuthSheetResult {
  signIn,
  signUp,
}

/// Bottom sheet affiché lorsqu'un utilisateur non connecté (invité) tente
/// une action nécessitant une authentification (paiement, comparaison, etc.).
///
/// Affiche un titre, un message et deux boutons : S'inscrire et Se connecter.
/// Retourne [GuestAuthSheetResult] si l'utilisateur choisit une action, null
/// s'il ferme le sheet par glissement.
class GuestAuthSheet extends StatelessWidget {
  const GuestAuthSheet({super.key});

  /// Affiche le bottom sheet "Connexion requise" avec les options
  /// S'inscrire et Se connecter.
  ///
  /// Retourne [GuestAuthSheetResult.signIn] ou [GuestAuthSheetResult.signUp]
  /// si l'utilisateur tape un bouton, null s'il ferme le sheet sans choisir.
  ///
  /// À appeler lorsque [AuthService.isAuthenticated] est false et que
  /// l'action nécessite un compte (ex: checkout, comparaison de produits).
  static Future<GuestAuthSheetResult?> show(BuildContext context) {
    return showModalBottomSheet<GuestAuthSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const GuestAuthSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.login_rounded,
                size: 48,
                color: colorScheme.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              Text(
                'guest_login_sheet_title'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'guest_login_sheet_message'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'sign_in'.tr,
                icon: Icons.login,
                type: AppButtonType.primary,
                onPressed: () {
                  Navigator.of(context).pop(GuestAuthSheetResult.signIn);
                  Get.toNamed(AppRoutes.login);
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'sign_up'.tr,
                icon: Icons.person_add_rounded,
                type: AppButtonType.secondary,
                onPressed: () {
                  Navigator.of(context).pop(GuestAuthSheetResult.signUp);
                  Get.toNamed(AppRoutes.register);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

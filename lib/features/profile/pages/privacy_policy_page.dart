import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Page de politique de confidentialité.
///
/// Affiche les informations sur la collecte, l'utilisation et la protection
/// des données personnelles des utilisateurs de Flutter Boilerplate.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'privacy_policy'.tr),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction
                Text(
                  'privacy_policy_intro'.tr,
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Collecte des données
                _buildSectionTitle(theme, 'privacy_data_collection'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_data_collection_content'.tr,
                ),
                const SizedBox(height: 16),

                // Utilisation des données
                _buildSectionTitle(theme, 'privacy_data_usage'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_data_usage_content'.tr,
                ),
                const SizedBox(height: 16),

                // Partage des données
                _buildSectionTitle(theme, 'privacy_data_sharing'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_data_sharing_content'.tr,
                ),
                const SizedBox(height: 16),

                // Sécurité des données
                _buildSectionTitle(theme, 'privacy_data_security'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_data_security_content'.tr,
                ),
                const SizedBox(height: 16),

                // Vos droits
                _buildSectionTitle(theme, 'privacy_your_rights'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_your_rights_content'.tr,
                ),
                const SizedBox(height: 16),

                // Cookies et technologies similaires
                _buildSectionTitle(theme, 'privacy_cookies'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_cookies_content'.tr,
                ),
                const SizedBox(height: 16),

                // Modifications de la politique
                _buildSectionTitle(theme, 'privacy_changes'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_changes_content'.tr,
                ),
                const SizedBox(height: 16),

                // Contact
                _buildSectionTitle(theme, 'privacy_contact'.tr),
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme,
                  isDarkMode,
                  content: 'privacy_contact_content'.tr,
                ),
                const SizedBox(height: 24),

                // Date de mise à jour
                Text(
                  'privacy_last_updated'.tr.replaceAll('@date', '2026-03-11'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un titre de section.
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Construit une carte de section avec contenu.
  Widget _buildSectionCard(
    ThemeData theme,
    bool isDarkMode, {
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          height: 1.6,
        ),
      ),
    );
  }
}

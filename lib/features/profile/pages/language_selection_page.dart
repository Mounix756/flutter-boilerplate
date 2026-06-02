import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/controllers/language_controller.dart';
import 'package:flutter_boilerplate/core/localization/app_translations.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Page de sélection de la langue de l'application.
///
/// Permet à l'utilisateur de choisir entre :
/// - Français
/// - English
/// - العربية (Arabe)
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final languageController = LanguageController.to;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'language'.tr),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Description
            Text(
              'Choisissez votre langue préférée',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Options de langue
            Obx(
              () => Column(
                children: AppLanguages.supportedLanguages.map((lang) {
                  final isSelected =
                      languageController.currentLanguage == lang['code'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLanguageOption(
                      theme,
                      code: lang['code']!,
                      name: lang['name']!,
                      nativeName: lang['nativeName']!,
                      flag: lang['flag']!,
                      isSelected: isSelected,
                      onTap: () {
                        languageController.changeLanguage(lang['code']!);
                        Get.back();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Note explicative
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La langue sera appliquée immédiatement dans toute l\'application',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une option de langue.
  Widget _buildLanguageOption(
    ThemeData theme, {
    required String code,
    required String name,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(25)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Drapeau
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // Nom de la langue
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (name != nativeName) ...[
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Indicateur de sélection
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              )
            else
              Icon(Icons.circle_outlined, color: theme.dividerColor, size: 24),
          ],
        ),
      ),
    );
  }
}

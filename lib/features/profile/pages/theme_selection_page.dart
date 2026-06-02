import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/controllers/theme_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Page de sélection du thème de l'application.
///
/// Permet à l'utilisateur de choisir entre :
/// - Thème système (suit l'appareil)
/// - Thème clair (permanent)
/// - Thème sombre (permanent)
class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeController = ThemeController.to;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'appearance'.tr),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Description
            Text(
              'choose_theme'.tr,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Options de thème
            Obx(
              () => Column(
                children: [
                  _buildThemeOption(
                    theme,
                    title: 'system_theme'.tr,
                    subtitle: 'system_theme_desc'.tr,
                    icon: Icons.brightness_auto,
                    themeMode: 0,
                    isSelected: themeController.themeMode == 0,
                    onTap: () {
                      themeController.setThemeMode(0);
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    theme,
                    title: 'light_theme'.tr,
                    subtitle: 'light_theme_desc'.tr,
                    icon: Icons.light_mode,
                    themeMode: 1,
                    isSelected: themeController.themeMode == 1,
                    onTap: () {
                      themeController.setThemeMode(1);
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    theme,
                    title: 'dark_theme'.tr,
                    subtitle: 'dark_theme_desc'.tr,
                    icon: Icons.dark_mode,
                    themeMode: 2,
                    isSelected: themeController.themeMode == 2,
                    onTap: () {
                      themeController.setThemeMode(2);
                      Get.back();
                    },
                  ),
                ],
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
                      'system_theme_note'.tr,
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

  /// Construit une option de thème.
  Widget _buildThemeOption(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required int themeMode,
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
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
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

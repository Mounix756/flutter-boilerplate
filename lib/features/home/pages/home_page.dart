import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/constants/string.dart';
import 'package:flutter_boilerplate/features/notifications/widgets/notification_badge_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Accueil générique du boilerplate.
///
/// Cette page sert de vitrine technique légère pour les fondations disponibles.
/// Remplacez les cartes par les modules de votre produit.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: StringConstants.appName,
          useLegacyTitleStyle: true,
          actions: const [NotificationBadgeButton()],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withAlpha(45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: colorScheme.primary,
                    size: 34,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'welcome'.tr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    StringConstants.appDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'edit_profile'.tr,
                    icon: Icons.person_outline,
                    onPressed: () => Get.toNamed(AppRoutes.editProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Boilerplate modules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _FoundationTile(
              icon: Icons.lock_outline,
              title: 'Auth + guest mode',
              subtitle: 'Login, register, OTP, secure token storage.',
            ),
            _FoundationTile(
              icon: Icons.palette_outlined,
              title: 'Theme system',
              subtitle: 'Light, dark and system mode with persistence.',
            ),
            _FoundationTile(
              icon: Icons.translate_outlined,
              title: 'Localization',
              subtitle: 'French, English and Arabic ready with GetX.',
            ),
            _FoundationTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'FCM, local notifications and an in-app inbox.',
            ),
            _FoundationTile(
              icon: Icons.cloud_sync_outlined,
              title: 'API layer',
              subtitle: 'Dio client, auth interceptor, env config.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FoundationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FoundationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withAlpha(65)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

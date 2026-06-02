import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';

class AuthRequiredView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const AuthRequiredView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'sign_in'.tr,
                icon: Icons.login_rounded,
                onPressed: () => Get.toNamed(AppRoutes.login),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'sign_up'.tr,
                icon: Icons.person_add_alt_1_rounded,
                type: AppButtonType.secondary,
                onPressed: () => Get.toNamed(AppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

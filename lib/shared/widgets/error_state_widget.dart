import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

/// Widget réutilisable pour afficher un état d'erreur.
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final bool isNetworkError;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.actionLabel,
    this.onRetry,
    this.isNetworkError = false,
  });

  /// Factory pour les erreurs réseau.
  factory ErrorStateWidget.network({Key? key, VoidCallback? onRetry}) {
    return ErrorStateWidget(
      key: key,
      title: 'Pas de connexion',
      message:
          'Impossible de se connecter au serveur.\nVérifiez votre connexion internet et réessayez.',
      icon: Icons.wifi_off_rounded,
      actionLabel: 'Réessayer',
      onRetry: onRetry,
      isNetworkError: true,
    );
  }

  /// Factory pour les erreurs serveur.
  factory ErrorStateWidget.server({
    Key? key,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      key: key,
      title: 'Erreur serveur',
      message: message ?? 'Une erreur est survenue sur le serveur.',
      icon: Icons.cloud_off_outlined,
      actionLabel: 'Réessayer',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isNetworkError
                    ? Colors.orange.withAlpha(26)
                    : AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isNetworkError ? Colors.orange : AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNetworkError ? Colors.orange : AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNetworkError
                      ? Colors.orange
                      : AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

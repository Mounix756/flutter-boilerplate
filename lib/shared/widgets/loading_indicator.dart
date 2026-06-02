import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

/// Widget d'indicateur de chargement personnalisé.
///
/// Affiche un CircularProgressIndicator avec des options de personnalisation
/// pour la taille, l'épaisseur du trait et la couleur. S'adapte automatiquement
/// au thème clair ou sombre de l'application.
///
/// Exemple d'utilisation :
/// ```dart
/// LoadingIndicator(
///   size: 40,
///   strokeWidth: 3,
///   color: AppColors.primary,
/// )
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Taille du cercle de chargement en pixels
  final double size;

  /// Épaisseur du trait du cercle
  final double strokeWidth;

  /// Couleur personnalisée de l'indicateur.
  /// Si null, utilise la couleur du thème actif.
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ??
              (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
        ),
      ),
    );
  }
}

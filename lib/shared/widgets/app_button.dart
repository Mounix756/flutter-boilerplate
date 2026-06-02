import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Type de bouton définissant le style visuel.
enum AppButtonType {
  /// Bouton primaire avec fond coloré et élévation
  primary,

  /// Bouton secondaire avec fond transparent et bordure
  secondary,

  /// Bouton tertiaire sans fond ni bordure
  text,
}

/// Widget de bouton réutilisable adapté au thème de l'application.
///
/// Supporte trois types de boutons (primary, secondary, text) avec :
/// - Adaptation automatique au thème clair/sombre
/// - État de chargement intégré
/// - Support des icônes
/// - Animations optionnelles
/// - Personnalisation des couleurs
///
/// Exemple d'utilisation :
/// ```dart
/// AppButton(
///   label: 'Se connecter',
///   icon: Icons.login,
///   type: AppButtonType.primary,
///   onPressed: () => login(),
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Label du bouton
  final String label;

  /// Callback appelé lors du clic (null pour désactiver le bouton)
  final VoidCallback? onPressed;

  /// Type de bouton définissant le style
  final AppButtonType type;

  /// Icône optionnelle affichée avant le label (Material Icons)
  final IconData? icon;

  /// Icône personnalisée (Widget) affichée avant le label
  /// Prend la priorité sur [icon] si fourni
  final Widget? customIcon;

  /// État de chargement (affiche un indicateur circulaire)
  final bool isLoading;

  /// Largeur du bouton
  /// - null : prend toute la largeur disponible (match parent) - comportement par défaut
  /// - double.infinity : prend toute la largeur disponible (match parent)
  /// - -1 : s'adapte au contenu (pour Row/Align)
  /// - valeur numérique positive : largeur fixe en pixels
  final double? width;

  /// Hauteur du bouton
  final double height;

  /// Couleur de fond personnalisée (remplace la couleur par défaut du type)
  final Color? backgroundColor;

  /// Couleur du texte personnalisée
  final Color? foregroundColor;

  /// Délai avant l'animation d'apparition (en millisecondes)
  final int? animationDelay;

  /// Rayon de bordure
  final double borderRadius;
  final int labelMaxLines;
  final TextAlign labelTextAlign;
  final bool centerLabelWithIcon;
  final TextStyle? labelTextStyle;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.customIcon,
    this.isLoading = false,
    this.width,
    this.height = 56.0,
    this.backgroundColor,
    this.foregroundColor,
    this.animationDelay,
    this.borderRadius = 16.0,
    this.labelMaxLines = 1,
    this.labelTextAlign = TextAlign.center,
    this.centerLabelWithIcon = false,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Désactiver le bouton si loading ou onPressed est null
    final isDisabled = isLoading || onPressed == null;

    // Gérer la largeur :
    // - null ou double.infinity : match parent
    // - -1 : s'adapter au contenu (pas de contrainte de largeur)
    // - autre valeur : largeur fixe
    Widget button;
    if (width == -1) {
      // S'adapter au contenu (pour Row/Align)
      // Pour les TextButton, ne pas contraindre la hauteur pour éviter de couper le contenu
      if (type == AppButtonType.text) {
        button = SizedBox(
          child: _buildButton(
            context,
            theme,
            isDarkMode,
            colorScheme,
            textTheme,
            isDisabled,
          ),
        );
      } else {
        button = SizedBox(
          height: height,
          child: _buildButton(
            context,
            theme,
            isDarkMode,
            colorScheme,
            textTheme,
            isDisabled,
          ),
        );
      }
    } else {
      // Match parent par défaut (null = double.infinity) ou largeur fixe
      final buttonWidth = width ?? double.infinity;
      // Pour les TextButton, ne pas contraindre la hauteur pour éviter de couper le contenu
      if (type == AppButtonType.text) {
        button = SizedBox(
          width: buttonWidth,
          child: _buildButton(
            context,
            theme,
            isDarkMode,
            colorScheme,
            textTheme,
            isDisabled,
          ),
        );
      } else {
        button = SizedBox(
          width: buttonWidth,
          height: height,
          child: _buildButton(
            context,
            theme,
            isDarkMode,
            colorScheme,
            textTheme,
            isDisabled,
          ),
        );
      }
    }

    // Ajouter l'animation si un délai est spécifié
    if (animationDelay != null) {
      button = button
          .animate()
          .fadeIn(delay: animationDelay!.ms, duration: 600.ms)
          .slideY(begin: 0.3, end: 0);
    }

    return button;
  }

  /// Construit le bouton selon le type.
  Widget _buildButton(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDisabled,
  ) {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton(
          context,
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isDisabled,
        );
      case AppButtonType.secondary:
        return _buildSecondaryButton(
          context,
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isDisabled,
        );
      case AppButtonType.text:
        return _buildTextButton(
          context,
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isDisabled,
        );
    }
  }

  /// Bouton primaire avec fond coloré et élévation.
  Widget _buildPrimaryButton(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDisabled,
  ) {
    final bgColor = backgroundColor ?? colorScheme.primary;
    final fgColor = foregroundColor ?? AppColors.white;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isLoading) {
            return bgColor.withValues(alpha: 0.8);
          }
          if (states.contains(WidgetState.disabled)) {
            return isDarkMode
                ? AppColors.surfaceDark.withAlpha(127)
                : AppColors.surfaceLight.withAlpha(127);
          }
          return bgColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isLoading || states.contains(WidgetState.disabled)) {
            return isLoading
                ? fgColor
                : (isDarkMode
                      ? AppColors.textSecondaryDark.withAlpha(127)
                      : AppColors.textSecondaryLight.withAlpha(127));
          }
          return fgColor;
        }),
        elevation: WidgetStateProperty.resolveWith<double>((
          Set<WidgetState> states,
        ) {
          if (isLoading) return 4;
          if (states.contains(WidgetState.disabled)) return 0;
          return 8;
        }),
        shadowColor: WidgetStateProperty.all<Color>(
          colorScheme.primary.withAlpha(102),
        ),
        // Désactiver l'overlay blanc lors du clic
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return fgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return fgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      child: _buildButtonContent(colorScheme, isDarkMode, isDisabled),
    );
  }

  /// Bouton secondaire avec bordure et fond transparent.
  Widget _buildSecondaryButton(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDisabled,
  ) {
    final bgColor =
        backgroundColor ??
        (isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight);
    final fgColor = foregroundColor ?? colorScheme.onSurface;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isLoading) {
            return bgColor.withValues(alpha: 0.8);
          }
          return bgColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isLoading) {
            return fgColor;
          }
          if (states.contains(WidgetState.disabled)) {
            return isDarkMode
                ? AppColors.textSecondaryDark.withAlpha(127)
                : AppColors.textSecondaryLight.withAlpha(127);
          }
          return fgColor;
        }),
        elevation: WidgetStateProperty.all<double>(0),
        // Désactiver l'overlay blanc lors du clic
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return fgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return fgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isLoading
                  ? fgColor.withValues(alpha: 0.5)
                  : (isDisabled
                        ? (isDarkMode
                              ? AppColors.textSecondaryDark.withAlpha(51)
                              : AppColors.textSecondaryLight.withAlpha(51))
                        : (isDarkMode
                              ? AppColors.textSecondaryDark.withAlpha(76)
                              : AppColors.textSecondaryLight.withAlpha(76))),
              width: 1.5,
            ),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      child: _buildButtonContent(colorScheme, isDarkMode, isDisabled),
    );
  }

  /// Bouton texte sans fond ni bordure.
  Widget _buildTextButton(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDisabled,
  ) {
    // Calculer le padding vertical pour s'adapter à la hauteur
    // La hauteur du bouton moins la hauteur du contenu (environ 24px pour le texte)
    final contentHeight = 24.0; // Hauteur approximative du texte
    final verticalPadding = (height - contentHeight) / 2;
    final adjustedVerticalPadding = verticalPadding > 0 ? verticalPadding : 8.0;
    final fgColor = foregroundColor ?? colorScheme.primary;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isLoading) {
            return fgColor.withValues(alpha: 0.7);
          }
          if (states.contains(WidgetState.disabled)) {
            return isDarkMode
                ? AppColors.textSecondaryDark.withAlpha(127)
                : AppColors.textSecondaryLight.withAlpha(127);
          }
          return fgColor;
        }),
        // Désactiver l'overlay blanc lors du clic
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return fgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return fgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: 24,
            vertical: adjustedVerticalPadding.clamp(8.0, 16.0),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(Size(0, height)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _buildButtonContent(colorScheme, isDarkMode, isDisabled),
    );
  }

  /// Construit le contenu du bouton (loading, icône + texte, ou texte seul).
  Widget _buildButtonContent(
    ColorScheme colorScheme,
    bool isDarkMode,
    bool isDisabled,
  ) {
    // IMPORTANT : Ne pas utiliser textTheme qui contient une couleur définie
    // Créer un style qui hérite de foregroundColor du bouton
    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      // Pas de color - hérite du foregroundColor du bouton
    );
    final effectiveTextStyle = textStyle.merge(labelTextStyle);

    // Déterminer la couleur de l'indicateur de chargement selon le type
    Color loadingColor;
    if (type == AppButtonType.primary) {
      loadingColor = foregroundColor ?? AppColors.white;
    } else if (type == AppButtonType.secondary) {
      loadingColor = foregroundColor ?? colorScheme.onSurface;
    } else {
      loadingColor = foregroundColor ?? colorScheme.primary;
    }

    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: effectiveTextStyle,
              maxLines: labelMaxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: labelMaxLines > 1,
              textAlign: labelTextAlign,
            ),
          ),
        ],
      );
    }

    // Utiliser customIcon si fourni, sinon icon
    final hasIcon = customIcon != null || icon != null;

    if (hasIcon) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize:
            centerLabelWithIcon ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Utiliser customIcon si fourni, sinon icon
          customIcon ?? Icon(icon, size: 24),
          const SizedBox(width: 12),
          // Le texte hérite de foregroundColor du bouton
          if (centerLabelWithIcon)
            const SizedBox(width: 24),
          Flexible(
            child: Text(
              label,
              style: effectiveTextStyle,
              maxLines: labelMaxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: labelMaxLines > 1,
              textAlign: labelTextAlign,
            ),
          ),
          if (centerLabelWithIcon) const SizedBox(width: 36),
        ],
      );
    }

    return Text(
      label,
      style: effectiveTextStyle,
      maxLines: labelMaxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: labelMaxLines > 1,
      textAlign: labelTextAlign,
    );
  }
}

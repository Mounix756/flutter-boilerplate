import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar réutilisable adaptée au thème de l'application.
///
/// Supporte plusieurs variantes :
/// - AppBar simple avec titre
/// - AppBar avec icône et sous-titre
/// - AppBar avec actions personnalisées
/// - AppBar avec avatar
///
/// Exemple d'utilisation :
/// ```dart
/// CustomAppBar(
///   title: 'Mon titre',
///   subtitle: 'Sous-titre optionnel',
///   leadingIcon: Icons.menu,
///   actions: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Titre principal de l'AppBar
  final String title;

  /// Sous-titre optionnel affiché sous le titre
  final String? subtitle;

  /// Widget optionnel pour remplacer le sous-titre (ex: indicateur animé).
  final Widget? subtitleWidget;

  /// Icône à afficher avant le titre (remplace le bouton retour par défaut)
  final Widget? leading;

  /// Liste d'actions à afficher à droite de l'AppBar
  final List<Widget>? actions;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  /// Afficher une élévation
  final double elevation;

  /// Centrer le titre
  final bool centerTitle;

  /// Widget personnalisé pour l'icône du titre (ex: avatar, logo)
  final Widget? titleIcon;

  /// Couleur de l'icône du titre
  final Color? titleIconColor;

  /// Taille de l'icône du titre
  final double titleIconSize;

  /// Utiliser le style de titre historique pour certaines pages clés.
  final bool useLegacyTitleStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleIcon,
    this.titleIconColor,
    this.titleIconSize = 24.0,
    this.useLegacyTitleStyle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Génère le SystemUiOverlayStyle correspondant à la couleur de l'AppBar.
  static SystemUiOverlayStyle getSystemUiOverlayStyle(
    BuildContext context, {
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final bgColor = backgroundColor ?? colorScheme.surface;

    return SystemUiOverlayStyle(
      statusBarColor: bgColor,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget titleWidget;

    // Si sous-titre ou icône présents, construire un widget custom
    if (subtitle != null || titleIcon != null) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: centerTitle
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          // Icône du titre si présente
          if (titleIcon != null) ...[titleIcon!, const SizedBox(width: 12)],
          // Titre et sous-titre
          Flexible(
            child: Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: useLegacyTitleStyle
                      ? textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        )
                      : GoogleFonts.manrope(
                          textStyle: textTheme.titleMedium,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  subtitleWidget ??
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Titre simple
      titleWidget = Text(
        title,
        style: useLegacyTitleStyle
            ? textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              )
            : GoogleFonts.manrope(
                textStyle: textTheme.titleLarge,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
      );
    }

    final bgColor = backgroundColor ?? colorScheme.surface;
    final foregroundColor = colorScheme.primary;

    return AppBar(
      title: titleWidget,
      leading: leading,
      actions: actions,
      backgroundColor: bgColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      iconTheme: IconThemeData(color: foregroundColor),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

/// Variante de CustomAppBar avec avatar et statut en ligne.
///
/// Utilisée principalement pour les pages de chat ou de profil.
class CustomAppBarWithAvatar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Titre principal
  final String title;

  /// Sous-titre (ex: "En ligne", "Hors ligne")
  final String subtitle;

  /// Widget optionnel pour remplacer le sous-titre (ex: indicateur animé).
  final Widget? subtitleWidget;

  /// Couleur du statut (ex: vert pour "En ligne")
  final Color? statusColor;

  /// Icône de l'avatar
  final IconData avatarIcon;

  /// Actions à droite
  final List<Widget>? actions;

  const CustomAppBarWithAvatar({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleWidget,
    this.statusColor,
    this.avatarIcon = Icons.smart_toy,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      subtitleWidget: subtitleWidget,
      centerTitle: false,
      titleIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(avatarIcon, color: colorScheme.primary, size: 24),
      ),
      actions: actions,
    );
  }
}

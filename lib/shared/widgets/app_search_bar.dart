import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';

/// Barre de recherche réutilisable pour l'application.
///
/// Widget personnalisé pour les champs de recherche avec :
/// - Adaptation automatique au thème clair/sombre
/// - Bouton de suppression du texte
/// - Support des callbacks pour la recherche
/// - Style cohérent avec le reste de l'application
///
/// Exemple d'utilisation :
/// ```dart
/// AppSearchBar(
///   controller: _searchController,
///   hintText: 'search_services'.tr,
///   onChanged: (value) {
///     setState(() {
///       _searchQuery = value;
///     });
///   },
///   onClear: () {
///     setState(() {
///       _searchQuery = '';
///       _searchController.clear();
///     });
///   },
/// )
/// ```
class AppSearchBar extends StatefulWidget {
  /// Contrôleur du champ de texte
  final TextEditingController controller;

  /// Texte d'indication (placeholder)
  final String hintText;

  /// Callback appelé lorsque le texte change
  final ValueChanged<String>? onChanged;

  /// Callback appelé lors du clic sur le bouton de suppression
  final VoidCallback? onClear;

  /// Callback appelé lors du tap sur le champ (pour navigation)
  final VoidCallback? onTap;

  /// Si true, le champ est en lecture seule (pour navigation)
  final bool readOnly;

  /// FocusNode optionnel (permet de forcer le focus)
  final FocusNode? focusNode;

  /// Active le focus automatique du champ
  final bool autofocus;

  /// Widget suffix optionnel (ex: bouton filtre)
  final Widget? suffixIcon;

  /// Marge autour de la barre de recherche
  final EdgeInsetsGeometry? margin;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
    this.autofocus = false,
    this.suffixIcon,
    this.margin,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      margin: widget.margin ?? const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          suffixIcon: widget.suffixIcon ??
              (hasText && widget.onClear != null
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      onPressed: widget.onClear,
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

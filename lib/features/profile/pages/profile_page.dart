import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/controllers/language_controller.dart';
import 'package:flutter_boilerplate/core/controllers/theme_controller.dart';
import 'package:flutter_boilerplate/core/localization/app_translations.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/constants/string.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/services/google_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
import 'package:flutter_boilerplate/features/profile/data/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:flutter_boilerplate/shared/widgets/confirmation_bottom_sheet.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:share_plus/share_plus.dart';

/// Page de profil utilisateur.
///
/// Affiche les informations de l'utilisateur et permet d'accéder aux différentes
/// sections : commandes, favoris, paramètres, aide, etc.
/// Gère aussi le mode invité avec options d'authentification.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Charger l'état du mode invité
    _isGuestMode = await AppPreferences.isGuestMode();

    // Charger le profil si nécessaire
    await _loadProfileIfNeeded();

    // Mettre à jour l'UI si nécessaire
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProfileIfNeeded() async {
    final profileController = Get.find<ProfileController>();
    final authService = Get.find<AuthService>();

    // Recharger le profil si l'utilisateur est authentifié et que le profil n'est pas chargé
    if (authService.isAuthenticated &&
        !profileController.hasProfile &&
        !profileController.isLoading) {
      final success = await profileController.loadProfile();

      // Si le chargement échoue et que l'utilisateur n'est plus authentifié (JWT expiré),
      // activer le mode invité
      if (!success && !authService.isAuthenticated) {
        await AppPreferences.setGuestMode(true);
        _isGuestMode = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else if (!authService.isAuthenticated) {
      // Si l'utilisateur n'est pas authentifié, s'assurer que le mode invité est activé
      _isGuestMode = await AppPreferences.isGuestMode();
      if (!_isGuestMode) {
        await AppPreferences.setGuestMode(true);
        _isGuestMode = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = ThemeController.to;
    final languageController = LanguageController.to;
    final profileController = Get.find<ProfileController>();
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'profile'.tr,
        centerTitle: true,
        useLegacyTitleStyle: true,
      ),
      body: Builder(
        builder: (context) {
          final isGuest = _isGuestMode || !authService.isAuthenticated;

          return CustomScrollView(
            slivers: [
              // En-tête avec avatar et infos
              SliverToBoxAdapter(
                child: Obx(() {
                  return _buildProfileHeader(
                    context,
                    theme,
                    isGuest,
                    profileController.user,
                    profileController.isLoading,
                  );
                }),
              ),

              // Menu des options
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!isGuest) ...[
                      _buildSectionTitle(theme, 'my_account'.tr),
                      const SizedBox(height: 16),
                      _buildOptionCard(theme, [
                        _buildOptionTile(
                          theme,
                          icon: Icons.person_outline,
                          title: 'edit_profile'.tr,
                          onTap: () => Get.toNamed(AppRoutes.editProfile),
                        ),
                        _buildOptionTile(
                          theme,
                          icon: Icons.lock_outlined,
                          title: 'change_password'.tr,
                          onTap: () => Get.toNamed(AppRoutes.changePassword),
                        ),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle(theme, 'preferences'.tr),
                    const SizedBox(height: 16),
                    _buildOptionCard(theme, [
                      _buildOptionTile(
                        theme,
                        icon: Icons.palette_outlined,
                        title: 'theme'.tr,
                        trailing: Obx(() {
                          final currentMode = themeController.themeMode;
                          String label;
                          IconData icon;

                          switch (currentMode) {
                            case 0:
                              label = 'system_theme'.tr;
                              icon = Icons.brightness_auto;
                              break;
                            case 1:
                              label = 'light_theme'.tr;
                              icon = Icons.light_mode;
                              break;
                            case 2:
                              label = 'dark_theme'.tr;
                              icon = Icons.dark_mode;
                              break;
                            default:
                              label = 'system_theme'.tr;
                              icon = Icons.brightness_auto;
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }),
                        onTap: () => Get.toNamed(AppRoutes.themeSelection),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.notifications_outlined,
                        title: 'notifications'.tr,
                        onTap: () =>
                            Get.toNamed(AppRoutes.notificationSettings),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.language_outlined,
                        title: 'language'.tr,
                        trailing: Obx(() {
                          final currentLang =
                              languageController.currentLanguage;
                          final langName = AppLanguages.getLanguageName(
                            currentLang,
                          );

                          return Text(
                            langName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                        onTap: () => Get.toNamed(AppRoutes.languageSelection),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle(theme, 'information'.tr),
                    const SizedBox(height: 16),
                    _buildOptionCard(theme, [
                      _buildOptionTile(
                        theme,
                        icon: Icons.help_outline,
                        title: 'help_center'.tr,
                        onTap: () => Get.toNamed(AppRoutes.helpCenter),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.info_outline,
                        title: 'about'.tr,
                        onTap: () => Get.toNamed(AppRoutes.about),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.share_outlined,
                        title: 'share_app'.tr,
                        onTap: () => _shareApp(context),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.policy_outlined,
                        title: 'privacy_policy'.tr,
                        onTap: () => _openExternalUrl(
                          StringConstants.appPrivacyPolicyUrl,
                        ),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.description_outlined,
                        title: 'terms_of_service'.tr,
                        onTap: () => _openExternalUrl(
                          StringConstants.appTermsOfServiceUrl,
                        ),
                      ),
                      _buildOptionTile(
                        theme,
                        icon: Icons.person_remove_outlined,
                        title: 'request_account_deletion'.tr,
                        textColor: AppColors.error,
                        iconColor: AppColors.error,
                        onTap: () => _openAccountDeletionUrl(),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildOptionCard(theme, [
                      _buildOptionTile(
                        theme,
                        icon: isGuest ? Icons.login : Icons.logout,
                        title: isGuest ? 'sign_in'.tr : 'logout'.tr,
                        textColor: isGuest
                            ? theme.colorScheme.primary
                            : AppColors.error,
                        iconColor: isGuest
                            ? theme.colorScheme.primary
                            : AppColors.error,
                        onTap: () =>
                            isGuest ? _handleLogin() : _handleLogout(context),
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Extrait les initiales d'un utilisateur.
  String _getInitials(User? user) {
    if (user == null) return '?';
    final firstname = user.firstname.trim();
    final lastname = user.lastname.trim();

    if (firstname.isEmpty && lastname.isEmpty) return '?';
    if (firstname.isEmpty) return lastname[0].toUpperCase();
    if (lastname.isEmpty) return firstname[0].toUpperCase();

    return '${firstname[0].toUpperCase()}${lastname[0].toUpperCase()}';
  }

  /// Construit l'en-tête du profil avec avatar et informations.
  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    bool isGuest,
    User? user,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        // color: theme.colorScheme.primary.withAlpha(26),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  backgroundImage:
                      user?.image != null && user!.image!.isNotEmpty
                      ? CachedNetworkImageProvider(user.image!)
                      : null,
                  child: user?.image == null || user!.image!.isEmpty
                      ? (isGuest
                            ? Icon(
                                Icons.person_outline,
                                size: 50,
                                color: theme.colorScheme.primary,
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(user),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ))
                      : null,
                ),
              ),
              if (!isGuest && user != null && user.isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'active'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Nom et informations
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            )
          else
            Column(
              children: [
                // Nom complet
                Text(
                  isGuest
                      ? 'guest_mode'.tr
                      : (user != null && user.fullName.isNotEmpty
                            ? user.fullName
                            : 'Utilisateur'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Email (seulement si présent)
                if (!isGuest &&
                    user?.email != null &&
                    user!.email!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                // Téléphone (seulement si présent et pas un utilisateur Google)
                if (!isGuest &&
                    user?.phone != null &&
                    user!.phone.isNotEmpty &&
                    !user.isGoogleUser) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  /// Construit un titre de section.
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Construit une carte d'options.
  Widget _buildOptionCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.dividerColor.withAlpha(26),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Construit une option cliquable.
  Widget _buildOptionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Gère la connexion pour les utilisateurs invités.
  void _handleLogin() {
    Get.offAllNamed(AppRoutes.authOptions);
  }

  /// Gère la déconnexion de l'utilisateur.
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'logout'.tr,
      message: 'logout_confirm'.tr,
      confirmLabel: 'logout'.tr,
      cancelLabel: 'cancel'.tr,
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!confirmed) return;

    final authService = Get.find<AuthService>();
    await authService.logout();
    await GoogleAuthService.signOut();
    Get.find<ProfileController>().clearProfile();
    if (mounted) {
      setState(() {
        _isGuestMode = true;
      });
    }
    Get.offAllNamed(AppRoutes.authOptions);
  }

  /// Partage l'application.
  Future<void> _shareApp(BuildContext context) async {
    try {
      final shareText = 'share_text'.trParams({
        'url': StringConstants.appPlayStoreUrl,
      });
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e) {
      // Erreur silencieuse lors du partage
    }
  }

  Future<void> _openAccountDeletionUrl() async {
    await _openExternalUrl(StringConstants.appDeletionAccountUrl);
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && mounted) {
        ModernNotification.showError(
          context,
          'cannot_open_url'.tr,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        ModernNotification.showError(
          context,
          'cannot_open_url'.tr,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/string.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Page "À propos" affichant les informations sur l'application.
///
/// Présente :
/// - La description de l'application
/// - La mission et les valeurs
/// - Les informations sur l'entreprise
/// - La version de l'application
/// - Les liens vers les réseaux sociaux et le site web
/// - Les informations de contact
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'about'.tr),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo dans un cercle
                _buildLogoCircle(theme),
                const SizedBox(height: 16),

                // Description
                Text(
                  'about_description'.tr,
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReadMoreCta(theme, isDarkMode),
                const SizedBox(height: 16),

                // Mission
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSectionTitle(theme, 'about_mission_title'.tr),
                ),
                const SizedBox(height: 8),
                Text(
                  'about_mission'.tr,
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Points forts
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSectionTitle(theme, 'about_why_choose'.tr),
                ),
                const SizedBox(height: 12),
                _buildFeaturesSection(theme, isDarkMode),
                const SizedBox(height: 16),

                // Version
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: _buildSectionTitle(theme, 'app_info'.tr),
                // ),
                // const SizedBox(height: 16),
                // _buildVersionCard(theme, isDarkMode),
                // const SizedBox(height: 24),

                // Réseaux sociaux
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSectionTitle(theme, 'follow_us'.tr),
                ),
                const SizedBox(height: 12),
                _buildSocialLinks(theme, isDarkMode),
                const SizedBox(height: 16),

                // Contact
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSectionTitle(theme, 'contact_us'.tr),
                ),
                const SizedBox(height: 12),
                _buildContactInfo(theme, isDarkMode),
                const SizedBox(height: 24),

                // Copyright
                _buildCopyright(theme, isDarkMode),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit le logo dans un cercle.
  Widget _buildLogoCircle(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withAlpha(25),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(76),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(51),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            AppImages.logoWithoutBackground,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Construit un titre de section.
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Construit un CTA discret pour accéder à la page web "À propos".
  Widget _buildReadMoreCta(ThemeData theme, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => _launchUrl(StringConstants.appAuthorAbout),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.colorScheme.primary.withAlpha(22),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(56)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'read_more'.tr,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la section des points forts.
  Widget _buildFeaturesSection(ThemeData theme, bool isDarkMode) {
    final features = [
      {
        'icon': Icons.verified_user,
        'title': 'about_feature_verified'.tr,
        'description': 'about_feature_verified_desc'.tr,
      },
      {
        'icon': Icons.security,
        'title': 'about_feature_secure'.tr,
        'description': 'about_feature_secure_desc'.tr,
      },
      {
        'icon': Icons.local_shipping,
        'title': 'about_feature_logistics'.tr,
        'description': 'about_feature_logistics_desc'.tr,
      },
      {
        'icon': Icons.support_agent,
        'title': 'about_feature_support'.tr,
        'description': 'about_feature_support_desc'.tr,
      },
    ];

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
        children: features.map((feature) {
          final index = features.indexOf(feature);
          return Column(
            children: [
              _buildFeatureTile(
                theme,
                isDarkMode,
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
              ),
              if (index < features.length - 1)
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

  /// Construit une tuile de fonctionnalité.
  Widget _buildFeatureTile(
    ThemeData theme,
    bool isDarkMode, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les liens vers les réseaux sociaux.
  Widget _buildSocialLinks(ThemeData theme, bool isDarkMode) {
    final socialLinks = [
      {
        'icon': Icons.language,
        'label': 'website'.tr,
        'url': StringConstants.appAuthorWebsite,
      },
      if (StringConstants.appAuthorTwitter.isNotEmpty)
        {
          'icon': Icons.alternate_email,
          'label': 'Twitter',
          'url': StringConstants.appAuthorTwitter,
        },
      if (StringConstants.appAuthorFacebook.isNotEmpty)
        {
          'icon': Icons.facebook,
          'label': 'Facebook',
          'url': StringConstants.appAuthorFacebook,
        },
      if (StringConstants.appAuthorInstagram.isNotEmpty)
        {
          'icon': Icons.camera_alt_outlined,
          'label': 'Instagram',
          'url': StringConstants.appAuthorInstagram,
        },
      if (StringConstants.appAuthorLinkedin.isNotEmpty)
        {
          'icon': Icons.work_outline,
          'label': 'LinkedIn',
          'url': StringConstants.appAuthorLinkedin,
        },
    ];

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
        children: socialLinks.map((link) {
          final index = socialLinks.indexOf(link);
          return Column(
            children: [
              _buildSocialTile(
                theme,
                isDarkMode,
                icon: link['icon'] as IconData,
                label: link['label'] as String,
                onTap: () => _launchUrl(link['url'] as String),
              ),
              if (index < socialLinks.length - 1)
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

  /// Construit une tuile de réseau social.
  Widget _buildSocialTile(
    ThemeData theme,
    bool isDarkMode, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Construit les informations de contact.
  Widget _buildContactInfo(ThemeData theme, bool isDarkMode) {
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
        children: [
          _buildContactTile(
            theme,
            isDarkMode,
            icon: Icons.email_outlined,
            title: 'email_support'.tr,
            subtitle: StringConstants.appSupportEmail,
            onTap: () => _sendEmail(),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.dividerColor.withAlpha(26),
          ),
          _buildContactTile(
            theme,
            isDarkMode,
            icon: Icons.phone_outlined,
            title: 'phone_support'.tr,
            subtitle: StringConstants.appSupportPhone,
            onTap: () => _makePhoneCall(),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.dividerColor.withAlpha(26),
          ),
          _buildContactTile(
            theme,
            isDarkMode,
            icon: Icons.access_time_outlined,
            title: 'support_hours'.tr,
            subtitle: StringConstants.appSupportHours,
            onTap: null,
          ),
        ],
      ),
    );
  }

  /// Construit une tuile de contact.
  Widget _buildContactTile(
    ThemeData theme,
    bool isDarkMode, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Construit le copyright.
  Widget _buildCopyright(ThemeData theme, bool isDarkMode) {
    final year = DateTime.now().year.toString();
    final company = StringConstants.appName;
    final copyright = 'copyright'.tr
        .replaceAll('@year', year)
        .replaceAll('@company', company);
    return Text(
      copyright,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: isDarkMode
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }

  /// Lance une URL.
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && mounted) {
        Get.snackbar(
          'error'.tr,
          'cannot_open_url'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'cannot_open_url'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Envoie un email.
  Future<void> _sendEmail() async {
    try {
      final uri = Uri.parse('mailto:${StringConstants.appSupportEmail}');
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && mounted) {
        Get.snackbar(
          'error'.tr,
          'no_email_app'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'no_email_app'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Passe un appel téléphonique.
  Future<void> _makePhoneCall() async {
    try {
      final phoneNumber = StringConstants.appSupportPhone.replaceAll(' ', '');
      final uri = Uri.parse('tel:$phoneNumber');
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && mounted) {
        Get.snackbar(
          'error'.tr,
          'cannot_make_call'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'cannot_make_call'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}

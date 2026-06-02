import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_boilerplate/core/constants/string.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Page du centre d'aide affichant les FAQ et les options de contact.
///
/// Permet aux utilisateurs de :
/// - Consulter les questions fréquemment posées
/// - Contacter le support par différents moyens
/// - Voir les options de contact disponibles
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'help_center'.tr),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  'help_center_desc'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Section FAQ
                _buildSectionTitle(theme, 'frequently_asked_questions'.tr),
                const SizedBox(height: 16),
                _buildFAQSection(theme, isDarkMode),

                const SizedBox(height: 32),

                // Section Contact Support
                _buildSectionTitle(theme, 'contact_support'.tr),
                const SizedBox(height: 8),
                Text(
                  'contact_support_desc'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactSection(theme, isDarkMode),
              ],
            ),
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

  /// Construit la section des FAQ.
  Widget _buildFAQSection(ThemeData theme, bool isDarkMode) {
    final faqs = [
      {
        'question': 'faq_price_fixed'.tr,
        'answer': 'faq_price_fixed_answer'.tr,
      },
      {'question': 'faq_warranty'.tr, 'answer': 'faq_warranty_answer'.tr},
      {
        'question': 'faq_account_creation'.tr,
        'answer': 'faq_account_creation_answer'.tr,
      },
      {
        'question': 'faq_login_trouble'.tr,
        'answer': 'faq_login_trouble_answer'.tr,
      },
    ];

    return Column(
      children: faqs.map((faq) {
        return _buildFAQItem(
          theme,
          isDarkMode,
          question: faq['question']!,
          answer: faq['answer']!,
        );
      }).toList(),
    );
  }

  /// Construit un élément de FAQ.
  Widget _buildFAQItem(
    ThemeData theme,
    bool isDarkMode, {
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.primary,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section de contact.
  Widget _buildContactSection(ThemeData theme, bool isDarkMode) {
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
          // Email Support
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
          // Phone Support
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
          // Chat Support
          _buildContactTile(
            theme,
            isDarkMode,
            icon: Icons.chat_bubble_outline,
            title: 'chat_support'.tr,
            subtitle: StringConstants.appSupportHours,
            onTap: () => _startChat(),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Envoie un email au support.
  Future<void> _sendEmail() async {
    final email = StringConstants.appSupportEmail;
    final uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent('Demande d\'aide - Flutter Boilerplate')}',
    );

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch) {
        Get.snackbar(
          'error'.tr,
          'no_email_app'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'no_email_app'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Appelle le support.
  Future<void> _makePhoneCall() async {
    final phone = StringConstants.appSupportPhone.trim();
    final uri = Uri.parse('tel:$phone');

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch) {
        Get.snackbar(
          'error'.tr,
          'cannot_make_call'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'cannot_make_call'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Démarre le chat avec le support.
  void _startChat() {
    Get.snackbar(
      'coming_soon'.tr,
      'feature_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/notifications/notification_permission_manager.dart';
import 'package:flutter_boilerplate/core/services/notification_service.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page de gestion des paramètres de notifications.
///
/// Permet à l'utilisateur de configurer les types de notifications
/// qu'il souhaite recevoir (commandes, promotions, messages, etc.).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // États des différents types de notifications
  bool _ordersNotifications = true;
  bool _promotionsNotifications = true;
  bool _messagesNotifications = true;
  bool _stockNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;

  // Clés pour SharedPreferences
  static const String _ordersKey = 'notif_orders';
  static const String _promotionsKey = 'notif_promotions';
  static const String _messagesKey = 'notif_messages';
  static const String _stockKey = 'notif_stock';
  static const String _emailKey = 'notif_email';
  static const String _smsKey = 'notif_sms';

  bool _pushPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _refreshPermissionStatus();
  }

  Future<void> _refreshPermissionStatus() async {
    final granted = await NotificationPermissionManager.isGranted();
    if (!mounted) return;
    setState(() => _pushPermissionGranted = granted);
  }

  /// Charge les préférences de notifications depuis SharedPreferences.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ordersNotifications = prefs.getBool(_ordersKey) ?? true;
      _promotionsNotifications = prefs.getBool(_promotionsKey) ?? true;
      _messagesNotifications = prefs.getBool(_messagesKey) ?? true;
      _stockNotifications = prefs.getBool(_stockKey) ?? true;
      _emailNotifications = prefs.getBool(_emailKey) ?? true;
      _smsNotifications = prefs.getBool(_smsKey) ?? true;
    });
  }

  /// Sauvegarde une préférence de notification.
  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _enablePushNotifications() async {
    final granted = await NotificationPermissionManager.requestPermission();
    if (!mounted) return;

    setState(() => _pushPermissionGranted = granted);

    if (granted) {
      // Optionnel: appliquer topics selon préférences
      await NotificationService.applyTopicPreferences();
    } else {
      // Permission refusée: on laisse les toggles, mais aucune notif ne sera affichée
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'notifications'.tr),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Description
            Text(
              'notification_settings_desc'.tr,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Soft prompt (permission)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _pushPermissionGranted
                    ? AppColors.success.withAlpha(20)
                    : theme.colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pushPermissionGranted
                      ? AppColors.success.withAlpha(60)
                      : theme.colorScheme.primary.withAlpha(60),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _pushPermissionGranted
                        ? Icons.check_circle_outline
                        : Icons.notifications_outlined,
                    color: _pushPermissionGranted
                        ? AppColors.success
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pushPermissionGranted
                              ? 'push_notifications_enabled'.tr
                              : 'push_notifications_disabled'.tr,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'push_notifications_permission_desc'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_pushPermissionGranted)
                    FilledButton(
                      onPressed: _enablePushNotifications,
                      child: Text('enable'.tr),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications push
            _buildSectionTitle(theme, 'push_notifications'.tr),
            const SizedBox(height: 12),
            _buildNotificationCard(theme, [
              _buildNotificationTile(
                theme,
                icon: Icons.notifications_active_outlined,
                title: 'orders_notifications'.tr,
                subtitle: 'orders_notifications_desc'.tr,
                value: _ordersNotifications,
                onChanged: (value) {
                  setState(() => _ordersNotifications = value);
                  _savePreference(_ordersKey, value);
                  NotificationService.applyTopicPreferences();
                },
              ),
              _buildNotificationTile(
                theme,
                icon: Icons.local_offer_outlined,
                title: 'promotions_notifications'.tr,
                subtitle: 'promotions_notifications_desc'.tr,
                value: _promotionsNotifications,
                onChanged: (value) {
                  setState(() => _promotionsNotifications = value);
                  _savePreference(_promotionsKey, value);
                  NotificationService.applyTopicPreferences();
                },
              ),
              _buildNotificationTile(
                theme,
                icon: Icons.message_outlined,
                title: 'messages_notifications'.tr,
                subtitle: 'messages_notifications_desc'.tr,
                value: _messagesNotifications,
                onChanged: (value) {
                  setState(() => _messagesNotifications = value);
                  _savePreference(_messagesKey, value);
                  NotificationService.applyTopicPreferences();
                },
              ),
              _buildNotificationTile(
                theme,
                icon: Icons.system_update_alt_outlined,
                title: 'stock_notifications'.tr,
                subtitle: 'stock_notifications_desc'.tr,
                value: _stockNotifications,
                onChanged: (value) {
                  setState(() => _stockNotifications = value);
                  _savePreference(_stockKey, value);
                  NotificationService.applyTopicPreferences();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Autres canaux
            _buildSectionTitle(theme, 'other_channels'.tr),
            const SizedBox(height: 12),
            _buildNotificationCard(theme, [
              _buildNotificationTile(
                theme,
                icon: Icons.email_outlined,
                title: 'email_notifications'.tr,
                subtitle: 'email_notifications_desc'.tr,
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                  _savePreference(_emailKey, value);
                },
              ),
              _buildNotificationTile(
                theme,
                icon: Icons.sms_outlined,
                title: 'sms_notifications'.tr,
                subtitle: 'sms_notifications_desc'.tr,
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() => _smsNotifications = value);
                  _savePreference(_smsKey, value);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Note informative
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'notification_info'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  /// Construit une carte de notifications.
  Widget _buildNotificationCard(ThemeData theme, List<Widget> children) {
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

  /// Construit une option de notification avec switch.
  Widget _buildNotificationTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: theme.colorScheme.primary,
    );
  }
}

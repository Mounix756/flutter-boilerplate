import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/notifications/notification_handler.dart';
import 'package:flutter_boilerplate/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_boilerplate/features/notifications/models/app_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'notifications'.tr,
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'mark_all_notifications_read'.tr,
                icon: controller.isMarkingAllRead.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded),
                onPressed:
                    controller.unreadCount.value > 0 &&
                        !controller.isMarkingAllRead.value
                    ? () async {
                        final marked = await controller.markAllAsRead();
                        if (!marked && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'notification_mark_all_read_error'.tr,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.loadNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
                  _NotificationEmptyState(theme: theme, isDarkMode: isDarkMode),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: controller.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return Dismissible(
                  key: ValueKey(
                    notification.id.isEmpty
                        ? '${_safeTitle(notification)}-$index'
                        : notification.id,
                  ),
                  direction: DismissDirection.endToStart,
                  background: _DismissBackground(theme: theme),
                  confirmDismiss: (_) async {
                    final deleted = await controller.deleteNotification(
                      notification,
                    );
                    if (!deleted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('notification_delete_error'.tr)),
                      );
                    }
                    return deleted;
                  },
                  onDismissed: (_) => controller.removeLocal(notification),
                  child: _NotificationTile(
                    notification: notification,
                    onTap: () async {
                      final detail = await controller.openNotification(
                        notification,
                      );
                      final handled = await NotificationHandler.handlePayload(
                        _notificationPayload(detail),
                      );
                      if (context.mounted) {
                        if (!handled) {
                          _showNotificationDetails(context, detail);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    AppNotification notification,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final secondaryColor = isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _notificationIconForType(notification.type),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _safeTitle(notification),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (notification.type.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              notification.type,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _safeMessage(notification),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('close'.tr),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final timestampLabel = _notificationTimeLabel(notification);

    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: theme.cardColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: notification.isRead
                  ? theme.dividerColor.withAlpha(60)
                  : theme.colorScheme.primary.withAlpha(90),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _notificationIcon(notification.type),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _safeTitle(notification),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (timestampLabel.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Text(
                            timestampLabel,
                            maxLines: 1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _safeMessage(notification),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.25,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(String type) => _notificationIconForType(type);
}

String _safeTitle(AppNotification notification) {
  final title = notification.title.trim();
  return title.isEmpty ? 'notifications'.tr : title;
}

String _safeMessage(AppNotification notification) {
  final message = notification.message.trim();
  return message.isEmpty ? 'notification_empty_message'.tr : message;
}

String _notificationTimeLabel(AppNotification notification) {
  final date = notification.createdAt ?? notification.readAt;
  if (date == null) return '';

  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'notification_now'.tr;
  if (diff.inHours < 1) return '${diff.inMinutes} min';
  if (diff.inDays < 1) return '${diff.inHours} h';
  if (diff.inDays < 7) return '${diff.inDays} j';

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

IconData _notificationIconForType(String type) {
  if (type.startsWith('request.')) return Icons.handyman_outlined;
  if (type.startsWith('order.')) return Icons.shopping_bag_outlined;
  if (type.startsWith('payment.')) return Icons.payments_outlined;
  return Icons.notifications_none_rounded;
}

Map<String, dynamic> _notificationPayload(AppNotification notification) {
  return <String, dynamic>{
    ...notification.data,
    if (notification.id.trim().isNotEmpty) 'notification_id': notification.id,
    if (notification.type.trim().isNotEmpty) 'type': notification.type,
    if (notification.title.trim().isNotEmpty) 'title': notification.title,
    if (notification.message.trim().isNotEmpty) 'body': notification.message,
  };
}

class _DismissBackground extends StatelessWidget {
  final ThemeData theme;

  const _DismissBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: theme.colorScheme.onError,
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkMode;

  const _NotificationEmptyState({
    required this.theme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: isDarkMode
                ? AppColors.textSecondaryDark.withAlpha(150)
                : AppColors.textSecondaryLight.withAlpha(150),
          ),
          const SizedBox(height: 24),
          Text(
            'no_notifications'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'no_notifications_desc'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

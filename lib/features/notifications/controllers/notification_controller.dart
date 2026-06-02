import 'dart:async';

import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/features/notifications/models/app_notification.dart';
import 'package:flutter_boilerplate/features/notifications/repository/notification_repository.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;
  final AuthService _authService;

  NotificationController({
    NotificationRepository? repository,
    AuthService? authService,
  }) : _repository = repository ?? NotificationRepository(),
       _authService = authService ?? Get.find<AuthService>();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt unreadCount = 0.obs;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    _authWorker = ever<bool>(_authService.isAuthenticatedRx, (isAuthenticated) {
      if (isAuthenticated) {
        unawaited(loadNotifications());
      } else {
        _clear();
      }
    });
    unawaited(loadNotifications());
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  Future<void> loadNotifications({String query = ''}) async {
    if (!_authService.isAuthenticated) {
      _clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    final response = await _repository.getNotifications(query: query);
    notifications.assignAll(response.notifications);
    unreadCount.value = _countUnread(response.notifications);
    errorMessage.value = response.success ? null : response.message;
    isLoading.value = false;
  }

  Future<void> loadBadge() async {
    if (!_authService.isAuthenticated) {
      unreadCount.value = 0;
      return;
    }

    final response = await _repository.getAllNotifications();
    if (response.success) {
      unreadCount.value = _countUnread(response.notifications);
    }
  }

  Future<AppNotification> openNotification(AppNotification notification) async {
    if (notification.id.trim().isEmpty) return notification;
    AppNotification current = notification;
    if (!notification.isRead) {
      final response = await _repository.markAsRead([notification.id]);
      if (response.success) {
        current = notification.copyWith(readAt: DateTime.now());
        _replaceLocalNotification(current);
      } else {
        errorMessage.value = response.message;
      }
    }

    final detail = await _repository.getNotification(notification.id);
    if (detail == null) return current;
    final safeDetail = _mergeReadableNotification(current, detail);
    _replaceLocalNotification(safeDetail);
    return safeDetail;
  }

  void _replaceLocalNotification(AppNotification notification) {
    final index = notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (index != -1) {
      notifications[index] = notification;
      unreadCount.value = _countUnread(notifications);
    }
  }

  void removeLocal(AppNotification notification) {
    notifications.removeWhere((item) {
      if (notification.id.trim().isNotEmpty) return item.id == notification.id;
      return identical(item, notification);
    });
    unreadCount.value = _countUnread(notifications);
  }

  Future<bool> deleteNotification(AppNotification notification) async {
    if (notification.id.trim().isEmpty) {
      return true;
    }

    final response = await _repository.deleteNotification(notification.id);
    if (response.success) {
      return true;
    }

    errorMessage.value = response.message;
    return false;
  }

  Future<bool> markAllAsRead() async {
    if (!_authService.isAuthenticated || unreadCount.value == 0) {
      return true;
    }

    isMarkingAllRead.value = true;
    final response = await _repository.markAllAsRead();

    if (!response.success) {
      isMarkingAllRead.value = false;
      errorMessage.value = response.message;
      return false;
    }

    _markNotificationsReadLocally();

    final refreshed = await _repository.getNotifications();
    if (refreshed.success) {
      if (refreshed.notifications.isNotEmpty || notifications.isEmpty) {
        notifications.assignAll(refreshed.notifications);
        unreadCount.value = _countUnread(refreshed.notifications);
      }
      errorMessage.value = null;
    } else {
      errorMessage.value = refreshed.message;
    }

    isMarkingAllRead.value = false;
    return true;
  }

  void _markNotificationsReadLocally() {
    final readAt = DateTime.now();
    notifications.assignAll(
      notifications.map((notification) {
        if (notification.isRead) return notification;
        return notification.copyWith(readAt: readAt);
      }),
    );
    unreadCount.value = 0;
  }

  void _clear() {
    notifications.clear();
    unreadCount.value = 0;
    errorMessage.value = null;
    isLoading.value = false;
  }

  int _countUnread(List<AppNotification> items) {
    return items.where((notification) => !notification.isRead).length;
  }

  AppNotification _mergeReadableNotification(
    AppNotification original,
    AppNotification detail,
  ) {
    return AppNotification(
      id: detail.id.trim().isNotEmpty ? detail.id : original.id,
      title: detail.title.trim().isNotEmpty ? detail.title : original.title,
      message: detail.message.trim().isNotEmpty
          ? detail.message
          : original.message,
      type: detail.type.trim().isNotEmpty ? detail.type : original.type,
      data: detail.data.isNotEmpty ? detail.data : original.data,
      createdAt: detail.createdAt ?? original.createdAt,
      readAt: detail.readAt ?? original.readAt ?? DateTime.now(),
    );
  }
}

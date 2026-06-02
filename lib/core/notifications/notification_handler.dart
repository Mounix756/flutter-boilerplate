import 'dart:async';

import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:get/get.dart';

/// Routeur générique des notifications.
///
/// Les applications qui ajoutent des modules métier peuvent enrichir ce fichier
/// en fonction des `type`, `screen` ou `entity_type` reçus dans les payloads.
class NotificationHandler {
  static void handle(Map<String, dynamic> data) {
    unawaited(handlePayload(data));
  }

  static Future<bool> handlePayload(Map<String, dynamic> data) async {
    final payload = _normalizePayload(data);
    final target = _resolveTarget(payload);

    switch (target) {
      case _NotificationTarget.settings:
        _safeToNamed(AppRoutes.notificationSettings);
        return true;
      case _NotificationTarget.profile:
        _safeToNamed(AppRoutes.app, arguments: 1);
        return true;
      case _NotificationTarget.help:
        _safeToNamed(AppRoutes.helpCenter);
        return true;
      case _NotificationTarget.home:
        _safeToNamed(AppRoutes.app, arguments: 0);
        return true;
      case _NotificationTarget.inbox:
        _safeToNamed(AppRoutes.notificationsPage);
        return false;
    }
  }

  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{...data};
    final nestedData = data['data'];
    if (nestedData is Map) {
      nestedData.forEach((key, value) {
        normalized.putIfAbsent(key.toString(), () => value);
      });
    }
    return normalized;
  }

  static _NotificationTarget _resolveTarget(Map<String, dynamic> payload) {
    final type = _string(payload['type']).toLowerCase();
    final screen = _string(payload['screen']).toLowerCase();
    final entityType = _string(payload['entity_type']).toLowerCase();
    final route = _string(payload['route']).toLowerCase();
    final combined = '$type $screen $entityType $route';

    if (combined.contains('setting')) return _NotificationTarget.settings;
    if (combined.contains('profile') || combined.contains('account')) {
      return _NotificationTarget.profile;
    }
    if (combined.contains('support') || combined.contains('help')) {
      return _NotificationTarget.help;
    }
    if (combined.contains('home') || combined.contains('dashboard')) {
      return _NotificationTarget.home;
    }
    return _NotificationTarget.inbox;
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static void _safeToNamed(String route, {dynamic arguments}) {
    if (Get.currentRoute == route && arguments == null) return;
    Get.toNamed(route, arguments: arguments);
  }
}

enum _NotificationTarget { inbox, settings, profile, help, home }

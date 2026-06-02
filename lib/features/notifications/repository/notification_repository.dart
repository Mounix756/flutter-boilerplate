import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/constants/endpoint.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/features/notifications/models/app_notification.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String query = '',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userNotifications,
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          if (query.trim().isNotEmpty) 'query': query.trim(),
        },
      );

      return _parseListResponse(response.data);
    } on DioException catch (e) {
      return NotificationListResponse(
        success: false,
        notifications: const [],
        message: _extractMessage(e.response?.data),
      );
    } catch (_) {
      return const NotificationListResponse(
        success: false,
        notifications: [],
        message: 'Erreur lors du chargement des notifications.',
      );
    }
  }

  Future<NotificationListResponse> getAllNotifications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userNotificationsAll);
      return _parseListResponse(response.data);
    } on DioException catch (e) {
      return NotificationListResponse(
        success: false,
        notifications: const [],
        message: _extractMessage(e.response?.data),
      );
    } catch (_) {
      return const NotificationListResponse(
        success: false,
        notifications: [],
        message: 'Erreur lors du chargement des notifications.',
      );
    }
  }

  Future<AppNotification?> getNotification(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userNotificationById(id),
      );
      final payload = response.data;
      if (payload is Map<String, dynamic> && payload['data'] is Map) {
        return AppNotification.fromJson(
          Map<String, dynamic>.from(payload['data'] as Map),
        );
      }
      if (payload is Map) {
        return AppNotification.fromJson(Map<String, dynamic>.from(payload));
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<NotificationActionResponse> deleteNotification(String id) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.userNotificationById(id),
      );
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return NotificationActionResponse(
          success: payload['status'] == 'success' || payload['success'] == true,
          message: payload['message'] as String?,
        );
      }

      return const NotificationActionResponse(success: true);
    } on DioException catch (e) {
      return NotificationActionResponse(
        success: false,
        message: _extractMessage(
          e.response?.data,
          fallback: 'Erreur lors de la suppression de la notification.',
        ),
      );
    } catch (_) {
      return const NotificationActionResponse(
        success: false,
        message: 'Erreur lors de la suppression de la notification.',
      );
    }
  }

  Future<NotificationActionResponse> markAllAsRead() async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.userNotificationsMarkAllRead,
      );
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return NotificationActionResponse(
          success: payload['status'] == 'success' || payload['success'] == true,
          message: payload['message'] as String?,
        );
      }

      return const NotificationActionResponse(success: true);
    } on DioException catch (e) {
      return NotificationActionResponse(
        success: false,
        message: _extractMessage(
          e.response?.data,
          fallback: 'Erreur lors de la mise à jour des notifications.',
        ),
      );
    } catch (_) {
      return const NotificationActionResponse(
        success: false,
        message: 'Erreur lors de la mise à jour des notifications.',
      );
    }
  }

  Future<NotificationActionResponse> markAsRead(List<String> ids) async {
    final cleanIds = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (cleanIds.isEmpty) {
      return const NotificationActionResponse(success: true);
    }

    try {
      final response = await _apiClient.patch(
        ApiEndpoints.userNotificationsMarkRead,
        data: <String, dynamic>{'ids': cleanIds},
      );
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return NotificationActionResponse(
          success:
              payload['status'] == 'success' ||
              payload['success'] == true ||
              response.statusCode == 200,
          message: payload['message'] as String?,
        );
      }

      return NotificationActionResponse(success: response.statusCode == 200);
    } on DioException catch (e) {
      return NotificationActionResponse(
        success: false,
        message: _extractMessage(
          e.response?.data,
          fallback: 'Erreur lors de la mise à jour de la notification.',
        ),
      );
    } catch (_) {
      return const NotificationActionResponse(
        success: false,
        message: 'Erreur lors de la mise à jour de la notification.',
      );
    }
  }

  String _extractMessage(
    dynamic payload, {
    String fallback = 'Erreur lors du chargement des notifications.',
  }) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.isNotEmpty) return message;
      final errors = payload['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map<String, dynamic>) {
          final cleanMessage = first['clean_message'];
          if (cleanMessage is String && cleanMessage.isNotEmpty) {
            return cleanMessage;
          }
        }
      }
    }
    return fallback;
  }

  NotificationListResponse _parseListResponse(dynamic payload) {
    if (payload is List) {
      return NotificationListResponse(
        success: true,
        notifications: _notificationsFromList(payload),
      );
    }

    if (payload is Map<String, dynamic>) {
      final rawData = payload['data'];
      return NotificationListResponse(
        success: payload['status'] == 'success' || payload['success'] == true,
        notifications: rawData is List
            ? _notificationsFromList(rawData)
            : const [],
        message: payload['message'] as String?,
      );
    }

    return const NotificationListResponse(
      success: false,
      notifications: [],
      message: 'Réponse inattendue du serveur.',
    );
  }

  List<AppNotification> _notificationsFromList(List<dynamic> rawItems) {
    return rawItems
        .whereType<Map>()
        .map(
          (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}

class NotificationListResponse {
  final bool success;
  final List<AppNotification> notifications;
  final String? message;

  const NotificationListResponse({
    required this.success,
    required this.notifications,
    this.message,
  });
}

class NotificationActionResponse {
  final bool success;
  final String? message;

  const NotificationActionResponse({required this.success, this.message});
}

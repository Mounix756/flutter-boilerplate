import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final RegExp _bearerPattern = RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/=]+');
  static final RegExp _longNumberPattern = RegExp(r'\b\d{6,}\b');
  static final RegExp _jwtPattern = RegExp(r'eyJ[A-Za-z0-9_\-=]+\.([A-Za-z0-9_\-=]+)\.([A-Za-z0-9_\-=]+)?');
  static final RegExp _pathPattern = RegExp(r'(/[A-Za-z0-9._ -]+)+');

  static void info(String message, {Map<String, Object?> metadata = const {}}) {
    _log('INFO', message, metadata: metadata);
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    _log(
      'WARN',
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    _log(
      'ERROR',
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  static String sanitize(String value) {
    return value
        .replaceAll(_emailPattern, '****@****.***')
        .replaceAll(_bearerPattern, 'Bearer ***')
        .replaceAll(_jwtPattern, '***jwt***')
        .replaceAll(_longNumberPattern, '******')
        .replaceAll(_pathPattern, '/***');
  }

  static Map<String, Object?> sanitizeMetadata(Map<String, Object?> metadata) {
    final sanitized = <String, Object?>{};
    metadata.forEach((key, value) {
      sanitized[key] = _sanitizeValue(value);
    });
    return sanitized;
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null) return null;
    if (value is String) return sanitize(value);
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(
          key.toString(),
          _sanitizeValue(nestedValue),
        ),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    return sanitize(value.toString());
  }

  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    final sanitizedMetadata = sanitizeMetadata(metadata);
    final buffer = StringBuffer('[$level] ${sanitize(message)}');
    if (sanitizedMetadata.isNotEmpty) {
      buffer.write(' | metadata=$sanitizedMetadata');
    }
    if (error != null) {
      buffer.write(' | error=${sanitize(error.toString())}');
    }

    final text = buffer.toString();
    developer.log(
      text,
      name: 'flutter_boilerplate',
      error: error == null ? null : sanitize(error.toString()),
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint(text);
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}

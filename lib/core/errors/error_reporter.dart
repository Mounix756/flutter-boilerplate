import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';

class ErrorReporter {
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      reportError(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
        metadata: {
          'library': details.library,
          'context': details.context?.toDescription(),
        },
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      reportError(
        'Unhandled platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }

  static void reportError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    AppLogger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  static void reportWarning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    AppLogger.warning(
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }
}

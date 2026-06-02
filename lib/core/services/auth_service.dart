import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/services/google_auth_service.dart';
import 'package:flutter_boilerplate/core/services/notification_service.dart';

class AuthService extends GetxService {
  static const String authTokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _isAuthenticated = false.obs;
  final _isInitialized = false.obs;
  bool _isExpiringSession = false;

  bool get isAuthenticated => _isAuthenticated.value;
  bool get isInitialized => _isInitialized.value;
  RxBool get isAuthenticatedRx => _isAuthenticated;

  Future<AuthService> init() async {
    try {
      final token = await _secureStorage.read(key: authTokenKey);
      _isAuthenticated.value = token != null;
    } catch (e) {
      _isAuthenticated.value = false;
      ErrorReporter.reportWarning(
        'Unable to read auth token from secure storage',
        error: e,
      );
    } finally {
      _isInitialized.value = true;
    }
    return this;
  }

  Future<void> setAuthenticated(bool value) async {
    _isAuthenticated.value = value;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: authTokenKey);
    _isAuthenticated.value = false;
    await AppPreferences.setGuestMode(true);

    await GoogleAuthService.signOut();

    // Stopper la réception de pushes liés à l’ancien utilisateur (best effort)
    await NotificationService.deleteToken();
  }

  Future<void> expireSession({String reason = 'session_expired'}) async {
    if (_isExpiringSession) return;
    _isExpiringSession = true;

    try {
      await _secureStorage.delete(key: authTokenKey);
      _isAuthenticated.value = false;
      await AppPreferences.setGuestMode(false);
      await GoogleAuthService.signOut();
      await NotificationService.deleteToken();

      final currentRoute = Get.currentRoute;
      final isAlreadyInAuthFlow =
          currentRoute == AppRoutes.authOptions ||
          currentRoute == AppRoutes.login ||
          currentRoute == AppRoutes.register ||
          currentRoute == AppRoutes.forgotPassword ||
          currentRoute == AppRoutes.resetPassword ||
          currentRoute == AppRoutes.verifyOtp;

      if (!isAlreadyInAuthFlow) {
        Get.offAllNamed(AppRoutes.authOptions);
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportWarning(
        'Unable to expire auth session',
        error: e,
        stackTrace: stackTrace,
        metadata: {'reason': reason},
      );
    } finally {
      _isExpiringSession = false;
    }
  }
}

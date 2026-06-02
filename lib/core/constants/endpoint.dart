class ApiEndpoints {
  /// Authentification
  static const String login = 'auth/login';
  static const String loginWithGoogle = 'auth/login/google';
  static const String register = 'auth/register';
  static const String registerWithGoogle = 'auth/register/google';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyEmail = 'auth/verify-email';
  static const String verifyPhone = 'auth/verify-phone';
  static const String verifyCode = 'auth/verify-code';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String profile = 'auth/profile';
  static const String changePassword = 'auth/profile/password';
  static const String countries = '/countries';

  /// Notifications utilisateur
  static const String userNotifications = '/notification/user-notifications';
  static const String userNotificationsAll =
      '/notification/user-notifications/_all';
  static const String userNotificationsMarkAllRead =
      '/notification/user-notifications/mark-all-read';
  static const String userNotificationsMarkRead =
      '/notification/user-notifications/mark-read';
  static String userNotificationById(String id) =>
      '/notification/user-notifications/$id';
}

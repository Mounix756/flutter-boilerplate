import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/features/app/app_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/auth_options_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/forgot_password_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/login_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/register_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/reset_password_page.dart';
import 'package:flutter_boilerplate/features/auth/pages/verify_otp_page.dart';
import 'package:flutter_boilerplate/features/connectivity/pages/no_connection_page.dart';
import 'package:flutter_boilerplate/features/home/pages/home_page.dart';
import 'package:flutter_boilerplate/features/notifications/pages/notification_page.dart';
import 'package:flutter_boilerplate/features/onboarding/onboarding.dart';
import 'package:flutter_boilerplate/features/onboarding/splash_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/about_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/change_password_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/edit_profile_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/help_center_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/language_selection_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/notification_settings_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/privacy_policy_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/theme_selection_page.dart';

/// Routes conservées dans le noyau du boilerplate.
class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.authOptions,
      page: () => const AuthOptionsPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return VerifyOtpPage(
          registrationToken: args?['registrationToken'] as String? ?? '',
          otpMethod: args?['otpMethod'] as String? ?? 'sms',
          contact: args?['contact'] as String? ?? '',
        );
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.app,
      page: () => const AppHome(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notificationsPage,
      page: () => const NotificationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.themeSelection,
      page: () => const ThemeSelectionPage(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionPage(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsPage(),
      transition: Transition.native,
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterPage(),
      transition: Transition.native,
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutPage(),
      transition: Transition.native,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      transition: Transition.native,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.noConnection,
      page: () => const NoConnectionPage(),
      transition: Transition.fadeIn,
    ),
  ];
}

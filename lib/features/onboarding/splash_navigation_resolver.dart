import 'package:flutter_boilerplate/core/constants/routes.dart';

enum SplashDestination { app, authOptions, onboarding }

class SplashNavigationResolver {
  static SplashDestination resolve({
    required bool hasAuthToken,
    required bool isGuestMode,
    required bool isOnboardingCompleted,
  }) {
    if (hasAuthToken || isGuestMode) {
      return SplashDestination.app;
    }
    if (isOnboardingCompleted) {
      return SplashDestination.authOptions;
    }
    return SplashDestination.onboarding;
  }

  static String resolveRoute({
    required bool hasAuthToken,
    required bool isGuestMode,
    required bool isOnboardingCompleted,
  }) {
    final destination = resolve(
      hasAuthToken: hasAuthToken,
      isGuestMode: isGuestMode,
      isOnboardingCompleted: isOnboardingCompleted,
    );
    switch (destination) {
      case SplashDestination.app:
        return AppRoutes.app;
      case SplashDestination.authOptions:
        return AppRoutes.authOptions;
      case SplashDestination.onboarding:
        return AppRoutes.onboarding;
    }
  }
}

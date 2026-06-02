import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/features/onboarding/splash_navigation_resolver.dart';

void main() {
  test('authenticated users go directly to app', () {
    final route = SplashNavigationResolver.resolveRoute(
      hasAuthToken: true,
      isGuestMode: false,
      isOnboardingCompleted: false,
    );

    expect(route, AppRoutes.app);
  });

  test('completed onboarding without token goes to auth options', () {
    final route = SplashNavigationResolver.resolveRoute(
      hasAuthToken: false,
      isGuestMode: false,
      isOnboardingCompleted: true,
    );

    expect(route, AppRoutes.authOptions);
  });

  test('fresh user goes to onboarding', () {
    final route = SplashNavigationResolver.resolveRoute(
      hasAuthToken: false,
      isGuestMode: false,
      isOnboardingCompleted: false,
    );

    expect(route, AppRoutes.onboarding);
  });
}

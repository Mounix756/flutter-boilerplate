/// Exemple de configuration API pour le boilerplate.
///
/// Pour un developpement local:
/// 1. Copiez ce fichier vers `lib/core/constants/api.dart`.
/// 2. Ne mettez jamais de vraie cle dans les `defaultValue`.
/// 3. Injectez les valeurs avec `--dart-define` ou `--dart-define-from-file`.
///
/// Exemple:
/// flutter run \
///   --dart-define=APP_API_BASE_URL=https://api.example.com/api/v1/ \
///   --dart-define=APP_API_KEY=change-me
class ApiConstants {
  static const bool isReleaseBuild = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => _requiredUrl(
    'APP_API_BASE_URL',
    const String.fromEnvironment('APP_API_BASE_URL'),
    debugFallback: 'https://example.invalid/api/v1/',
  );

  static String get baseImageUrl => _requiredUrl(
    'APP_BASE_IMAGE_URL',
    const String.fromEnvironment('APP_BASE_IMAGE_URL'),
    debugFallback: 'https://example.invalid/sliders/',
  );

  static String get apiKey => _requiredValue(
    'APP_API_KEY',
    const String.fromEnvironment('APP_API_KEY'),
    debugFallback: 'APP_API_KEY_NOT_CONFIGURED',
  );

  static String get baseOnboardingImageUrl => _requiredUrl(
    'APP_BASE_ONBOARDING_IMAGE_URL',
    const String.fromEnvironment('APP_BASE_ONBOARDING_IMAGE_URL'),
    debugFallback: 'https://example.invalid/onboarding/',
  );

  static String get baseBannerImageUrl => _requiredUrl(
    'APP_BASE_BANNER_IMAGE_URL',
    const String.fromEnvironment('APP_BASE_BANNER_IMAGE_URL'),
    debugFallback: 'https://example.invalid/banner/',
  );

  static String get baseProductImageUrl => _requiredUrl(
    'APP_BASE_PRODUCT_IMAGE_URL',
    const String.fromEnvironment('APP_BASE_PRODUCT_IMAGE_URL'),
    debugFallback: 'https://example.invalid/',
  );

  static String get googleClientId => _requiredValue(
    'APP_GOOGLE_CLIENT_ID',
    const String.fromEnvironment('APP_GOOGLE_CLIENT_ID'),
    debugFallback: 'APP_GOOGLE_CLIENT_ID_NOT_CONFIGURED',
  );

  static String get googleApiKey => _requiredValue(
    'APP_GOOGLE_API_KEY',
    const String.fromEnvironment('APP_GOOGLE_API_KEY'),
    debugFallback: 'APP_GOOGLE_API_KEY_NOT_CONFIGURED',
  );

  static Uri get apiBaseUri => Uri.parse(baseUrl);

  static Set<String> get trustedApiHosts {
    final hosts = <String>{
      if (apiBaseUri.host.isNotEmpty) apiBaseUri.host,
      Uri.parse(baseImageUrl).host,
      Uri.parse(baseOnboardingImageUrl).host,
      Uri.parse(baseBannerImageUrl).host,
      Uri.parse(baseProductImageUrl).host,
    };
    hosts.removeWhere((host) => host.trim().isEmpty);
    return hosts;
  }

  static String _requiredUrl(
    String name,
    String value, {
    required String debugFallback,
  }) {
    final resolved = _requiredValue(name, value, debugFallback: debugFallback);
    final uri = Uri.tryParse(resolved);
    if (uri == null || uri.scheme != 'https' || uri.host.trim().isEmpty) {
      throw StateError('$name must be a valid HTTPS URL.');
    }
    return resolved;
  }

  static String _requiredValue(
    String name,
    String value, {
    required String debugFallback,
  }) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (isReleaseBuild) {
      throw StateError('$name must be provided with --dart-define.');
    }
    return debugFallback;
  }
}

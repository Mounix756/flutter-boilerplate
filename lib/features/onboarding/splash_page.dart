import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/features/onboarding/splash_navigation_resolver.dart';
import 'package:flutter_boilerplate/features/onboarding/widgets/splash_brand_content.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Page de splash screen affichée au démarrage de l'application.
///
/// Gère la logique de navigation initiale :
/// - Vérifie l'authentification de l'utilisateur
/// - Vérifie si l'onboarding a été complété
/// - Redirige vers la page appropriée
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _masterController; // séquenceur 0→1 en 2600ms
  late AnimationController _pulseController; // loop infini 1800ms
  late AnimationController _orbitController; // loop infini 3600ms
  late AnimationController _shimmerController; // loop infini 1400ms

  // ── Animations dérivées du _masterController ─────────────────────────────
  late Animation<double> _bgFade;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textReveal;
  late Animation<double> _taglineReveal;
  late Animation<double> _barReveal;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  /// Initialise les animations du splash screen.
  void _initializeAnimations() {
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _bgFade = _interval(0.00, 0.20);
    _logoOpacity = _interval(0.10, 0.45);
    _logoScale = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.10, 0.45, curve: Curves.elasticOut),
    );
    _textReveal = _interval(0.45, 0.70, curve: Curves.easeOutCubic);
    _taglineReveal = _interval(0.60, 0.82, curve: Curves.easeOutCubic);
    _barReveal = _interval(0.75, 1.00, curve: Curves.easeOutCubic);
    _exitFade = _interval(0.93, 1.00, curve: Curves.easeInQuart);

    _masterController.forward();
  }

  Animation<double> _interval(
    double begin,
    double end, {
    Curve curve = Curves.easeOut,
  }) => CurvedAnimation(
    parent: _masterController,
    curve: Interval(begin, end, curve: curve),
  );

  /// Détermine la prochaine route à afficher selon l'état de l'application.
  ///
  /// Vérifie dans l'ordre :
  /// 1. Si l'utilisateur est authentifié → Page principale
  /// 2. Si l'utilisateur a choisi le mode invité → Page principale
  /// 3. Si l'onboarding est complété → Options d'authentification
  /// 4. Sinon → Onboarding
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    try {
      final secureStorage = const FlutterSecureStorage();
      final token = await secureStorage.read(key: AuthService.authTokenKey);
      final isGuestMode = await AppPreferences.isGuestMode();
      final isOnboardingCompleted =
          await AppPreferences.isOnboardingCompleted();
      final route = SplashNavigationResolver.resolveRoute(
        hasAuthToken: token != null && token.isNotEmpty,
        isGuestMode: isGuestMode,
        isOnboardingCompleted: isOnboardingCompleted,
      );
      Get.offAllNamed(route);
    } catch (e) {
      ErrorReporter.reportWarning(
        'Splash navigation fallback triggered',
        error: e,
      );
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final Color bg1 = isDarkMode
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final Color bg2 = isDarkMode
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _masterController,
            _pulseController,
            _orbitController,
            _shimmerController,
          ]),
          builder: (context, _) {
            return Opacity(
              opacity: (1.0 - _exitFade.value).clamp(0.0, 1.0),
              child: Stack(
                children: [
                  // ── 1. Fond dégradé animé ───────────────────────────
                  _MeshBackground(
                    opacity: _bgFade.value,
                    bg1: bg1,
                    bg2: bg2,
                    brand: colorScheme.primary,
                    accent: colorScheme.secondary,
                    isDark: isDarkMode,
                    animValue: _orbitController.value,
                  ),

                  // ── 2. Grille géométrique subtile ───────────────────
                  CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _GridPainter(
                      color: isDarkMode ? AppColors.white : colorScheme.primary,
                      opacity: _bgFade.value * (isDarkMode ? 0.06 : 0.04),
                    ),
                  ),

                  // ── 3. Contenu central ──────────────────────────────
                  SafeArea(
                    child: SplashBrandContent(
                      logoOpacity: _logoOpacity.value,
                      logoScale: _logoScale.value,
                      pulseProgress: _pulseController.value,
                      orbitProgress: _orbitController.value,
                      shimmerProgress: _shimmerController.value,
                      textReveal: _textReveal.value,
                      taglineReveal: _taglineReveal.value,
                      barReveal: _barReveal.value,
                      loadingProgress: _masterController.value,
                      brand: colorScheme.primary,
                      accent: colorScheme.secondary,
                      surface: colorScheme.surface,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fond avec dégradé + orbes flottants animés
// ─────────────────────────────────────────────────────────────────────────────
class _MeshBackground extends StatelessWidget {
  const _MeshBackground({
    required this.opacity,
    required this.bg1,
    required this.bg2,
    required this.brand,
    required this.accent,
    required this.isDark,
    required this.animValue,
  });

  final double opacity;
  final Color bg1, bg2, brand, accent;
  final bool isDark;
  final double animValue;

  @override
  Widget build(BuildContext context) {
    final shift = math.sin(animValue * 2 * math.pi);

    return Opacity(
      opacity: opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fond dégradé de base (reprend le style original)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bg1, brand.withAlpha(isDark ? 35 : 22), bg1],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Orbe haut-droite
          Positioned(
            top: -80 + shift * 20,
            right: -60 + shift * 15,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brand.withAlpha(isDark ? 60 : 40),
              ),
            ),
          ),

          // Orbe bas-gauche
          Positioned(
            bottom: -110 - shift * 20,
            left: -70 + shift * 10,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withAlpha(isDark ? 45 : 30),
              ),
            ),
          ),

          // Petit carré arrondi haut-gauche (style original)
          Positioned(
            top: 120 + shift * 15,
            left: 24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: brand.withAlpha(isDark ? 40 : 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grille géométrique en fond
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color, required this.opacity});
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0, 1))
      ..strokeWidth = 0.5;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.color != color || old.opacity != opacity;
}

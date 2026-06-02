import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/features/onboarding/widgets/splash_brand_text.dart';
import 'package:flutter_boilerplate/features/onboarding/widgets/splash_loading_bar.dart';
import 'package:flutter_boilerplate/features/onboarding/widgets/splash_logo.dart';
import 'package:flutter/material.dart';

class SplashBrandContent extends StatelessWidget {
  const SplashBrandContent({
    super.key,
    required this.logoOpacity,
    required this.logoScale,
    required this.pulseProgress,
    required this.orbitProgress,
    required this.shimmerProgress,
    required this.textReveal,
    required this.taglineReveal,
    required this.barReveal,
    required this.loadingProgress,
    required this.brand,
    required this.accent,
    required this.surface,
    required this.isDarkMode,
  });

  final double logoOpacity;
  final double logoScale;
  final double pulseProgress;
  final double orbitProgress;
  final double shimmerProgress;
  final double textReveal;
  final double taglineReveal;
  final double barReveal;
  final double loadingProgress;
  final Color brand;
  final Color accent;
  final Color surface;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final compact = height < 520 || width < 360;
        final logoSize = (height * (compact ? 0.34 : 0.28)).clamp(118.0, 200.0);
        final titleSize = compact ? 34.0 : 42.0;
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SplashLogo(
              size: logoSize,
              opacity: logoOpacity,
              scale: logoScale,
              pulseProgress: pulseProgress,
              orbitProgress: orbitProgress,
              shimmerProgress: shimmerProgress,
              brand: brand,
              accent: accent,
              surface: surface,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: compact ? 16 : 32),
            SplashAnimatedBrandTitle(
              reveal: textReveal,
              fontSize: titleSize,
              brand: brand,
              accent: accent,
            ),
            SizedBox(height: compact ? 6 : 8),
            SplashAnimatedTagline(
              reveal: taglineReveal,
              compact: compact,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: compact ? 24 : 56),
            Opacity(
              opacity: barReveal,
              child: SplashLoadingBar(
                progress: loadingProgress,
                brand: brand,
                accent: accent,
                isDark: isDarkMode,
              ),
            ),
            SizedBox(height: compact ? 10 : 14),
            Opacity(
              opacity: barReveal * 0.6,
              child: Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? AppColors.white.withAlpha(77)
                      : brand.withAlpha(115),
                ),
              ),
            ),
          ],
        );

        return Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height > 32 ? height - 32 : 0,
              ),
              child: Center(child: content),
            ),
          ),
        );
      },
    );
  }
}

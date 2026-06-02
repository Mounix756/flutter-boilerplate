import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashAnimatedBrandTitle extends StatelessWidget {
  const SplashAnimatedBrandTitle({
    super.key,
    required this.reveal,
    required this.fontSize,
    required this.brand,
    required this.accent,
  });

  final double reveal;
  final double fontSize;
  final Color brand;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        heightFactor: reveal,
        child: Opacity(
          opacity: reveal,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [brand, accent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Flutter Boilerplate',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                height: 1,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashAnimatedTagline extends StatelessWidget {
  const SplashAnimatedTagline({
    super.key,
    required this.reveal,
    required this.compact,
    required this.isDarkMode,
  });

  final double reveal;
  final bool compact;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        heightFactor: reveal,
        child: Opacity(
          opacity: reveal,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
            child: Text(
              "L'artisan qu'il vous faut, maintenant.",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

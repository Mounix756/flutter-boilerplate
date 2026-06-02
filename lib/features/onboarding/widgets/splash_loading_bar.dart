import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashLoadingBar extends StatelessWidget {
  const SplashLoadingBar({
    super.key,
    required this.progress,
    required this.brand,
    required this.accent,
    required this.isDark,
  });

  final double progress;
  final Color brand;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.72,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isDark ? AppColors.white.withAlpha(20) : brand.withAlpha(26),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: brand.withAlpha(38), blurRadius: 6),
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(colors: [brand, accent]),
                  boxShadow: [
                    BoxShadow(color: brand.withAlpha(140), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

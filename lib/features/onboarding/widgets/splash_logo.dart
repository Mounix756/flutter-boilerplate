import 'dart:math' as math;

import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.size,
    required this.opacity,
    required this.scale,
    required this.pulseProgress,
    required this.orbitProgress,
    required this.shimmerProgress,
    required this.brand,
    required this.accent,
    required this.surface,
    required this.isDarkMode,
  });

  final double size;
  final double opacity;
  final double scale;
  final double pulseProgress;
  final double orbitProgress;
  final double shimmerProgress;
  final Color brand;
  final Color accent;
  final Color surface;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final logoBoxSize = size * 0.82;
    final logoPadding = size * 0.13;
    final radius = size * 0.19;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _LogoHalo(
            size: size,
            opacity: opacity,
            pulseProgress: pulseProgress,
            brand: brand,
          ),
          ..._buildOrbits(),
          Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale.clamp(0.0, 1.0),
              child: Container(
                width: logoBoxSize,
                height: logoBoxSize,
                padding: EdgeInsets.all(logoPadding),
                decoration: BoxDecoration(
                  color: surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: brand.withAlpha(75), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: brand.withAlpha(70),
                      blurRadius: size * 0.14,
                      spreadRadius: 3,
                      offset: Offset(0, size * 0.07),
                    ),
                    BoxShadow(
                      color: accent.withAlpha(35),
                      blurRadius: size * 0.25,
                      spreadRadius: -6,
                      offset: Offset(0, size * 0.03),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: _ShimmerOverlay(
                        progress: shimmerProgress,
                        isDark: isDarkMode,
                      ),
                    ),
                    Image.asset(
                      isDarkMode
                          ? AppImages.logoWhiteWithoutBackground
                          : AppImages.logoWithoutBackground,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbits() {
    final orbitRadius = size * 0.5;
    final specs = [
      _OrbitSpec(radius: orbitRadius, size: 7, speed: 1, startAngle: 0),
      _OrbitSpec(
        radius: orbitRadius * 0.96,
        size: 5,
        speed: -0.7,
        startAngle: 1.8,
      ),
      _OrbitSpec(
        radius: orbitRadius * 1.04,
        size: 4,
        speed: 0.5,
        startAngle: 3.5,
      ),
      _OrbitSpec(
        radius: orbitRadius * 0.92,
        size: 3.5,
        speed: -1.2,
        startAngle: 5,
      ),
    ];

    return specs.asMap().entries.map((entry) {
      final spec = entry.value;
      final angle = orbitProgress * spec.speed * 2 * math.pi + spec.startAngle;
      final color = entry.key.isOdd ? accent : brand;
      final particleOpacity = (opacity * (0.5 + math.sin(angle) * 0.3).abs())
          .clamp(0.2, 1.0);

      return Transform.translate(
        offset: Offset(
          math.cos(angle) * spec.radius,
          math.sin(angle) * spec.radius,
        ),
        child: Opacity(
          opacity: particleOpacity,
          child: Container(
            width: spec.size,
            height: spec.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(178),
                  blurRadius: spec.size * 2,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _LogoHalo extends StatelessWidget {
  const _LogoHalo({
    required this.size,
    required this.opacity,
    required this.pulseProgress,
    required this.brand,
  });

  final double size;
  final double opacity;
  final double pulseProgress;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 + pulseProgress * 0.18,
      child: Container(
        width: size * 0.88,
        height: size * 0.88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              brand.withAlpha(
                (71 * opacity * (1 - pulseProgress * 0.4)).round(),
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerOverlay extends StatelessWidget {
  const _ShimmerOverlay({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.5 + progress * 4, -1),
            end: Alignment(-0.5 + progress * 4, 1),
            colors: [
              Colors.transparent,
              AppColors.white.withAlpha(isDark ? 25 : 40),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitSpec {
  const _OrbitSpec({
    required this.radius,
    required this.size,
    required this.speed,
    required this.startAngle,
  });

  final double radius;
  final double size;
  final double speed;
  final double startAngle;
}

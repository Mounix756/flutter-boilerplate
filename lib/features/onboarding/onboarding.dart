import 'dart:async';

import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Page d'onboarding moderne pour présenter l'application Flutter Boilerplate.
///
/// La logique de navigation reste alignée avec le flux du projet :
/// - "Passer" ou dernière page -> AuthOptions
/// - sauvegarde de l'état onboarding via AppPreferences
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  Timer? _autoSlideTimer;
  Timer? _autoSlideResumeTimer;
  bool _isUserInteracting = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'titleKey': 'onboarding_title_1',
      'descriptionKey': 'onboarding_desc_1',
      'image': AppImages.onboardingOne,
      'icon': Icons.location_on_rounded,
    },
    {
      'titleKey': 'onboarding_title_2',
      'descriptionKey': 'onboarding_desc_2',
      'image': AppImages.onboardingTwo,
      'icon': Icons.handyman_rounded,
    },
    {
      'titleKey': 'onboarding_title_3',
      'descriptionKey': 'onboarding_desc_3',
      'image': AppImages.onboardingThree,
      'icon': Icons.radar_rounded,
    },
    {
      'titleKey': 'onboarding_title_4',
      'descriptionKey': 'onboarding_desc_4',
      'image': AppImages.onboardingFour,
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'titleKey': 'onboarding_title_5',
      'descriptionKey': 'onboarding_desc_5',
      'image': AppImages.onboardingFive,
      'icon': Icons.security_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted || _isUserInteracting) return;
      if (_currentPage < _onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
      _startAutoSlide();
    });
  }

  void _pauseAutoSlide({bool scheduleResume = true}) {
    _autoSlideTimer?.cancel();
    if (scheduleResume) {
      _autoSlideResumeTimer?.cancel();
      _autoSlideResumeTimer = Timer(const Duration(seconds: 10), () {
        if (!mounted) return;
        _isUserInteracting = false;
        _startAutoSlide();
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _autoSlideResumeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseAutoSlide(scheduleResume: false);
      return;
    }
    if (state == AppLifecycleState.resumed && !_isUserInteracting) {
      _startAutoSlide();
    }
  }

  Future<void> _nextPage() async {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await AppPreferences.setOnboardingCompleted();
      Get.offAllNamed(AppRoutes.authOptions);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _skipOnboarding() async {
    await AppPreferences.setOnboardingCompleted();
    Get.offAllNamed(AppRoutes.authOptions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textColor = isDarkMode
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final backgroundColor = isDarkMode
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: backgroundColor),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlesPainter(isDarkMode: isDarkMode),
                ),
              ),
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _isUserInteracting = true;
                    _pauseAutoSlide();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _animationController.forward(from: 0);
                    if (!_isUserInteracting) {
                      _startAutoSlide();
                    } else {
                      _pauseAutoSlide();
                    }
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(index, textColor);
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(70),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.logoPng,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 18,
                right: 16,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: textColor.withAlpha(220),
                  ),
                  child: Text(
                    'skip'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.16,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      dotColor: textColor.withAlpha(76),
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 3,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 34,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(
                              color: textColor.withAlpha(90),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'previous'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox.shrink()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 6,
                          shadowColor: colorScheme.primary.withAlpha(110),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'onboarding_start'.tr
                              : 'next'.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int index, Color textColor) {
    final data = _onboardingData[index];
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final overlayColor = isDarkMode
        ? AppColors.backgroundDark.withAlpha(178)
        : colorScheme.primary.withAlpha(128);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOutQuad,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(51),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.30,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          data['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDarkMode
                                  ? AppColors.backgroundDark.withAlpha(178)
                                  : colorScheme.primary.withAlpha(128),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 80,
                                  color: AppColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, overlayColor],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            data['icon'] as IconData,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.3, 0.8, curve: Curves.easeOutQuad),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  (data['titleKey'] as String).tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  (data['descriptionKey'] as String).tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textColor.withAlpha(225),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final bool isDarkMode;

  ParticlesPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final particleColor = isDarkMode
        ? AppColors.primary.withAlpha(76)
        : AppColors.primary.withAlpha(51);

    final lineColor = isDarkMode
        ? AppColors.textSecondaryDark.withAlpha(40)
        : AppColors.secondary.withAlpha(26);

    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 30; i++) {
      final x = (i * 17) % size.width;
      final y = (i * 23) % size.height;
      final radius = (i % 4 + 1) * 2.0;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 10; i++) {
      final startX = -size.width * 0.2 + (i * size.width * 0.15);
      final startY = size.height;
      final endX = startX + size.width * 0.6;
      const endY = 0.0;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) =>
      oldDelegate.isDarkMode != isDarkMode;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/requests/forgot_password_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/reset_password_request.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/otp_input_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page de réinitialisation de mot de passe.
///
/// Permet aux utilisateurs d'entrer le code OTP reçu
/// et de définir un nouveau mot de passe.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<OtpInputFieldState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _resetToken;
  String? _recoveryType;
  String? _email;
  String? _phone;
  Timer? _resendTimer;
  int _resendCountdown = 0; // Temps restant en secondes (90 secondes = 1min30)

  @override
  void initState() {
    super.initState();
    // Récupérer les arguments passés depuis la page précédente
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _resetToken = arguments['reset_token'] as String?;
      _recoveryType = arguments['recovery_type'] as String?;
      _email = arguments['email'] as String?;
      _phone = arguments['phone'] as String?;
    }
    // Valeurs par défaut si aucun argument n'est fourni
    _recoveryType ??= 'email';

    // Démarrer le compte à rebours initial
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Démarre le compte à rebours pour le renvoi du code OTP.
  void _startResendCountdown() {
    _resendCountdown = 90; // 1 minute 30 secondes
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// Formate le temps restant en minutes et secondes.
  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Valide et soumet la réinitialisation du mot de passe.
  Future<void> _handleResetPassword() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final otpCode = _otpKey.currentState?.getOtpCode() ?? '';
    if (otpCode.length != 6) {
      ModernNotification.showError(context, 'otp_required'.tr);
      return;
    }

    if (_resetToken == null || _resetToken!.isEmpty) {
      ModernNotification.showError(
        context,
        'Token de réinitialisation manquant. Veuillez refaire une demande.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer la requête de réinitialisation
      final request = ResetPasswordRequest(
        resetToken: _resetToken!,
        otpCode: otpCode,
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );

      // Appeler l'API
      final response = await _authRepository.resetPassword(request);

      if (!mounted) return;

      if (response.success) {
        await AppPreferences.setGuestMode(false);

        if (!mounted) return;
        ModernNotification.showSuccess(
          context,
          response.message.isNotEmpty
              ? response.message
              : 'password_reset_success'.tr,
        );

        // Naviguer vers la page de connexion après un court délai
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        ModernNotification.showError(context, response.message);
      }
    } catch (e) {
      if (mounted) {
        ModernNotification.showError(context, 'reset_password_error'.tr);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Renvoie le code OTP.
  Future<void> _resendOtp() async {
    if (_isLoading || _resendCountdown > 0) return;

    try {
      // Créer la requête selon le type de récupération
      ForgotPasswordRequest request;
      if (_recoveryType == 'email' && _email != null) {
        request = ForgotPasswordRequest.withEmail(email: _email!);
      } else if (_recoveryType == 'phone' && _phone != null) {
        request = ForgotPasswordRequest.withPhone(phone: _phone!);
      } else {
        ModernNotification.showError(
          context,
          'Impossible de renvoyer le code. Informations manquantes.',
        );
        return;
      }

      // Appeler l'API pour renvoyer le code
      final response = await _authRepository.forgotPassword(request);

      if (mounted) {
        if (response.success && response.data != null) {
          // Mettre à jour le reset_token
          _resetToken = response.data!.resetToken;
          // Redémarrer le compte à rebours
          _startResendCountdown();
          ModernNotification.showSuccess(context, 'otp_resent'.tr);
        } else {
          ModernNotification.showError(
            context,
            response.message.isNotEmpty
                ? response.message
                : 'resend_otp_error'.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ModernNotification.showError(context, 'resend_otp_error'.tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 700;
              final topSpacing = isSmallScreen ? 8.0 : 10.0;
              final logoSize = isSmallScreen ? 60.0 : 80.0;
              final logoPadding = isSmallScreen ? 12.0 : 16.0;
              final titleSpacing = isSmallScreen ? 12.0 : 16.0;
              final subtitleSpacing = isSmallScreen ? 8.0 : 12.0;
              final formSpacing = isSmallScreen ? 16.0 : 20.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: topSpacing,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bouton retour
                      Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.2, end: 0),

                      SizedBox(height: titleSpacing),

                      // Logo et titre
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                                padding: EdgeInsets.all(logoPadding),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withAlpha(76),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  isDarkMode
                                      ? AppImages.logoWhiteWithoutBackground
                                      : AppImages.logoWithoutBackground,
                                  width: logoSize,
                                  height: logoSize,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(delay: 200.ms),

                          SizedBox(height: titleSpacing),

                          // Titre
                          Text(
                                'reset_password_title'.tr,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),

                          SizedBox(height: subtitleSpacing),

                          // Sous-titre avec l'email/téléphone
                          Builder(
                                builder: (context) {
                                  final contact = (_recoveryType == 'email')
                                      ? (_email ?? 'email'.tr)
                                      : (_phone ?? 'phone'.tr);
                                  final subtitle = 'reset_password_subtitle'.tr
                                      .replaceAll('@contact', contact);
                                  return Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                      height: 1.5,
                                    ),
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),

                      SizedBox(height: formSpacing),

                      // Formulaire
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Champ code OTP
                          Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'otp_code'.tr,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OtpInputField(
                                    key: _otpKey,
                                    length: 6,
                                    autoFocus: true,
                                    onCompleted: (code) {
                                      // Auto-soumission optionnelle
                                    },
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 700.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 12),

                          // Lien renvoyer le code
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton(
                              label: _resendCountdown > 0
                                  ? '${'resend_otp'.tr} (${_formatCountdown(_resendCountdown)})'
                                  : 'resend_otp'.tr,
                              type: AppButtonType.text,
                              onPressed: (_isLoading || _resendCountdown > 0)
                                  ? null
                                  : _resendOtp,
                              height: 40,
                              width: -1,
                              animationDelay: 800,
                            ),
                          ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Champ nouveau mot de passe
                          AppTextField(
                                controller: _passwordController,
                                label: 'new_password'.tr,
                                prefixIcon: Icons.lock_outlined,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                onTogglePassword: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'password_required'.tr;
                                  }
                                  if (value.length < 8) {
                                    return 'password_min_length'.tr;
                                  }
                                  return null;
                                },
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 900.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          // Champ confirmation mot de passe
                          AppTextField(
                                controller: _confirmPasswordController,
                                label: 'confirm_password'.tr,
                                prefixIcon: Icons.lock_outlined,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onTogglePassword: () {
                                  setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  );
                                },
                                onFieldSubmitted: (_) {
                                  if (!_isLoading) {
                                    _handleResetPassword();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'confirm_password_required'.tr;
                                  }
                                  if (value != _passwordController.text) {
                                    return 'passwords_not_match'.tr;
                                  }
                                  return null;
                                },
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1000.ms)
                              .slideY(begin: 0.2, end: 0),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Bouton de réinitialisation
                          AppButton(
                            label: 'reset_password'.tr,
                            icon: Icons.lock_reset_rounded,
                            type: AppButtonType.primary,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleResetPassword,
                            animationDelay: 1100,
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 16),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

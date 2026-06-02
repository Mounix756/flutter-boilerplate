import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/utils/fcm_token_helper.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/features/auth/utils/auth_error_sanitizer.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/requests/resend_otp_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/verify_otp_request.dart';
import 'package:flutter_boilerplate/features/auth/responses/verify_otp_response.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
import 'package:flutter_boilerplate/features/profile/data/models/user.dart' as profile_user;
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/error_message_widget.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/otp_input_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page de vérification du code OTP après inscription.
///
/// Permet à l'utilisateur de saisir le code OTP reçu par SMS ou email
/// pour finaliser son inscription.
class VerifyOtpPage extends StatefulWidget {
  /// Token d'inscription reçu après l'inscription.
  final String registrationToken;

  /// Méthode OTP utilisée (sms ou email).
  final String otpMethod;

  /// Numéro de téléphone ou email où le code a été envoyé.
  final String contact;

  const VerifyOtpPage({
    super.key,
    required this.registrationToken,
    required this.otpMethod,
    required this.contact,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpKey = GlobalKey<OtpInputFieldState>();
  final _authRepository = AuthRepository();
  final _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  String? _errorMessage; // Message d'erreur à afficher inline

  @override
  void initState() {
    super.initState();
    // Démarrer le compte à rebours pour le renvoi (60 secondes)
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          }
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  /// Valide et soumet le code OTP.
  Future<void> _handleVerifyOtp() async {
    if (_isLoading) {
      return;
    }

    final otpCode = _otpKey.currentState?.getOtpCode() ?? '';

    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'otp_required'.tr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Réinitialiser l'erreur au début
    });

    try {
      // Récupérer le FCM token (optionnel)
      final fcmToken = await FcmTokenHelper.getToken();

      // Créer la requête de vérification OTP
      final request = VerifyOtpRequest(
        registrationToken: widget.registrationToken,
        otpCode: otpCode,
        fcmToken: fcmToken,
      );

      // Appeler l'API de vérification OTP
      final response = await _authRepository.verifyOtp(request);

      // Vérifier explicitement le succès ET la présence des données
      if (!response.success || response.data == null) {
        // Ne jamais afficher de messages sensibles
        String errorMsg = response.message.isNotEmpty
            ? response.message
            : 'otp_verification_error'.tr;

        errorMsg = AuthErrorSanitizer.sanitizeForDisplay(errorMsg);

        setState(() {
          _errorMessage = errorMsg;
        });
        return;
      }

      // Vérification réussie - s'assurer que les données sont présentes
      if (mounted && response.data != null && response.data!.token.isNotEmpty) {
        // Sauvegarder le token d'authentification
        await _secureStorage.write(
          key: AuthService.authTokenKey,
          value: response.data!.token,
        );

        // Mettre à jour le service d'authentification
        final authService = Get.find<AuthService>();
        await authService.setAuthenticated(true);

        // Désactiver le mode invité
        await AppPreferences.setGuestMode(false);

        await _primeProfileAfterRegistration(response.data!.user);

        // Rediriger vers la page d'accueil
        Get.offAllNamed(AppRoutes.app);
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'OTP verification flow failed',
        error: e,
        stackTrace: stackTrace,
        metadata: e is DioException
            ? {
                'type': e.type.name,
                'statusCode': e.response?.statusCode,
                'path': e.requestOptions.path,
                'method': e.requestOptions.method,
              }
            : const {},
      );

      if (mounted) {
        setState(() {
          _errorMessage = 'otp_verification_error'.tr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _primeProfileAfterRegistration(UserData userData) async {
    try {
      ProfileController profileController;
      if (Get.isRegistered<ProfileController>()) {
        profileController = Get.find<ProfileController>();
      } else {
        profileController = ProfileController(
          profileRepository: Get.find<ProfileRepository>(),
        );
        Get.put(profileController);
      }

      if (userData.id.trim().isNotEmpty) {
        profileController.setUser(
          profile_user.User(
            id: userData.id,
            firstname: userData.firstname,
            lastname: userData.lastname,
            email: userData.email,
            phone: userData.phone ?? '',
            status: userData.status,
          ),
        );
      }

      await profileController.loadProfile();
    } catch (e, stackTrace) {
      ErrorReporter.reportWarning(
        'Unable to prime profile after OTP verification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Renvoie le code OTP.
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) {
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null; // Réinitialiser l'erreur
    });

    try {
      // Créer la requête de renvoi OTP
      final request = ResendOtpRequest(
        registrationToken: widget.registrationToken,
      );

      // Appeler l'API pour renvoyer le code OTP
      final response = await _authRepository.resendOtp(request);

      if (mounted) {
        if (response.success) {
          ModernNotification.showSuccess(context, 'otp_resent'.tr);
          // Redémarrer le compte à rebours
          _startResendCountdown();
        } else {
          // Afficher l'erreur de manière générique
          setState(() {
            _errorMessage = 'resend_otp_error'.tr;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'resend_otp_error'.tr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
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

                const SizedBox(height: 32),

                // Icône de vérification
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.otpMethod == 'sms'
                        ? Icons.sms_outlined
                        : Icons.email_outlined,
                    size: 50,
                    color: colorScheme.primary,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

                const SizedBox(height: 32),

                // Titre
                Text(
                      'verify_otp_title'.tr,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                // Sous-titre avec le contact
                Text(
                      widget.otpMethod == 'sms'
                          ? 'verify_otp_subtitle_sms'.tr.replaceAll(
                              '{contact}',
                              widget.contact,
                            )
                          : 'verify_otp_subtitle_email'.tr.replaceAll(
                              '{contact}',
                              widget.contact,
                            ),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 48),

                // Champ code OTP
                OtpInputField(
                      key: _otpKey,
                      autoFocus: true,
                      onCompleted: (code) {
                        if (code.length == 6) {
                          _handleVerifyOtp();
                        }
                      },
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Message d'erreur inline
                if (_errorMessage != null)
                  ErrorMessageWidget(message: _errorMessage!)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                if (_errorMessage != null) const SizedBox(height: 16),

                // Bouton de vérification
                AppButton(
                      label: 'verify'.tr,
                      icon: Icons.check,
                      onPressed: _isLoading ? null : _handleVerifyOtp,
                      type: AppButtonType.primary,
                      isLoading: _isLoading,
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Bouton renvoyer le code
                Center(
                  child: TextButton(
                    onPressed: (_isResending || _resendCountdown > 0)
                        ? null
                        : _resendOtp,
                    child: Text(
                      _resendCountdown > 0
                          ? 'resend_otp_in'.tr.replaceAll(
                              '{seconds}',
                              _resendCountdown.toString(),
                            )
                          : 'resend_otp'.tr,
                      style: textTheme.bodyMedium?.copyWith(
                        color: _resendCountdown > 0
                            ? (isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                            : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

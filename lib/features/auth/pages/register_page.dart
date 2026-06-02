import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/services/google_auth_service.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/utils/fcm_token_helper.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/features/auth/utils/auth_error_sanitizer.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/requests/google_sign_in_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/register_request.dart';
import 'package:flutter_boilerplate/features/auth/responses/register_response.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/error_message_widget.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/phone_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page d'inscription à l'application.
///
/// Permet aux utilisateurs de créer un nouveau compte en 4 étapes :
/// - Étape 1 : Informations personnelles (nom, prénom, conditions d'utilisation)
/// - Étape 2 : Contact (téléphone obligatoire, email)
/// - Étape 3 : Sécurité (mot de passe et confirmation)
/// - Étape 4 : Vérification (choix de la méthode OTP)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneFieldKey = PhoneFieldStateKey();

  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  int _currentStep = 0;
  final int _totalSteps = 4;
  String? _otpMethod; // null par défaut, sera déterminé automatiquement
  String? _errorMessage; // Message d'erreur à afficher inline

  @override
  void initState() {
    super.initState();
    // Écouter les changements d'email pour mettre à jour la méthode OTP
    _emailController.addListener(_updateOtpMethod);
    _phoneController.addListener(_updateOtpMethod);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateOtpMethod);
    _phoneController.removeListener(_updateOtpMethod);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Met à jour la méthode OTP selon les champs remplis.
  void _updateOtpMethod() {
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;

    setState(() {
      if (hasEmail && _otpMethod != 'email') {
        // Si email saisi, sélectionner email par défaut
        _otpMethod = 'email';
      } else if (!hasEmail && hasPhone && _otpMethod == 'email') {
        // Si email supprimé mais téléphone présent, basculer vers SMS
        _otpMethod = 'sms';
      } else if (!hasEmail && !hasPhone) {
        // Si aucun des deux, réinitialiser
        _otpMethod = null;
      }
    });
  }

  /// Passe à l'étape suivante.
  void _nextStep() {
    if (_currentStep == 0) {
      // Valider l'étape 1 : Nom, prénom et conditions
      if (_firstNameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'first_name_required'.tr;
        });
        return;
      }
      if (_lastNameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'last_name_required'.tr;
        });
        return;
      }
      // Réinitialiser le message d'erreur si validation réussie
      setState(() => _errorMessage = null);
    } else if (_currentStep == 1) {
      // Valider l'étape 2 : téléphone et email obligatoires.
      if (_phoneController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'phone_required'.tr;
        });
        return;
      }
      final phoneNumber = _phoneController.text.trim();
      if (phoneNumber.length < 8 || phoneNumber.length > 15) {
        setState(() {
          _errorMessage = 'phone_invalid'.tr;
        });
        return;
      }
      final phoneRegex = RegExp(r'^[0-9]{8,15}$');
      if (!phoneRegex.hasMatch(phoneNumber)) {
        setState(() {
          _errorMessage = 'phone_invalid'.tr;
        });
        return;
      }
      if (_emailController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'email_required'.tr;
        });
        return;
      }
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        setState(() {
          _errorMessage = 'email_invalid'.tr;
        });
        return;
      }
      // Réinitialiser le message d'erreur si validation réussie
      setState(() => _errorMessage = null);
    } else if (_currentStep == 2) {
      // Valider l'étape 3 : Mot de passe et confirmation
      if (_passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'password_required'.tr;
        });
        return;
      }
      if (_passwordController.text.length < 8) {
        setState(() {
          _errorMessage = 'password_min_length'.tr;
        });
        return;
      }
      final password = _passwordController.text;
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
      );
      if (!passwordRegex.hasMatch(password)) {
        setState(() {
          _errorMessage = 'password_strength'.tr;
        });
        return;
      }
      if (_confirmPasswordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'confirm_password_required'.tr;
        });
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'passwords_not_match'.tr;
        });
        return;
      }
      if (!_acceptTerms) {
        setState(() {
          _errorMessage = 'accept_terms_required'.tr;
        });
        return;
      }
      // Réinitialiser le message d'erreur si validation réussie
      setState(() => _errorMessage = null);
    } else if (_currentStep == 3) {
      // Étape 4 : Initialiser la méthode OTP si nécessaire
      final hasEmail = _emailController.text.trim().isNotEmpty;
      final hasPhone = _phoneController.text.trim().isNotEmpty;

      // Si aucune méthode n'est sélectionnée, sélectionner automatiquement
      if (_otpMethod == null) {
        if (hasEmail) {
          // Si email présent, sélectionner email par défaut
          setState(() => _otpMethod = 'email');
        } else if (hasPhone) {
          // Sinon, sélectionner SMS par défaut
          setState(() => _otpMethod = 'sms');
        } else {
          // Aucun contact disponible
          setState(() {
            _errorMessage = 'otp_method_required'.tr;
          });
          return;
        }
      }

      // Vérifier qu'une méthode OTP est sélectionnée
      if (_otpMethod == null) {
        setState(() {
          _errorMessage = 'otp_method_required'.tr;
        });
        return;
      }
      // Si email est choisi, vérifier qu'un email est saisi
      if (_otpMethod == 'email' && _emailController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'email_required_for_otp'.tr;
        });
        return;
      }
      // Réinitialiser le message d'erreur si validation réussie
      setState(() => _errorMessage = null);
      // Procéder à l'inscription
      _handleRegister();
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  /// Revient à l'étape précédente.
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  /// Valide et soumet le formulaire d'inscription.
  Future<void> _handleRegister() async {
    if (_otpMethod == null) {
      setState(() {
        _errorMessage = 'otp_method_required'.tr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Réinitialiser l'erreur au début
    });

    try {
      // Récupérer le country code depuis PhoneField
      final rawCountryCode =
          _phoneFieldKey.currentState?.getCountryCode() ?? '228';
      final normalizedCountryCode = rawCountryCode.startsWith('+')
          ? rawCountryCode
          : '+$rawCountryCode';
      final rawPhone = _phoneController.text.trim();
      final normalizedPhone = rawPhone.startsWith('+')
          ? rawPhone
          : '$normalizedCountryCode$rawPhone';

      // Récupérer le FCM token (optionnel)
      final fcmToken = await FcmTokenHelper.getToken();

      // Créer la requête d'inscription
      final request = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: normalizedPhone,
        phoneCountryCode: normalizedCountryCode,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        otpMethod: _otpMethod!,
        fcmToken: fcmToken,
      );

      // Appeler l'API d'inscription
      final response = await _authRepository.register(request);

      if (!response.success) {
        setState(() {
          _errorMessage = _registrationErrorMessage(response);
        });
        return;
      }

      // Inscription réussie, rediriger vers la page de vérification OTP
      if (mounted && response.data != null) {
        // Le contact dépend de la méthode OTP choisie
        final contact = _otpMethod == 'email'
            ? _emailController.text.trim()
            : _phoneController.text.trim();
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: {
            'registrationToken': response.data!.registrationToken,
            'otpMethod': response.data!.otpMethod,
            'contact': contact,
          },
        );
      } else if (mounted && response.requiresVerification) {
        setState(() {
          _errorMessage =
              'Inscription reussie mais token de verification absent. Verifie le contrat API de /verify-otp.';
        });
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Register flow failed',
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
          _errorMessage = 'register_error'.tr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _registrationErrorMessage(RegisterResponse response) {
    if (response.statusCode == 409 ||
        response.message == 'register_contact_unavailable') {
      return 'register_contact_unavailable'.tr;
    }

    var errorMsg = response.message;
    if (response.hasValidationErrors && response.errors != null) {
      final errorMessages = <String>[];
      response.errors!.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      });
      if (errorMessages.isNotEmpty) {
        errorMsg = errorMessages.join('\n');
      }
    }

    final sanitized = AuthErrorSanitizer.sanitizeForDisplay(errorMsg).trim();
    return sanitized.isEmpty ? 'register_error'.tr : sanitized;
  }

  /// Gère l'inscription/connexion avec Google.
  ///
  /// Workflow complet et sécurisé :
  /// 1. Authentification Google OAuth
  /// 2. Récupération des informations utilisateur
  /// 3. Envoi à l'API Laravel pour création/connexion
  /// 4. Sauvegarde du token JWT
  /// 5. Navigation vers l'application
  ///
  /// Sécurité :
  /// - Validation de toutes les données Google
  /// - Nettoyage automatique en cas d'erreur
  /// - Token JWT sécurisé dans FlutterSecureStorage
  /// - Gestion d'erreur complète à chaque étape
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Étape 1 : Authentification Google
      final googleResult = await GoogleAuthService.signIn();

      if (!googleResult['success']) {
        if (googleResult['cancelled'] == true) {
          return;
        }
        setState(() {
          _errorMessage = googleResult['message'] ?? 'google_signin_error'.tr;
        });
        return;
      }

      // Étape 2 : Récupération du FCM token (optionnel)
      final fcmToken = await FcmTokenHelper.getToken();

      // Étape 3 : Préparation de la requête pour l'API
      final request = GoogleSignInRequest(
        googleId: googleResult['googleId'] as String,
        email: googleResult['email'] as String,
        name: googleResult['displayName'] as String,
        avatar: googleResult['photoUrl'] as String?,
        fcmToken: fcmToken,
      );

      // Étape 4 : Envoi à l'API Laravel
      final response = await _authRepository.registerWithGoogle(request);

      if (!response.success) {
        await GoogleAuthService.signOut();

        setState(() {
          _errorMessage = response.message;
        });
        return;
      }

      // Étape 5 : Sauvegarde sécurisée du token JWT
      if (response.data?.token != null) {
        await _secureStorage.write(
          key: AuthService.authTokenKey,
          value: response.data!.token,
        );

        // Mise à jour de l'état d'authentification
        final authService = Get.find<AuthService>();
        await authService.setAuthenticated(true);
        await AppPreferences.setGuestMode(false);

        try {
          ProfileController? profileController;
          try {
            profileController = Get.find<ProfileController>();
          } catch (_) {
            final profileRepository = Get.find<ProfileRepository>();
            profileController = ProfileController(
              profileRepository: profileRepository,
            );
            Get.put(profileController);
          }

          await profileController.loadProfile();
        } catch (_) {}

        // Étape 6 : Navigation vers l'application
        if (mounted) {
          // Afficher un message de bienvenue
          ModernNotification.showSuccess(
            context,
            response.data!.isNewUser
                ? 'google_signup_success'.tr
                : 'google_signin_success'.tr,
          );

          // Redirection vers l'application
          Get.offAllNamed(AppRoutes.app);
        }
      } else {
        await GoogleAuthService.signOut();
        setState(() {
          _errorMessage = 'google_token_missing'.tr;
        });
      }
    } catch (e) {
      // Nettoyage en cas d'erreur
      await GoogleAuthService.signOut();

      if (mounted) {
        setState(() {
          _errorMessage = 'google_signin_error'.tr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              final topSpacing = isSmallScreen ? 4.0 : 8.0;
              final logoSize = isSmallScreen ? 50.0 : 70.0;
              final logoPadding = isSmallScreen ? 10.0 : 14.0;
              final titleSpacing = isSmallScreen ? 16.0 : 24.0;
              final subtitleSpacing = isSmallScreen ? 4.0 : 8.0;
              final formSpacing = isSmallScreen ? 12.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: topSpacing,
                ),
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
                              'register_welcome'.tr,
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

                        SizedBox(height: subtitleSpacing),

                        // Sous-titre
                        Text(
                              'register_subtitle'.tr,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: 24),

                        // Indicateur de progression
                        _buildStepIndicator(
                          theme,
                          isDarkMode,
                          constraints,
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                      ],
                    ),

                    SizedBox(height: formSpacing),

                    // Contenu avec AnimatedSwitcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStepContent(
                        _currentStep,
                        theme,
                        isDarkMode,
                        colorScheme,
                        textTheme,
                        isSmallScreen,
                      ),
                    ),

                    // Message d'erreur inline
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      ErrorMessageWidget(message: _errorMessage!)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: -0.1, end: 0),
                    ],

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    // Boutons de navigation
                    _buildNavigationButtons(theme, isDarkMode, colorScheme),

                    if (_currentStep == 0) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark.withAlpha(76)
                                  : AppColors.textSecondaryLight.withAlpha(76),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or'.tr,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark.withAlpha(76)
                                  : AppColors.textSecondaryLight.withAlpha(76),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'sign_up_with_google'.tr,
                        type: AppButtonType.secondary,
                        customIcon: SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 24,
                          height: 24,
                          semanticsLabel: 'Google',
                        ),
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        animationDelay: 600,
                      ),
                    ],

                    SizedBox(height: isSmallScreen ? 4 : 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construit l'indicateur de progression avec cercles et connecteurs.
  Widget _buildStepIndicator(
    ThemeData theme,
    bool isDarkMode,
    BoxConstraints constraints,
  ) {
    final stepWidth = constraints.maxWidth * 0.15;
    final connectorWidth = constraints.maxWidth * 0.05;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: stepWidth,
          child: _buildStepCircle(0, 'Infos', theme, isDarkMode),
        ),
        SizedBox(
          width: connectorWidth,
          child: _buildStepConnector(theme, isDarkMode),
        ),
        SizedBox(
          width: stepWidth,
          child: _buildStepCircle(1, 'Contact', theme, isDarkMode),
        ),
        SizedBox(
          width: connectorWidth,
          child: _buildStepConnector(theme, isDarkMode),
        ),
        SizedBox(
          width: stepWidth,
          child: _buildStepCircle(2, 'Sécurité', theme, isDarkMode),
        ),
        SizedBox(
          width: connectorWidth,
          child: _buildStepConnector(theme, isDarkMode),
        ),
        SizedBox(
          width: stepWidth,
          child: _buildStepCircle(3, 'Vérification', theme, isDarkMode),
        ),
      ],
    );
  }

  /// Construit un cercle d'étape.
  Widget _buildStepCircle(
    int step,
    String label,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    final circleSize = 40.0;

    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : (isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight),
            border: Border.all(
              color: isActive || isCompleted
                  ? theme.colorScheme.primary.withAlpha(64)
                  : (isDarkMode
                        ? AppColors.textSecondaryDark.withAlpha(51)
                        : AppColors.textSecondaryLight.withAlpha(51)),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: circleSize * 0.5,
                    color: theme.colorScheme.onPrimary,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : (isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      fontWeight: FontWeight.w600,
                      fontSize: circleSize * 0.4,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : (isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construit un connecteur entre les étapes.
  Widget _buildStepConnector(ThemeData theme, bool isDarkMode) {
    return Container(
      height: 2,
      color: isDarkMode
          ? AppColors.textSecondaryDark.withAlpha(51)
          : AppColors.textSecondaryLight.withAlpha(51),
    );
  }

  /// Construit le contenu de l'étape actuelle.
  Widget _buildStepContent(
    int step,
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmallScreen,
  ) {
    switch (step) {
      case 0:
        return _buildStep1(
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isSmallScreen,
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
      case 1:
        return _buildStep2(
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isSmallScreen,
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
      case 2:
        return _buildStep3(
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isSmallScreen,
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
      case 3:
        return _buildStep4(
          theme,
          isDarkMode,
          colorScheme,
          textTheme,
          isSmallScreen,
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Construit l'étape 1 : Informations personnelles.
  Widget _buildStep1(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmallScreen,
  ) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Champ prénom
        AppTextField(
          controller: _firstNameController,
          label: 'first_name'.tr,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        // Champ nom
        AppTextField(
          controller: _lastNameController,
          label: 'last_name'.tr,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _nextStep(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  /// Construit l'étape 2 : Contact.
  Widget _buildStep2(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmallScreen,
  ) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Champ téléphone (obligatoire) avec indicatif
        PhoneField(
          key: _phoneFieldKey,
          controller: _phoneController,
          label: 'phone'.tr,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        // Champ email (obligatoire)
        AppTextField(
          controller: _emailController,
          label: 'email'.tr,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  /// Construit l'étape 3 : Sécurité.
  Widget _buildStep3(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmallScreen,
  ) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Champ mot de passe
        AppTextField(
          controller: _passwordController,
          label: 'password'.tr,
          prefixIcon: Icons.lock_outlined,
          isPassword: true,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onTogglePassword: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),

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
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          onFieldSubmitted: (_) => _nextStep(),
        ),

        const SizedBox(height: 20),

        // Checkbox accepter les conditions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.textSecondaryDark.withAlpha(51)
                  : AppColors.textSecondaryLight.withAlpha(51),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() => _acceptTerms = value ?? false);
                },
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _acceptTerms = !_acceptTerms);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text.rich(
                      TextSpan(
                        text: 'accept_terms_prefix'.tr,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: 'terms_and_conditions'.tr,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' ${'and'.tr} '),
                          TextSpan(
                            text: 'privacy_policy'.tr,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit l'étape 4 : Vérification (choix OTP).
  Widget _buildStep4(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmallScreen,
  ) {
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final countryCode =
        _phoneFieldKey.currentState?.getSelectedCountry().dialCode ?? '+228';
    final phoneNumber = _phoneController.text.trim();
    final formattedPhone = '$countryCode $phoneNumber';

    // Initialiser automatiquement la méthode OTP si nécessaire
    if (_otpMethod == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (hasEmail) {
            // Si email présent, sélectionner email par défaut
            setState(() => _otpMethod = 'email');
          } else if (hasPhone) {
            // Sinon, sélectionner SMS par défaut
            setState(() => _otpMethod = 'sms');
          }
        }
      });
    }

    return Column(
      key: const ValueKey('step4'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option Email
        _buildOtpMethodOption(
          theme: theme,
          isDarkMode: isDarkMode,
          colorScheme: colorScheme,
          textTheme: textTheme,
          method: 'email',
          icon: Icons.email_outlined,
          title: 'Par email',
          subtitle: hasEmail
              ? _emailController.text.trim()
              : 'Votre adresse email',
          isSelected: _otpMethod == 'email',
          isEnabled: hasEmail,
          onTap: hasEmail
              ? () {
                  setState(() => _otpMethod = 'email');
                }
              : null,
        ),

        const SizedBox(height: 24),

        // Option SMS
        _buildOtpMethodOption(
          theme: theme,
          isDarkMode: isDarkMode,
          colorScheme: colorScheme,
          textTheme: textTheme,
          method: 'sms',
          icon: Icons.sms_outlined,
          title: 'Par SMS',
          subtitle: hasPhone ? formattedPhone : 'Votre numéro de téléphone',
          isSelected: _otpMethod == 'sms',
          isEnabled: hasPhone,
          onTap: hasPhone
              ? () {
                  setState(() => _otpMethod = 'sms');
                }
              : null,
        ),
      ],
    );
  }

  /// Construit une option de méthode OTP.
  Widget _buildOtpMethodOption({
    required ThemeData theme,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String method,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : (isDarkMode
                        ? AppColors.textSecondaryDark.withAlpha(51)
                        : AppColors.textSecondaryLight.withAlpha(51)),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withAlpha(26)
                      : (isDarkMode
                            ? AppColors.textSecondaryDark.withAlpha(26)
                            : AppColors.textSecondaryLight.withAlpha(26)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? colorScheme.primary
                    : (isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit les boutons de navigation.
  Widget _buildNavigationButtons(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Bouton Précédent
        if (_currentStep > 0)
          Expanded(
            child: AppButton(
              label: 'previous'.tr,
              icon: Icons.arrow_back,
              onPressed: _isLoading ? null : _previousStep,
              type: AppButtonType.secondary,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),

        // Bouton Suivant ou S'inscrire
        Expanded(
          child: AppButton(
            label: _currentStep == _totalSteps - 1 ? 'sign_up'.tr : 'next'.tr,
            icon: _currentStep == _totalSteps - 1
                ? Icons.check
                : Icons.arrow_forward,
            onPressed: _isLoading ? null : _nextStep,
            type: AppButtonType.primary,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}

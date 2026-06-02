import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/preferences/app_preferences.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/core/utils/fcm_token_helper.dart';
import 'package:flutter_boilerplate/core/services/google_auth_service.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/requests/login_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/google_login_request.dart';
import 'package:flutter_boilerplate/features/profile/controllers/profile_controller.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/phone_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page de connexion à l'application.
///
/// Permet aux utilisateurs de se connecter avec leur email/téléphone
/// et mot de passe. Inclut également des liens vers la réinitialisation
/// de mot de passe et l'inscription.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum LoginType { email, phone }

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFieldKey = PhoneFieldStateKey();
  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _obscurePassword = true;
  bool _isLoading = false;
  LoginType _loginType = LoginType.email;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valide et soumet le formulaire de connexion.
  Future<void> _handleLogin() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer le FCM token (optionnel)
      final fcmToken = await FcmTokenHelper.getToken();

      // Créer la requête de connexion selon le type
      final request = _loginType == LoginType.email
          ? LoginRequest.withEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fcmToken: fcmToken,
            )
          : LoginRequest.withPhone(
              phone: _getFormattedPhoneNumber(),
              password: _passwordController.text,
              fcmToken: fcmToken,
            );

      // Appeler l'API de connexion
      final response = await _authRepository.login(request);

      if (!response.success) {
        // Gérer les erreurs
        String errorMsg = response.message;
        if (response.hasValidationErrors && response.errors != null) {
          final errorMessages = <String>[];
          response.errors!.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          errorMsg = errorMessages.isNotEmpty
              ? errorMessages.join('\n')
              : response.message;
        }

        // Ne jamais afficher de messages sensibles
        errorMsg = errorMsg
            .replaceAll(
              RegExp(r'\b\d{4,}\b'),
              '****',
            ) // Masquer les numéros longs
            .replaceAll(
              RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
              '****@****.***',
            ); // Masquer les emails

        setState(() {
          _errorMessage = errorMsg;
        });
        return;
      }

      // Connexion réussie
      if (mounted && response.data != null) {
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

        // Recharger le profil utilisateur
        try {
          // S'assurer que le ProfileController existe
          ProfileController? profileController;
          try {
            profileController = Get.find<ProfileController>();
          } catch (e) {
            // Si le controller n'existe pas, l'initialiser
            final profileRepository = Get.find<ProfileRepository>();
            profileController = ProfileController(
              profileRepository: profileRepository,
            );
            Get.put(profileController);
          }

          // Charger le profil
          await profileController.loadProfile();
        } catch (e) {
          // Erreur silencieuse lors du chargement du profil
        }

        // Rediriger vers la page d'accueil
        Get.offAllNamed(AppRoutes.app);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'login_error'.tr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Formate le numéro de téléphone avec l'indicatif pays.
  String _getFormattedPhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    final countryCode =
        _phoneFieldKey.currentState?.getSelectedCountry().dialCode ?? '+228';
    // Si le numéro commence déjà par +, le retourner tel quel
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }
    // Sinon, ajouter l'indicatif
    return '$countryCode$phoneNumber';
  }

  /// Gère la connexion avec Google.
  ///
  /// Workflow complet et sécurisé :
  /// 1. Authentification Google OAuth
  /// 2. Récupération de l'id_token
  /// 3. Envoi à l'API Laravel pour connexion/création
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

      // Étape 2 : Vérifier que l'id_token est disponible
      final idToken = googleResult['idToken'] as String?;
      if (idToken == null || idToken.isEmpty) {
        await GoogleAuthService.signOut();
        setState(() {
          _errorMessage = 'google_token_missing'.tr;
        });
        return;
      }

      // Étape 3 : Récupération du FCM token (optionnel)
      final fcmToken = await FcmTokenHelper.getToken();

      // Étape 4 : Préparation de la requête pour l'API
      final request = GoogleLoginRequest(idToken: idToken, fcmToken: fcmToken);

      // Étape 5 : Envoi à l'API Laravel
      final response = await _authRepository.loginWithGoogle(request);

      if (!response.success) {
        await GoogleAuthService.signOut();

        // Gérer les erreurs de validation
        String errorMsg = response.message;
        if (response.hasValidationErrors && response.errors != null) {
          final errorMessages = <String>[];
          response.errors!.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          errorMsg = errorMessages.isNotEmpty
              ? errorMessages.join('\n')
              : response.message;
        }

        setState(() {
          _errorMessage = errorMsg;
        });
        return;
      }

      // Étape 6 : Sauvegarde sécurisée du token JWT
      if (response.data?.token != null) {
        await _secureStorage.write(
          key: AuthService.authTokenKey,
          value: response.data!.token,
        );

        // Mise à jour de l'état d'authentification
        final authService = Get.find<AuthService>();
        await authService.setAuthenticated(true);

        // Désactiver le mode invité
        await AppPreferences.setGuestMode(false);

        // Recharger le profil utilisateur
        try {
          // S'assurer que le ProfileController existe
          ProfileController? profileController;
          try {
            profileController = Get.find<ProfileController>();
          } catch (e) {
            // Si le controller n'existe pas, l'initialiser
            final profileRepository = Get.find<ProfileRepository>();
            profileController = ProfileController(
              profileRepository: profileRepository,
            );
            Get.put(profileController);
          }

          // Charger le profil
          await profileController.loadProfile();
        } catch (e) {
          // Erreur silencieuse lors du chargement du profil
        }

        // Étape 7 : Navigation vers l'application
        if (mounted) {
          // Redirection vers l'application
          Get.offAllNamed(AppRoutes.app);

          // Afficher un message de bienvenue après la navigation
          // Utiliser Get.snackbar qui fonctionne sans contexte
          // Get.snackbar(
          //   'success'.tr,
          //   response.data!.isNewUser
          //       ? 'google_signup_success'.tr
          //       : 'google_signin_success'.tr,
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: AppColors.success.withAlpha(230),
          //   colorText: AppColors.white,
          //   duration: const Duration(seconds: 3),
          // );
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

  /// Construit le sélecteur d'onglets (Email/Phone).
  Widget _buildLoginTypeSelector(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.textSecondaryDark.withAlpha(51)
              : AppColors.textSecondaryLight.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              theme,
              isDarkMode,
              type: LoginType.email,
              icon: Icons.email_outlined,
              label: 'email'.tr,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypeButton(
              theme,
              isDarkMode,
              type: LoginType.phone,
              icon: Icons.phone_outlined,
              label: 'phone'.tr,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un bouton de type.
  Widget _buildTypeButton(
    ThemeData theme,
    bool isDarkMode, {
    required LoginType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _loginType == type;
    return InkWell(
      onTap: () {
        setState(() => _loginType = type);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
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
                                'login_welcome'.tr,
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

                          // Sous-titre
                          Text(
                                'login_subtitle'.tr,
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
                        ],
                      ),

                      SizedBox(height: formSpacing),

                      // Formulaire
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sélecteur Email/Phone
                          _buildLoginTypeSelector(theme, isDarkMode)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 700.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          // Champ email ou téléphone selon le type sélectionné
                          AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _loginType == LoginType.email
                                    ? AppTextField(
                                        key: const ValueKey('email'),
                                        controller: _emailController,
                                        label: 'email'.tr,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'email_required'.tr;
                                          }
                                          // Regex acceptant les TLD modernes (ex: .africa, .museum, etc.)
                                          final emailRegex = RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                          );
                                          if (!emailRegex.hasMatch(
                                            value.trim(),
                                          )) {
                                            return 'email_invalid'.tr;
                                          }
                                          return null;
                                        },
                                      )
                                    : PhoneField(
                                        key: _phoneFieldKey,
                                        controller: _phoneController,
                                        label: 'phone'.tr,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'phone_required'.tr;
                                          }
                                          final phoneRegex = RegExp(
                                            r'^[0-9]{8,15}$',
                                          );
                                          if (!phoneRegex.hasMatch(
                                            value.trim(),
                                          )) {
                                            return 'phone_invalid'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 800.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 12),

                          // Champ mot de passe
                          AppTextField(
                                controller: _passwordController,
                                label: 'password'.tr,
                                prefixIcon: Icons.lock_outlined,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onTogglePassword: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                onFieldSubmitted: (_) => _handleLogin(),
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

                          const SizedBox(height: 12),

                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withAlpha(76),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Lien mot de passe oublié
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton(
                              label: 'forgot_password'.tr,
                              type: AppButtonType.text,
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.forgotPassword),
                              height: 40,
                              width: -1,
                              animationDelay: 1000,
                            ),
                          ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Bouton de connexion
                          AppButton(
                            label: 'sign_in'.tr,
                            icon: Icons.login_rounded,
                            type: AppButtonType.primary,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleLogin,
                            animationDelay: 1100,
                          ),

                          const SizedBox(height: 16),

                          // Séparateur
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark.withAlpha(
                                          76,
                                        )
                                      : AppColors.textSecondaryLight.withAlpha(
                                          76,
                                        ),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                      ? AppColors.textSecondaryDark.withAlpha(
                                          76,
                                        )
                                      : AppColors.textSecondaryLight.withAlpha(
                                          76,
                                        ),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Bouton connexion Google
                          AppButton(
                                label: 'sign_in_with_google'.tr,
                                type: AppButtonType.secondary,
                                customIcon: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  width: 24,
                                  height: 24,
                                  semanticsLabel: 'Google',
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleGoogleSignIn,
                                isLoading: _isLoading,
                                animationDelay: 1300,
                              )
                              .animate()
                              .fadeIn(delay: 1300.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          // Lien vers l'inscription
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 0,
                              children: [
                                Text(
                                  'no_account'.tr,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                AppButton(
                                  label: 'sign_up'.tr,
                                  type: AppButtonType.text,
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.register),
                                  height: 40,
                                  width: -1,
                                  foregroundColor: colorScheme.primary,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 1400.ms, duration: 400.ms),

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/constants/images.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/requests/forgot_password_request.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';
import 'package:flutter_boilerplate/shared/widgets/phone_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page de récupération de compte.
///
/// Permet aux utilisateurs de choisir entre email ou téléphone
/// pour recevoir un code de réinitialisation.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum RecoveryType { email, phone }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFieldKey = PhoneFieldStateKey();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  RecoveryType _recoveryType = RecoveryType.email;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Valide et soumet la demande de récupération.
  Future<void> _handleRecovery() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer la requête selon le type de récupération
      ForgotPasswordRequest request;
      String? email;
      String? phone;

      if (_recoveryType == RecoveryType.email) {
        email = _emailController.text.trim();
        request = ForgotPasswordRequest.withEmail(email: email);
      } else {
        // Récupérer le country code depuis PhoneField
        final countryCode =
            _phoneFieldKey.currentState?.getCountryCode() ?? '228';
        final phoneNumber = _phoneController.text.trim();
        phone = '+$countryCode$phoneNumber';
        request = ForgotPasswordRequest.withPhone(phone: phone);
      }

      // Appeler l'API
      final response = await _authRepository.forgotPassword(request);

      if (mounted) {
        if (response.success && response.data != null) {
          // Naviguer vers la page de réinitialisation avec le token
          Get.toNamed(
            AppRoutes.resetPassword,
            arguments: {
              'reset_token': response.data!.resetToken,
              'recovery_type': response.data!.recoveryType,
              'email': email,
              'phone': phone,
            },
          );
        } else {
          ModernNotification.showError(context, response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        ModernNotification.showError(context, 'recovery_error'.tr);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Construit le sélecteur d'onglets (Email/Phone).
  Widget _buildRecoveryTypeSelector(ThemeData theme, bool isDarkMode) {
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
              type: RecoveryType.email,
              icon: Icons.email_outlined,
              label: 'email'.tr,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypeButton(
              theme,
              isDarkMode,
              type: RecoveryType.phone,
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
    required RecoveryType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _recoveryType == type;
    return InkWell(
      onTap: () {
        setState(() => _recoveryType = type);
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
                                'forgot_password_title'.tr,
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
                                'forgot_password_subtitle'.tr,
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
                          _buildRecoveryTypeSelector(theme, isDarkMode)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 700.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          // Champ email ou téléphone selon le type sélectionné
                          AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _recoveryType == RecoveryType.email
                                    ? AppTextField(
                                        key: const ValueKey('email'),
                                        controller: _emailController,
                                        label: 'email'.tr,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done,
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
                                        textInputAction: TextInputAction.done,
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

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Bouton de récupération
                          AppButton(
                            label: 'send_recovery_code'.tr,
                            icon: Icons.send_rounded,
                            type: AppButtonType.primary,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleRecovery,
                            animationDelay: 900,
                          ),

                          const SizedBox(height: 16),

                          // Lien vers la connexion
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'remember_password'.tr,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                AppButton(
                                  label: 'sign_in'.tr,
                                  type: AppButtonType.text,
                                  onPressed: () => Get.back(),
                                  height: 40,
                                  width: -1,
                                  foregroundColor: colorScheme.primary,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),

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

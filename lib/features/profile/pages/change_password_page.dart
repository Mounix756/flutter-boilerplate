import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/theme/app_colors.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';
import 'package:flutter_boilerplate/features/profile/requests/change_password_request.dart';
import 'package:flutter_boilerplate/shared/widgets/app_button.dart';
import 'package:flutter_boilerplate/shared/widgets/app_text_field.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';
import 'package:flutter_boilerplate/shared/widgets/modern_notification.dart';

/// Page de changement de mot de passe.
///
/// Permet à l'utilisateur authentifié de changer son mot de passe.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _profileRepository = Get.find<ProfileRepository>();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valide et soumet le changement de mot de passe.
  Future<void> _handleChangePassword() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer la requête de changement de mot de passe
      final request = ChangePasswordRequest(
        currentPassword: _currentPasswordController.text,
        password: _newPasswordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      // Appeler l'API
      final response = await _profileRepository.changePassword(request);

      if (!mounted) return;

      if (response.success) {
        ModernNotification.showSuccess(
          context,
          response.message.isNotEmpty
              ? response.message
              : 'password_changed_success'.tr,
        );

        // Vider les champs et retourner en arrière après un court délai
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Get.back();
        }
      } else {
        // Afficher les erreurs de validation si présentes
        String errorMessage = response.message;
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
            errorMessage = errorMessages.join('\n');
          }
        }

        ModernNotification.showError(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ModernNotification.showError(context, 'change_password_error'.tr);
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'change_password'.tr, centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Description
                Text(
                  'change_password_description'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Champ mot de passe actuel
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'current_password'.tr,
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  obscureText: _obscureCurrentPassword,
                  textInputAction: TextInputAction.next,
                  onTogglePassword: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'current_password_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ nouveau mot de passe
                AppTextField(
                  controller: _newPasswordController,
                  label: 'new_password'.tr,
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  obscureText: _obscureNewPassword,
                  textInputAction: TextInputAction.next,
                  onTogglePassword: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
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
                ),
                const SizedBox(height: 16),

                // Champ confirmation nouveau mot de passe
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'confirm_new_password'.tr,
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onTogglePassword: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _handleChangePassword();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'confirm_password_required'.tr;
                    }
                    if (value != _newPasswordController.text) {
                      return 'passwords_not_match'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Bouton de changement de mot de passe
                AppButton(
                  label: 'change_password'.tr,
                  icon: Icons.lock_reset_rounded,
                  type: AppButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

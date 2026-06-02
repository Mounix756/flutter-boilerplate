/// Modèle de requête pour la réinitialisation de mot de passe.
///
/// Permet de réinitialiser le mot de passe avec le code OTP reçu.
class ResetPasswordRequest {
  final String resetToken;
  final String otpCode;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordRequest({
    required this.resetToken,
    required this.otpCode,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'otp_code': otpCode,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  String toString() {
    return 'ResetPasswordRequest('
        'resetToken: ${resetToken.substring(0, 20)}..., '
        'otpCode: $otpCode, '
        'password: ***'
        ')';
  }
}

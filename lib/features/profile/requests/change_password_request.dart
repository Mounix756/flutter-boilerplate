/// Modèle de requête pour le changement de mot de passe.
///
/// Permet à l'utilisateur authentifié de changer son mot de passe.
class ChangePasswordRequest {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  String toString() {
    return 'ChangePasswordRequest('
        'currentPassword: ***, '
        'password: ***, '
        'passwordConfirmation: ***'
        ')';
  }
}

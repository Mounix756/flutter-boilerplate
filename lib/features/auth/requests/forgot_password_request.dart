/// Modèle de requête pour la récupération de mot de passe.
///
/// Permet de demander un code OTP par email ou SMS pour réinitialiser le mot de passe.
class ForgotPasswordRequest {
  final String recoveryType; // 'email' ou 'phone'
  final String? email;
  final String? phone;

  const ForgotPasswordRequest({
    required this.recoveryType,
    this.email,
    this.phone,
  });

  /// Crée une requête de récupération par email.
  factory ForgotPasswordRequest.withEmail({
    required String email,
  }) {
    return ForgotPasswordRequest(
      recoveryType: 'email',
      email: email,
    );
  }

  /// Crée une requête de récupération par téléphone.
  factory ForgotPasswordRequest.withPhone({
    required String phone,
  }) {
    return ForgotPasswordRequest(
      recoveryType: 'phone',
      phone: phone,
    );
  }

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'recovery_type': recoveryType,
    };

    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    return json;
  }

  @override
  String toString() {
    return 'ForgotPasswordRequest('
        'recoveryType: $recoveryType, '
        'email: $email, '
        'phone: $phone'
        ')';
  }
}

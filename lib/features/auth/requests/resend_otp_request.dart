/// Modèle de requête pour le renvoi du code OTP.
///
/// Contient les données nécessaires pour renvoyer le code OTP
/// lors de l'inscription.
class ResendOtpRequest {
  final String registrationToken;

  const ResendOtpRequest({
    required this.registrationToken,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    return {
      'registration_token': registrationToken,
    };
  }

  /// Crée une instance depuis un Map (utile pour les tests).
  factory ResendOtpRequest.fromJson(Map<String, dynamic> json) {
    return ResendOtpRequest(
      registrationToken: json['registration_token'] as String,
    );
  }

  @override
  String toString() {
    return 'ResendOtpRequest(registrationToken: $registrationToken)';
  }
}

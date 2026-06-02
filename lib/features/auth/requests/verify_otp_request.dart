/// Modèle de requête pour la vérification du code OTP.
///
/// Contient les données nécessaires pour vérifier le code OTP
/// et finaliser l'inscription.
class VerifyOtpRequest {
  final String registrationToken;
  final String otpCode;
  final String? fcmToken;

  const VerifyOtpRequest({
    required this.registrationToken,
    required this.otpCode,
    this.fcmToken,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'registration_token': registrationToken,
      'otp_code': otpCode,
    };

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken;
    }

    return json;
  }

  /// Crée une instance depuis un Map (utile pour les tests).
  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      registrationToken: json['registration_token'] as String,
      otpCode: json['otp_code'] as String,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  @override
  String toString() {
    return 'VerifyOtpRequest('
        'registrationToken: $registrationToken, '
        'otpCode: $otpCode'
        ')';
  }
}

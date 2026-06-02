/// Modèle de réponse pour le renvoi du code OTP.
///
/// Contient les données retournées par l'API après un renvoi réussi.
class ResendOtpResponse {
  final bool success;
  final String message;

  const ResendOtpResponse({
    required this.success,
    required this.message,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'ResendOtpResponse(success: $success, message: $message)';
  }
}

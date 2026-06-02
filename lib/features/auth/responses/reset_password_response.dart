/// Modèle de réponse pour la réinitialisation de mot de passe.
///
/// Contient les données retournées par l'API après une réinitialisation réussie.
class ResetPasswordResponse {
  final bool success;
  final String message;

  const ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'ResetPasswordResponse('
        'success: $success, '
        'message: $message'
        ')';
  }
}

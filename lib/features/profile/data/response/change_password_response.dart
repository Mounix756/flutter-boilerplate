/// Modèle de réponse pour le changement de mot de passe.
///
/// Contient les données retournées par l'API après un changement de mot de passe.
class ChangePasswordResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;

  const ChangePasswordResponse({
    required this.success,
    required this.message,
    this.errors,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Indique si la réponse contient des erreurs de validation.
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'ChangePasswordResponse('
        'success: $success, '
        'message: $message'
        ')';
  }
}

/// Modèle de réponse pour la demande de récupération de mot de passe.
///
/// Contient les données retournées par l'API après une demande de récupération réussie.
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final ForgotPasswordData? data;

  const ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ForgotPasswordData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'ForgotPasswordResponse('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse de récupération de mot de passe.
class ForgotPasswordData {
  final String resetToken;
  final String recoveryType;
  final int expiresIn;

  const ForgotPasswordData({
    required this.resetToken,
    required this.recoveryType,
    required this.expiresIn,
  });

  /// Crée une instance depuis un Map JSON.
  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      resetToken: json['reset_token'] as String,
      recoveryType: json['recovery_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'recovery_type': recoveryType,
      'expires_in': expiresIn,
    };
  }

  @override
  String toString() {
    return 'ForgotPasswordData('
        'resetToken: ${resetToken.substring(0, 20)}..., '
        'recoveryType: $recoveryType, '
        'expiresIn: $expiresIn'
        ')';
  }
}

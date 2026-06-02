import 'package:flutter_boilerplate/features/profile/data/models/user.dart';

/// Modèle de réponse pour la mise à jour du profil.
class UpdateProfileResponse {
  final bool success;
  final String message;
  final UpdateProfileData? data;
  final Map<String, dynamic>? errors;

  const UpdateProfileResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Crée une instance depuis un Map JSON.
  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UpdateProfileData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Indique si la réponse contient des erreurs de validation.
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'UpdateProfileResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }
}

/// Données de la réponse de mise à jour du profil.
class UpdateProfileData {
  final User user;

  const UpdateProfileData({required this.user});

  /// Crée une instance depuis un Map JSON.
  factory UpdateProfileData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'UpdateProfileData(user: $user)';
  }
}

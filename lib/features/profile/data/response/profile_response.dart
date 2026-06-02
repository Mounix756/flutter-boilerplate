import 'package:flutter_boilerplate/features/profile/data/models/user.dart';

/// Modèle de réponse pour la récupération du profil utilisateur.
///
/// Contient les données retournées par l'API après une récupération de profil réussie.
class ProfileResponse {
  final bool success;
  final String message;
  final ProfileData? data;

  const ProfileResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'ProfileResponse('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse de profil.
class ProfileData {
  final User user;

  const ProfileData({
    required this.user,
  });

  /// Crée une instance depuis un Map JSON.
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProfileData(user: $user)';
  }
}

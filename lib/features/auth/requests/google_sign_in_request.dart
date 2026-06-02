/// Modèle de requête pour l'inscription/connexion avec Google.
///
/// Contient les données nécessaires pour authentifier un utilisateur via Google OAuth.
class GoogleSignInRequest {
  final String googleId;
  final String email;
  final String name;
  final String? avatar;
  final String? fcmToken;

  const GoogleSignInRequest({
    required this.googleId,
    required this.email,
    required this.name,
    this.avatar,
    this.fcmToken,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    return {
      'google_id': googleId,
      'email': email,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }

  @override
  String toString() {
    return 'GoogleSignInRequest('
        'googleId: $googleId, '
        'email: $email, '
        'name: $name, '
        'avatar: ${avatar ?? 'null'}, '
        'fcmToken: ${fcmToken != null ? '***' : 'null'}'
        ')';
  }
}

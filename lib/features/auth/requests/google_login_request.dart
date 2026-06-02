/// Modèle de requête pour la connexion avec Google (id_token).
///
/// Contient les données nécessaires pour authentifier un utilisateur via Google OAuth
/// en utilisant l'id_token fourni par Google Sign-In.
class GoogleLoginRequest {
  final String idToken;
  final String? fcmToken;

  const GoogleLoginRequest({
    required this.idToken,
    this.fcmToken,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id_token': idToken,
    };

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken;
    }

    return json;
  }

  @override
  String toString() {
    return 'GoogleLoginRequest('
        'idToken: ${idToken.substring(0, 20)}..., '
        'fcmToken: ${fcmToken != null ? '***' : 'null'}'
        ')';
  }
}

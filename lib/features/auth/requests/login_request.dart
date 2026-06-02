/// Modèle de requête pour la connexion d'un utilisateur.
///
/// Contient les données nécessaires pour authentifier un utilisateur.
/// L'utilisateur doit choisir son type de connexion (email ou téléphone)
/// via le champ 'login_type', puis fournir les informations correspondantes.
class LoginRequest {
  final String loginType; // 'email' ou 'phone'
  final String? email;
  final String? phone;
  final String password;
  final String? fcmToken;

  const LoginRequest({
    required this.loginType,
    this.email,
    this.phone,
    required this.password,
    this.fcmToken,
  });

  /// Crée une requête de connexion par email.
  factory LoginRequest.withEmail({
    required String email,
    required String password,
    String? fcmToken,
  }) {
    return LoginRequest(
      loginType: 'email',
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
  }

  /// Crée une requête de connexion par téléphone.
  factory LoginRequest.withPhone({
    required String phone,
    required String password,
    String? fcmToken,
  }) {
    return LoginRequest(
      loginType: 'phone',
      phone: phone,
      password: password,
      fcmToken: fcmToken,
    );
  }

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'login_type': loginType,
      'password': password,
    };

    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken;
    }

    return json;
  }

  /// Crée une instance depuis un Map (utile pour les tests).
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      loginType: json['login_type'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  @override
  String toString() {
    return 'LoginRequest('
        'loginType: $loginType, '
        'email: ${email ?? 'null'}, '
        'phone: ${phone ?? 'null'}'
        ')';
  }
}

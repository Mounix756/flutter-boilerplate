/// Modèle de réponse pour la connexion d'un utilisateur.
///
/// Contient les données retournées par l'API après une connexion réussie.
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;
  final Map<String, dynamic>? errors;

  const LoginResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Indique si la réponse contient des erreurs de validation.
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'LoginResponse('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse de connexion.
class LoginData {
  final LoginUserData user;
  final String token;

  const LoginData({
    required this.user,
    required this.token,
  });

  /// Crée une instance depuis un Map JSON.
  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: LoginUserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  String toString() {
    return 'LoginData('
        'user: $user, '
        'token: ${token.substring(0, 20)}...'
        ')';
  }
}

/// Données utilisateur retournées après connexion.
class LoginUserData {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String status;

  const LoginUserData({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phone,
    required this.status,
  });

  /// Crée une instance depuis un Map JSON.
  factory LoginUserData.fromJson(Map<String, dynamic> json) {
    return LoginUserData(
      id: json['id'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }

  /// Retourne le nom complet de l'utilisateur.
  String get fullName => '$firstname $lastname';

  @override
  String toString() {
    return 'LoginUserData('
        'id: $id, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'email: $email, '
        'phone: $phone, '
        'status: $status'
        ')';
  }
}

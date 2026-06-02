/// Modèle de réponse pour l'inscription/connexion avec Google.
///
/// Contient les données retournées par l'API après une authentification Google réussie.
class GoogleSignInResponse {
  final bool success;
  final String message;
  final GoogleSignInData? data;
  final Map<String, dynamic>? errors;

  const GoogleSignInResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory GoogleSignInResponse.fromJson(Map<String, dynamic> json) {
    return GoogleSignInResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? GoogleSignInData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Indique si la réponse contient des erreurs de validation.
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'GoogleSignInResponse('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse de connexion Google.
class GoogleSignInData {
  final GoogleUserData user;
  final String token;
  final bool isNewUser;

  const GoogleSignInData({
    required this.user,
    required this.token,
    required this.isNewUser,
  });

  /// Crée une instance depuis un Map JSON.
  factory GoogleSignInData.fromJson(Map<String, dynamic> json) {
    return GoogleSignInData(
      user: GoogleUserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token, 'is_new_user': isNewUser};
  }

  @override
  String toString() {
    return 'GoogleSignInData('
        'user: $user, '
        'token: ${token.substring(0, 20)}..., '
        'isNewUser: $isNewUser'
        ')';
  }
}

/// Données utilisateur retournées après connexion Google.
class GoogleUserData {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String? image;
  final String status;
  final bool isRegisterWithGoogle;

  const GoogleUserData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phone,
    this.image,
    required this.status,
    required this.isRegisterWithGoogle,
  });

  /// Crée une instance depuis un Map JSON.
  factory GoogleUserData.fromJson(Map<String, dynamic> json) {
    return GoogleUserData(
      id: json['id'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      status: json['status'] as String,
      isRegisterWithGoogle: json['is_register_with_google'] as bool? ?? false,
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
      'image': image,
      'status': status,
      'is_register_with_google': isRegisterWithGoogle,
    };
  }

  /// Retourne le nom complet de l'utilisateur.
  String get fullName => '$firstname $lastname';

  @override
  String toString() {
    return 'GoogleUserData('
        'id: $id, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'email: $email, '
        'phone: $phone, '
        'image: $image, '
        'status: $status, '
        'isRegisterWithGoogle: $isRegisterWithGoogle'
        ')';
  }
}

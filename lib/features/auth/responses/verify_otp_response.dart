/// Modèle de réponse pour la vérification du code OTP.
///
/// Contient les données retournées par l'API après une vérification OTP réussie.
class VerifyOtpResponse {
  final bool success;
  final String message;
  final VerifyOtpData? data;

  const VerifyOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Crée une instance depuis la réponse JSON de l'API.
  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'VerifyOtpResponse('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse de vérification OTP.
class VerifyOtpData {
  final UserData user;
  final String token;

  const VerifyOtpData({
    required this.user,
    required this.token,
  });

  /// Crée une instance depuis un Map JSON.
  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
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
    return 'VerifyOtpData('
        'user: $user, '
        'token: ${token.substring(0, 20)}...'
        ')';
  }
}

/// Données utilisateur retournées après vérification OTP.
class UserData {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String status;
  final String? phoneVerifiedAt;
  final String? emailVerifiedAt;

  const UserData({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phone,
    required this.status,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
  });

  /// Crée une instance depuis un Map JSON.
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      phoneVerifiedAt: json['phone_verified_at'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
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
      'phone_verified_at': phoneVerifiedAt,
      'email_verified_at': emailVerifiedAt,
    };
  }

  @override
  String toString() {
    return 'UserData('
        'id: $id, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'email: $email, '
        'phone: $phone, '
        'status: $status'
        ')';
  }
}

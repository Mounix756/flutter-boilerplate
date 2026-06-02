/// Modèle de requête pour l'inscription d'un nouvel utilisateur.
///
/// Contient toutes les données nécessaires pour créer un compte utilisateur.
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String? gender;
  final String email;
  final String phone;
  final String phoneCountryCode;
  final String password;
  final String? passwordConfirmation;
  final String otpMethod;
  final String? fcmToken;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    this.gender,
    required this.email,
    required this.phone,
    required this.phoneCountryCode,
    required this.password,
    this.passwordConfirmation,
    required this.otpMethod,
    this.fcmToken,
  });

  /// Convertit l'objet en Map pour l'envoi à l'API.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phone_country_code': phoneCountryCode,
      'password': password,
      'password_confirmation': passwordConfirmation ?? password,
      'otp_method': otpMethod,
    };

    if (gender != null && gender!.isNotEmpty) {
      json['gender'] = gender;
    }

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken;
    }

    return json;
  }

  /// Crée une instance depuis un Map (utile pour les tests).
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: (json['firstname'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastname'] ?? json['last_name'] ?? '').toString(),
      gender: json['gender']?.toString(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      phoneCountryCode:
          (json['phoneCountryCode'] ?? json['phone_country_code'] ?? '')
              .toString(),
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation']?.toString(),
      otpMethod: (json['otpMethod'] ?? json['otp_method'] ?? '').toString(),
      fcmToken: (json['fcmToken'] ?? json['fcm_token'])?.toString(),
    );
  }

  @override
  String toString() {
    return 'RegisterRequest('
        'firstName: $firstName, '
        'lastName: $lastName, '
        'email: $email, '
        'phone: $phone, '
        'phoneCountryCode: $phoneCountryCode, '
        'otpMethod: $otpMethod'
        ')';
  }
}

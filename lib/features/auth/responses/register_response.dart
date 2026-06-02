/// Modèle de réponse pour l'inscription d'un nouvel utilisateur.
///
/// Contient les données retournées par l'API après une inscription réussie.
class RegisterResponse {
  final bool success;
  final String message;
  final RegisterData? data;
  final RegisterUser? user;
  final bool requiresVerification;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const RegisterResponse({
    required this.success,
    required this.message,
    this.data,
    this.user,
    this.requiresVerification = false,
    this.errors,
    this.statusCode,
  });

  static String _parseMessage(dynamic rawMessage) {
    if (rawMessage == null) return '';
    if (rawMessage is String) return rawMessage;
    if (rawMessage is List) {
      final values = rawMessage
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
      return values.join('\n');
    }
    return rawMessage.toString();
  }

  /// Crée une instance depuis la réponse JSON de l'API.
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    RegisterData? data;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = RegisterData.fromJson(rawData);
    } else if (rawData is Map) {
      data = RegisterData.fromJson(Map<String, dynamic>.from(rawData));
    } else if (json['registration_token'] != null ||
        json['registrationToken'] != null) {
      data = RegisterData(
        registrationToken:
            (json['registration_token'] ?? json['registrationToken'])
                .toString(),
        otpMethod: (json['otp_method'] ?? json['otpMethod'] ?? 'sms')
            .toString(),
        expiresIn: int.tryParse((json['expires_in'] ?? json['expiresIn'] ?? 0)
                .toString()) ??
            0,
      );
    }

    RegisterUser? user;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      user = RegisterUser.fromJson(rawUser);
    } else if (rawUser is Map) {
      user = RegisterUser.fromJson(Map<String, dynamic>.from(rawUser));
    }

    return RegisterResponse(
      // Nouveau backend retourne 200 sans champ "success"
      success: json['success'] as bool? ?? true,
      message: _parseMessage(json['message']),
      data: data,
      user: user,
      requiresVerification: json['requiresVerification'] as bool? ?? false,
      statusCode: int.tryParse((json['statusCode'] ?? '').toString()),
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : (json['errors'] is Map
                ? Map<String, dynamic>.from(json['errors'] as Map)
                : null),
    );
  }

  /// Indique si la réponse contient des erreurs de validation.
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'RegisterResponse('
        'success: $success, '
        'message: $message, '
        'statusCode: $statusCode, '
        'requiresVerification: $requiresVerification, '
        'data: $data'
        ')';
  }
}

/// Données contenues dans la réponse d'inscription.
class RegisterData {
  final String registrationToken;
  final String otpMethod;
  final int expiresIn;

  const RegisterData({
    required this.registrationToken,
    required this.otpMethod,
    required this.expiresIn,
  });

  /// Crée une instance depuis un Map JSON.
  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      registrationToken:
          (json['registration_token'] ?? json['registrationToken'] ?? '')
              .toString(),
      otpMethod: (json['otp_method'] ?? json['otpMethod'] ?? '').toString(),
      expiresIn: int.tryParse((json['expires_in'] ?? json['expiresIn'] ?? 0)
              .toString()) ??
          0,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'registration_token': registrationToken,
      'otp_method': otpMethod,
      'expires_in': expiresIn,
    };
  }

  @override
  String toString() {
    return 'RegisterData('
        'registrationToken: $registrationToken, '
        'otpMethod: $otpMethod, '
        'expiresIn: $expiresIn'
        ')';
  }
}

/// Données utilisateur retournées par le nouveau backend d'inscription.
class RegisterUser {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String? phoneCountryCode;
  final String? status;

  const RegisterUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phone,
    this.phoneCountryCode,
    this.status,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstname: (json['firstname'] ?? json['first_name'] ?? '').toString(),
      lastname: (json['lastname'] ?? json['last_name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      phoneCountryCode:
          (json['phoneCountryCode'] ?? json['phone_country_code'])?.toString(),
      status: json['status']?.toString(),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/constants/endpoint.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/features/auth/requests/forgot_password_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/google_sign_in_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/google_login_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/login_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/register_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/reset_password_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/resend_otp_request.dart';
import 'package:flutter_boilerplate/features/auth/requests/verify_otp_request.dart';
import 'package:flutter_boilerplate/features/auth/responses/forgot_password_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/resend_otp_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/google_sign_in_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/login_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/register_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/reset_password_response.dart';
import 'package:flutter_boilerplate/features/auth/responses/verify_otp_response.dart';

/// Repository pour gérer les opérations d'authentification.
///
/// Centralise tous les appels API liés à l'authentification :
/// - Inscription
/// - Connexion
/// - Vérification OTP
/// - Réinitialisation de mot de passe
class AuthRepository {
  final ApiClient _apiClient;

  /// Constructeur avec injection du client API.
  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  String _extractMessage(dynamic responseData, String fallback) {
    if (responseData is! Map) {
      return fallback;
    }

    final rawMessage = responseData['message'];
    if (rawMessage == null) {
      return fallback;
    }
    if (rawMessage is String && rawMessage.isNotEmpty) {
      return rawMessage;
    }
    if (rawMessage is List) {
      final values = rawMessage
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
      return values.isNotEmpty ? values.join('\n') : fallback;
    }

    final message = rawMessage.toString();
    return message.trim().isNotEmpty ? message : fallback;
  }

  Map<String, dynamic>? _extractErrors(dynamic responseData) {
    if (responseData is! Map) {
      return null;
    }

    final rawErrors = responseData['errors'];
    if (rawErrors is Map<String, dynamic>) {
      return rawErrors;
    }
    if (rawErrors is Map) {
      return Map<String, dynamic>.from(rawErrors);
    }

    return null;
  }

  Map<String, dynamic> _redactRegisterPayload(Map<String, dynamic> payload) {
    final redacted = Map<String, dynamic>.from(payload);
    if (redacted.containsKey('password')) {
      redacted['password'] = '***';
    }
    if (redacted.containsKey('password_confirmation')) {
      redacted['password_confirmation'] = '***';
    }
    return redacted;
  }

  /// Inscrit un nouvel utilisateur.
  ///
  /// Envoie les données d'inscription à l'API et retourne la réponse
  /// contenant le token d'inscription et les informations OTP.
  ///
  /// Paramètres :
  /// - [request] : Les données d'inscription de l'utilisateur
  ///
  /// Retourne :
  /// - [RegisterResponse] : La réponse de l'API avec le token d'inscription
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = RegisterRequest(
  ///   firstName: 'John',
  ///   lastName: 'Doe',
  ///   email: 'john@example.com',
  ///   phone: '90909090',
  ///   phoneCountryCode: '228',
  ///   password: 'password123',
  ///   passwordConfirmation: 'password123',
  ///   otpMethod: 'sms',
  /// );
  /// final response = await authRepository.register(request);
  /// ```
  Future<RegisterResponse> register(RegisterRequest request) async {
    final payload = request.toJson();
    if (kDebugMode) {
      debugPrint('[AuthRepository] register endpoint: ${ApiEndpoints.register}');
      debugPrint(
        '[AuthRepository] register request body: '
        '${_redactRegisterPayload(payload)}',
      );
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: payload,
      );

      if (kDebugMode) {
        debugPrint(
          '[AuthRepository] register response status: '
          '${response.statusCode}',
        );
        debugPrint(
          '[AuthRepository] register response data: ${response.data}',
        );
      }

      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AuthRepository] register DioException type: ${e.type}',
        );
        debugPrint(
          '[AuthRepository] register error status: '
          '${e.response?.statusCode}',
        );
        debugPrint(
          '[AuthRepository] register error response: ${e.response?.data}',
        );
      }

      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 409) {
          return const RegisterResponse(
            success: false,
            message: 'register_contact_unavailable',
            statusCode: 409,
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return RegisterResponse(
            success: false,
            message: _extractMessage(responseData, 'Erreur de validation'),
            errors: _extractErrors(responseData),
            statusCode: statusCode,
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return RegisterResponse(
            success: false,
            message: _extractMessage(
              responseData,
              'Erreur serveur. Veuillez réessayer.',
            ),
            statusCode: statusCode,
          );
        }

        // Autres erreurs HTTP
        return RegisterResponse(
          success: false,
          message: _extractMessage(
            responseData,
            'Une erreur est survenue. Veuillez réessayer.',
          ),
          errors: _extractErrors(responseData),
          statusCode: statusCode,
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Renvoie le code OTP pour l'inscription.
  ///
  /// Envoie une requête à l'API pour renvoyer le code OTP
  /// en utilisant le token d'inscription.
  ///
  /// Paramètres :
  /// - [request] : Les données de renvoi OTP (registration_token)
  ///
  /// Retourne :
  /// - [ResendOtpResponse] : La réponse de l'API
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = ResendOtpRequest(
  ///   registrationToken: 'abc123def456...',
  /// );
  /// final response = await authRepository.resendOtp(request);
  /// ```
  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resendOtp,
        data: request.toJson(),
      );

      return ResendOtpResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Token invalide ou expiré (404)
        if (statusCode == 404) {
          return ResendOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Token d\'inscription invalide ou expiré. Veuillez recommencer l\'inscription.',
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return ResendOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Impossible de renvoyer le code OTP.',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return ResendOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur lors du renvoi du code OTP.',
          );
        }

        // Autres erreurs HTTP
        return ResendOtpResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Vérifie le code OTP et finalise l'inscription.
  ///
  /// Envoie le code OTP à l'API pour vérification et création du compte.
  /// Retourne la réponse contenant les données utilisateur et le token d'authentification.
  ///
  /// Paramètres :
  /// - [request] : Les données de vérification OTP
  ///
  /// Retourne :
  /// - [VerifyOtpResponse] : La réponse de l'API avec le token et les données utilisateur
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = VerifyOtpRequest(
  ///   registrationToken: 'abc123def456...',
  ///   otpCode: '123456',
  ///   fcmToken: 'fcm_token_here',
  /// );
  /// final response = await authRepository.verifyOtp(request);
  /// ```
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      // Vérifier le status code pour s'assurer que c'est un succès (201)
      if (response.statusCode == 201) {
        return VerifyOtpResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      // Si le status code n'est pas 201, traiter comme une erreur
      final responseData = response.data as Map<String, dynamic>? ?? {};
      return VerifyOtpResponse(
        success: false,
        message:
            responseData['message'] as String? ??
            'Une erreur est survenue lors de la vérification.',
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Token invalide ou expiré (404)
        if (statusCode == 404) {
          return VerifyOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Token d\'inscription invalide ou expiré. Veuillez recommencer l\'inscription.',
          );
        }

        // Code OTP incorrect ou expiré (422)
        if (statusCode == 422) {
          return VerifyOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Code OTP incorrect ou expiré.',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return VerifyOtpResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Une erreur est survenue lors de la vérification.',
          );
        }

        // Autres erreurs HTTP
        return VerifyOtpResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Connecte un utilisateur.
  ///
  /// Authentifie un utilisateur avec son email ou téléphone et son mot de passe.
  /// Retourne la réponse contenant les données utilisateur et le token JWT.
  ///
  /// Paramètres :
  /// - [request] : Les données de connexion de l'utilisateur
  ///
  /// Retourne :
  /// - [LoginResponse] : La réponse de l'API avec le token JWT et les données utilisateur
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = LoginRequest.withEmail(
  ///   email: 'john@example.com',
  ///   password: 'password123',
  /// );
  /// final response = await authRepository.login(request);
  /// ```
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Identifiants invalides (401)
        if (statusCode == 401) {
          return LoginResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Les identifiants fournis sont incorrects.',
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return LoginResponse(
            success: false,
            message:
                responseData['message'] as String? ?? 'Erreur de validation',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return LoginResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Une erreur est survenue lors de la connexion.',
          );
        }

        // Autres erreurs HTTP
        return LoginResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Demande la réinitialisation du mot de passe.
  ///
  /// Envoie un code OTP par email ou SMS pour réinitialiser le mot de passe.
  ///
  /// Paramètres :
  /// - [request] : Les données de récupération (email ou téléphone)
  ///
  /// Retourne :
  /// - [ForgotPasswordResponse] : La réponse de l'API avec le reset_token
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = ForgotPasswordRequest.withEmail(
  ///   email: 'john@example.com',
  /// );
  /// final response = await authRepository.forgotPassword(request);
  /// ```
  Future<ForgotPasswordResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );

      return ForgotPasswordResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Utilisateur non trouvé (404)
        if (statusCode == 404) {
          return ForgotPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Aucun compte trouvé avec ces informations.',
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return ForgotPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ?? 'Erreur de validation',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return ForgotPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur lors de l\'envoi du code de réinitialisation.',
          );
        }

        // Autres erreurs HTTP
        return ForgotPasswordResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Réinitialise le mot de passe avec le code OTP.
  ///
  /// Vérifie le code OTP reçu et réinitialise le mot de passe de l'utilisateur.
  ///
  /// Paramètres :
  /// - [request] : Les données de réinitialisation (reset_token, otp_code, password)
  ///
  /// Retourne :
  /// - [ResetPasswordResponse] : La réponse de l'API
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final request = ResetPasswordRequest(
  ///   resetToken: 'abc123def456...',
  ///   otpCode: '123456',
  ///   password: 'newpassword123',
  ///   passwordConfirmation: 'newpassword123',
  /// );
  /// final response = await authRepository.resetPassword(request);
  /// ```
  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );

      return ResetPasswordResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Token invalide ou expiré (404)
        if (statusCode == 404) {
          return ResetPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Token de réinitialisation invalide ou expiré. Veuillez refaire une demande.',
          );
        }

        // Code OTP incorrect ou erreur de validation (422)
        if (statusCode == 422) {
          return ResetPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ?? 'Code OTP incorrect.',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return ResetPasswordResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Une erreur est survenue lors de la réinitialisation.',
          );
        }

        // Autres erreurs HTTP
        return ResetPasswordResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }

  /// Inscrit/connecte un utilisateur avec Google.
  ///
  /// Envoie les données Google à l'API pour créer un compte ou connecter
  /// un utilisateur existant. L'API gère automatiquement la synchronisation
  /// entre Google et la base de données.
  ///
  /// Paramètres :
  /// - [request] : Les données d'authentification Google
  ///
  /// Retourne :
  /// - [GoogleSignInResponse] : La réponse de l'API avec le token JWT et les données utilisateur
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Sécurité :
  /// - Toutes les données Google sont validées côté serveur
  /// - Le token JWT est généré par le serveur (pas côté client)
  /// - Synchronisation stricte avec Google (mise à jour automatique des infos)
  ///
  /// Exemple :
  /// ```dart
  /// final request = GoogleSignInRequest(
  ///   googleId: '123456789012345678901',
  ///   email: 'user@gmail.com',
  ///   name: 'John Doe',
  ///   avatar: 'https://lh3.googleusercontent.com/...',
  ///   fcmToken: 'fcm_token_here',
  /// );
  /// final response = await authRepository.registerWithGoogle(request);
  /// ```
  Future<GoogleSignInResponse> registerWithGoogle(
    GoogleSignInRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.registerWithGoogle,
        data: request.toJson(),
      );

      // Vérifier les status codes de succès (200 ou 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedResponse = GoogleSignInResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return parsedResponse;
      }

      // Si le status code n'est pas 200/201, traiter comme une erreur
      final responseData = response.data as Map<String, dynamic>? ?? {};
      return GoogleSignInResponse(
        success: false,
        message:
            responseData['message'] as String? ??
            'Une erreur est survenue lors de l\'authentification avec Google.',
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Erreur de validation (422)
        if (statusCode == 422) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Données Google invalides. Veuillez réessayer.',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }

        // Utilisateur bloqué ou compte invalide (401/403)
        if (statusCode == 401 || statusCode == 403) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Accès refusé. Votre compte pourrait être bloqué.',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur serveur. Veuillez réessayer plus tard.',
          );
        }

        // Autres erreurs HTTP
        return GoogleSignInResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Connecte un utilisateur avec Google (id_token).
  ///
  /// Vérifie un id_token Google côté serveur, connecte l'utilisateur
  /// (ou crée un compte si inexistant) et retourne un token JWT.
  ///
  /// Paramètres :
  /// - [request] : Les données d'authentification Google (id_token)
  ///
  /// Retourne :
  /// - [GoogleSignInResponse] : La réponse de l'API avec le token JWT et les données utilisateur
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Sécurité :
  /// - L'id_token est validé côté serveur
  /// - Le token JWT est généré par le serveur
  /// - Création automatique du compte si l'utilisateur n'existe pas
  ///
  /// Exemple :
  /// ```dart
  /// final request = GoogleLoginRequest(
  ///   idToken: 'eyJhbGciOiJSUzI1NiIsImtpZCI6Ii4uLiJ9...',
  ///   fcmToken: 'fcm_token_here',
  /// );
  /// final response = await authRepository.loginWithGoogle(request);
  /// ```
  Future<GoogleSignInResponse> loginWithGoogle(
    GoogleLoginRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.loginWithGoogle,
        data: request.toJson(),
      );

      // Vérifier le status code de succès (200)
      if (response.statusCode == 200) {
        final parsedResponse = GoogleSignInResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return parsedResponse;
      }

      // Si le status code n'est pas 200, traiter comme une erreur
      final responseData = response.data as Map<String, dynamic>? ?? {};
      return GoogleSignInResponse(
        success: false,
        message:
            responseData['message'] as String? ??
            'Une erreur est survenue lors de la connexion avec Google.',
      );
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Token Google invalide (401)
        if (statusCode == 401) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Token Google invalide ou expiré.',
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ?? 'Erreur de validation',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return GoogleSignInResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur serveur. Veuillez réessayer plus tard.',
          );
        }

        // Autres erreurs HTTP
        return GoogleSignInResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

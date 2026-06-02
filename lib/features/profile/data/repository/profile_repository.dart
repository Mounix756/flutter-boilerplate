import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/constants/endpoint.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/features/profile/data/response/change_password_response.dart';
import 'package:flutter_boilerplate/features/profile/data/response/countries_response.dart';
import 'package:flutter_boilerplate/features/profile/data/response/profile_response.dart';
import 'package:flutter_boilerplate/features/profile/data/response/update_profile_response.dart';
import 'package:flutter_boilerplate/features/profile/requests/change_password_request.dart';

/// Repository pour gérer les opérations liées au profil utilisateur.
///
/// Centralise tous les appels API liés au profil :
/// - Récupération du profil
/// - Mise à jour du profil
class ProfileRepository {
  final ApiClient _apiClient;

  /// Constructeur avec injection du client API.
  ProfileRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  String _extractMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      if (message is List) {
        final joined = message
            .where((e) => e != null)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .join('\n');
        if (joined.isNotEmpty) {
          return joined;
        }
      }
      if (message != null) {
        final asText = message.toString();
        if (asText.isNotEmpty) {
          return asText;
        }
      }
    }
    return fallback;
  }

  Map<String, dynamic>? _extractErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        return errors;
      }
      if (errors is Map) {
        return Map<String, dynamic>.from(errors);
      }
    }
    return null;
  }

  /// Récupère le profil de l'utilisateur connecté.
  ///
  /// Envoie une requête GET à l'API pour récupérer les informations
  /// du profil de l'utilisateur authentifié via JWT.
  ///
  /// Retourne :
  /// - [ProfileResponse] : La réponse de l'API avec les données du profil
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await profileRepository.getProfile();
  /// if (response.success) {
  ///   final user = response.data?.user;
  ///   print('Nom: ${user?.fullName}');
  /// }
  /// ```
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Gestion des erreurs HTTP spécifiques
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Non authentifié (401)
        if (statusCode == 401) {
          return ProfileResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Non authentifié. Token JWT invalide ou expiré.',
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return ProfileResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur serveur. Veuillez réessayer.',
          );
        }

        // Autres erreurs HTTP
        return ProfileResponse(
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

  /// Récupère la liste des pays disponibles.
  ///
  /// Retourne :
  /// - [CountriesResponse] : La réponse de l'API avec la liste des pays
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  Future<CountriesResponse> getCountries() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.countries);

      // Vérifier que la réponse contient des données
      if (response.data == null) {
        return CountriesResponse(success: false, data: [], count: 0);
      }

      // Parser la réponse JSON
      final responseData = response.data;

      // Si responseData est déjà un Map, l'utiliser directement
      if (responseData is Map<String, dynamic>) {
        return CountriesResponse.fromJson(responseData);
      }

      // Sinon, essayer de le convertir
      return CountriesResponse.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        if (statusCode == 401) {
          return CountriesResponse(success: false, data: [], count: 0);
        }

        if (statusCode == 500) {
          return CountriesResponse(success: false, data: [], count: 0);
        }

        return CountriesResponse(success: false, data: [], count: 0);
      }

      // Erreur réseau (pas de réponse du serveur)
      return CountriesResponse(success: false, data: [], count: 0);
    } catch (e) {
      // Erreur de parsing ou autre
      return CountriesResponse(success: false, data: [], count: 0);
    }
  }

  /// Met à jour le profil de l'utilisateur connecté.
  ///
  /// Paramètres :
  /// - [firstname] : Prénom (optionnel)
  /// - [lastname] : Nom (optionnel)
  /// - [email] : Email (optionnel)
  /// - [phone] : Téléphone au format E.164 (optionnel)
  /// - [address] : Adresse (optionnel)
  /// - [city] : Ville (optionnel)
  /// - [countryId] : ID du pays (optionnel)
  /// - [latitude] : Latitude (optionnel)
  /// - [longitude] : Longitude (optionnel)
  ///
  /// Retourne :
  /// - [UpdateProfileResponse] : La réponse de l'API avec les données mises à jour
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  Future<UpdateProfileResponse> updateProfile({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? countryId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // L'API attend un body JSON (pas multipart/form-data).
      final payload = <String, dynamic>{};

      if (firstname != null && firstname.isNotEmpty) {
        payload['firstname'] = firstname;
      }
      if (lastname != null && lastname.isNotEmpty) {
        payload['lastname'] = lastname;
      }
      if (email != null && email.isNotEmpty) {
        payload['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        payload['phone'] = phone;
      }
      if (address != null && address.isNotEmpty) {
        payload['address'] = address;
      }
      if (city != null && city.isNotEmpty) {
        payload['city'] = city;
      }
      if (countryId != null && countryId.isNotEmpty) {
        payload['country_id'] = countryId;
      }
      if (latitude != null) {
        payload['latitude'] = latitude;
      }
      if (longitude != null) {
        payload['longitude'] = longitude;
      }

      final response = await _apiClient.put(
        ApiEndpoints.profile,
        data: payload,
      );

      return UpdateProfileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401) {
          return UpdateProfileResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Non authentifié. Token JWT invalide ou expiré.',
          );
        }

        if (statusCode == 422) {
          return UpdateProfileResponse(
            success: false,
            message:
                responseData['message'] as String? ?? 'Erreur de validation',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }

        if (statusCode == 500) {
          return UpdateProfileResponse(
            success: false,
            message:
                responseData['message'] as String? ??
                'Erreur serveur. Veuillez réessayer.',
          );
        }

        return UpdateProfileResponse(
          success: false,
          message:
              responseData['message'] as String? ??
              'Une erreur est survenue. Veuillez réessayer.',
        );
      }
      rethrow;
    }
  }

  /// Change le mot de passe de l'utilisateur connecté.
  ///
  /// Paramètres :
  /// - [request] : Les données de changement de mot de passe
  ///
  /// Retourne :
  /// - [ChangePasswordResponse] : La réponse de l'API
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.changePassword,
        data: request.toJson(),
      );

      return ChangePasswordResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Non authentifié ou mot de passe actuel incorrect (401)
        if (statusCode == 401) {
          return ChangePasswordResponse(
            success: false,
            message: _extractMessage(
              responseData,
              'Le mot de passe actuel est incorrect.',
            ),
          );
        }

        // Erreur de validation (422)
        if (statusCode == 422) {
          return ChangePasswordResponse(
            success: false,
            message: _extractMessage(responseData, 'Erreur de validation'),
            errors: _extractErrors(responseData),
          );
        }

        // Erreur serveur (500)
        if (statusCode == 500) {
          return ChangePasswordResponse(
            success: false,
            message: _extractMessage(
              responseData,
              'Une erreur est survenue lors de la mise à jour du mot de passe.',
            ),
          );
        }

        // Autres erreurs HTTP
        return ChangePasswordResponse(
          success: false,
          message: _extractMessage(
            responseData,
            'Une erreur est survenue. Veuillez réessayer.',
          ),
        );
      }

      // Erreur réseau (pas de réponse du serveur)
      rethrow;
    }
  }
}

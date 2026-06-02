import 'package:get/get.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/features/profile/data/models/user.dart';
import 'package:flutter_boilerplate/features/profile/data/repository/profile_repository.dart';

/// Controller pour gérer l'état du profil utilisateur.
///
/// Gère :
/// - Le chargement du profil
/// - L'état du profil (chargé, erreur)
/// - Les opérations de mise à jour du profil
class ProfileController extends GetxController {
  final ProfileRepository _profileRepository;
  final AuthService _authService;

  // État réactif
  final _user = Rxn<User>();
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  /// Utilisateur actuel (null si non chargé ou erreur).
  User? get user => _user.value;

  /// Indique si le profil est en cours de chargement.
  bool get isLoading => _isLoading.value;

  /// Message d'erreur si le chargement a échoué (null si pas d'erreur).
  String? get error => _error.value;

  /// Indique si le profil a été chargé avec succès.
  bool get hasProfile => _user.value != null;

  ProfileController({
    ProfileRepository? profileRepository,
    AuthService? authService,
  }) : _profileRepository = profileRepository ?? Get.find<ProfileRepository>(),
       _authService = authService ?? Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // Charger automatiquement le profil si l'utilisateur est authentifié
    if (_authService.isAuthenticated) {
      loadProfile();
    }
  }

  /// Charge le profil de l'utilisateur depuis l'API.
  ///
  /// Met à jour l'état réactif avec les données du profil ou l'erreur.
  ///
  /// Retourne :
  /// - `true` si le profil a été chargé avec succès
  /// - `false` en cas d'erreur
  ///
  /// Exemple :
  /// ```dart
  /// final controller = Get.find<ProfileController>();
  /// final success = await controller.loadProfile();
  /// if (success) {
  ///   print('Profil chargé: ${controller.user?.fullName}');
  /// }
  /// ```
  Future<bool> loadProfile() async {
    // Vérifier que l'utilisateur est authentifié
    if (!_authService.isAuthenticated) {
      _error.value = 'Utilisateur non authentifié';
      return false;
    }

    try {
      _isLoading.value = true;
      _error.value = null;

      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        _user.value = response.data!.user;
        _error.value = null;
        return true;
      } else {
        // Vérifier si l'erreur est due à un JWT expiré (401)
        final errorMessage = response.message.toLowerCase();
        final isAuthError =
            errorMessage.contains('non authentifié') ||
            errorMessage.contains('token jwt invalide') ||
            errorMessage.contains('token jwt expiré') ||
            errorMessage.contains('401');

        if (isAuthError) {
          // Déconnecter l'utilisateur si le JWT est expiré
          await _authService.logout();
          clearProfile();
        }

        _error.value = response.message;
        _user.value = null;
        return false;
      }
    } catch (e) {
      _error.value = 'Erreur lors du chargement du profil: ${e.toString()}';
      _user.value = null;
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Réinitialise le profil (utile lors de la déconnexion).
  void clearProfile() {
    _user.value = null;
    _error.value = null;
    _isLoading.value = false;
  }

  /// Rafraîchit le profil (recharge depuis l'API).
  ///
  /// Utile pour mettre à jour les données après une modification.
  Future<bool> refreshProfile() {
    return loadProfile();
  }

  /// Met à jour immédiatement le profil en mémoire locale.
  ///
  /// Permet de refléter les changements UI sans attendre un rechargement API.
  void setUser(User user) {
    _user.value = user;
    _error.value = null;
  }
}

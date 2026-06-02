import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Service pour gérer la détection de la connectivité réseau.
///
/// Permet de vérifier l'état de la connexion internet et d'écouter
/// les changements de connectivité en temps réel.
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Observable indiquant si l'appareil est connecté à internet.
  RxBool get isConnected => _isConnected;

  /// Initialise le service et commence à écouter les changements de connectivité.
  Future<void> init() async {
    // Vérifier l'état initial
    await checkConnectivity();

    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectionStatus(results);
      },
    );
  }

  /// Vérifie l'état actuel de la connectivité.
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      // En cas d'erreur, considérer comme non connecté
      _isConnected.value = false;
    }
  }

  /// Met à jour le statut de connexion en fonction des résultats.
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Considérer comme connecté si au moins un type de connexion est disponible
    // et qu'il n'est pas "none"
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _isConnected.value = hasConnection;
  }

  /// Vérifie si l'appareil est actuellement connecté à internet.
  ///
  /// Note: Cette méthode vérifie uniquement la disponibilité d'une connexion réseau
  /// (WiFi, mobile, etc.), pas nécessairement l'accès à internet.
  /// Pour une vérification plus précise, utilisez [checkConnectivity] qui fait
  /// une vérification en temps réel.
  bool get hasConnection => _isConnected.value;

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

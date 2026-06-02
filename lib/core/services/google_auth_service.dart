import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_boilerplate/core/constants/api.dart';

/// Service de gestion de l'authentification Google.
///
/// Encapsule toute la logique d'authentification Google OAuth pour l'application.
/// Gère la connexion, la déconnexion et la récupération des informations utilisateur.
///
/// Sécurité :
/// - Gestion robuste des erreurs avec try-catch
/// - Nettoyage automatique en cas d'échec
/// - Logging sécurisé (pas de données sensibles)
///
/// Performance :
/// - Instance singleton pour éviter les multiples initialisations
/// - Mise en cache des informations utilisateur
class GoogleAuthService {
  /// Instance singleton du SDK Google Sign-In (API v7).
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(serverClientId: ApiConstants.googleClientId);
    _googleInitialized = true;
  }

  /// Utilisateur Google actuellement connecté (cache)
  static GoogleSignInAccount? _currentUser;

  /// Récupère l'utilisateur actuellement connecté
  static GoogleSignInAccount? get currentUser => _currentUser;

  /// Initialise le service et vérifie si un utilisateur est déjà connecté.
  ///
  /// Retourne :
  /// - [GoogleSignInAccount?] : L'utilisateur connecté ou null
  ///
  /// Sécurité :
  /// - Gestion des erreurs silencieuse pour ne pas bloquer l'application
  static Future<GoogleSignInAccount?> initSilently() async {
    try {
      await _ensureInitialized();
      final attempt = _googleSignIn.attemptLightweightAuthentication();
      if (attempt == null) {
        return null;
      }
      _currentUser = await attempt;
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  /// ```
  ///
  /// Sécurité :
  /// - Validation de toutes les données reçues de Google
  /// - Nettoyage automatique en cas d'erreur
  /// - Pas de stockage de tokens côté client (géré par le SDK)
  static Future<Map<String, dynamic>> signIn() async {
    try {
      await _ensureInitialized();
      // Étape 1 : Déconnexion préventive pour éviter les états incohérents
      await _googleSignIn.signOut();

      // Étape 2 : Lancement du flow d'authentification Google
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // Étape 3 : Vérification que l'utilisateur n'a pas annulé
      // Étape 4 : Récupération des informations d'authentification
      final GoogleSignInAuthentication auth = account.authentication;

      // Debug: Vérifier la présence de l'id_token
      if (auth.idToken == null || auth.idToken!.isEmpty) {
        await signOut();
        return {
          'success': false,
          'message':
              'Token Google non disponible. Veuillez vérifier la configuration de votre compte Google.',
        };
      }

      // Étape 5 : Validation des données essentielles
      if (account.id.isEmpty || account.email.isEmpty) {
        await signOut();
        return {
          'success': false,
          'message': 'Données Google invalides. Veuillez réessayer.',
        };
      }

      // Étape 6 : Mise en cache de l'utilisateur
      _currentUser = account;

      // Étape 7 : Retour des données validées
      final result = {
        'success': true,
        'googleId': account.id,
        'email': account.email,
        'displayName': account.displayName ?? '',
        'photoUrl': account.photoUrl,
        'idToken': auth.idToken,
      };
      return result;
    } catch (e) {
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        return {
          'success': false,
          'cancelled': true,
          'message': 'Connexion Google annulée par l\'utilisateur',
        };
      }

      // Sécurité : Nettoyage en cas d'erreur
      await signOut();

      return {
        'success': false,
        'message':
            'Une erreur est survenue lors de la connexion avec Google. '
            'Veuillez vérifier votre connexion internet et réessayer.',
      };
    }
  }

  /// Déconnecte l'utilisateur de Google.
  ///
  /// Sécurité :
  /// - Déconnexion complète (pas seulement locale)
  /// - Nettoyage de toutes les données en cache
  /// - Gestion des erreurs silencieuse
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      // On force le nettoyage même en cas d'erreur
      _currentUser = null;
    }
  }

  /// Déconnecte l'utilisateur et révoque l'accès à l'application.
  ///
  /// Plus sécurisé que signOut() car révoque tous les tokens.
  /// À utiliser lors de la suppression de compte ou déconnexion définitive.
  static Future<void> disconnect() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.disconnect();
      _currentUser = null;
    } catch (e) {
      // Fallback sur signOut si disconnect échoue
      await signOut();
    }
  }

  /// Vérifie si un utilisateur est actuellement connecté à Google.
  ///
  /// Retourne :
  /// - [bool] : true si un utilisateur est connecté, false sinon
  static Future<bool> isSignedIn() async {
    try {
      await _ensureInitialized();
      if (_currentUser != null) return true;

      final attempt = _googleSignIn.attemptLightweightAuthentication();
      if (attempt == null) return false;

      _currentUser = await attempt;
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }
}

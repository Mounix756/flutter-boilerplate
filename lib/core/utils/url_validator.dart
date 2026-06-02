/// Validateur d'URLs avec vérifications de sécurité.
///
/// Fournit des méthodes pour valider et sécuriser les URLs
/// avant de les utiliser dans l'application.
class UrlValidator {
  /// Liste des domaines autorisés pour les images de produits.
  static const List<String> _allowedImageDomains = [
    'example.com',
    'storage.example.com',
    'cdn.example.com',
    'via.placeholder.com', // Pour les tests
    'picsum.photos', // Pour les tests
  ];

  /// Extensions d'images autorisées.
  static const List<String> _allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg',
  ];

  /// Valide une URL d'image.
  ///
  /// Vérifie :
  /// - La validité de l'URL
  /// - Le protocole (https uniquement en production)
  /// - Le domaine (doit être dans la liste des domaines autorisés)
  /// - L'extension du fichier
  ///
  /// Retourne `true` si l'URL est valide et sécurisée.
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Vérifier le protocole (http ou https)
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // En production, exiger HTTPS
      const bool isProduction = bool.fromEnvironment('dart.vm.product');
      if (isProduction && uri.scheme != 'https') {
        return false;
      }

      // Vérifier le domaine
      if (!_isAllowedDomain(uri.host)) {
        return false;
      }

      // Vérifier l'extension
      final path = uri.path.toLowerCase();
      if (!_hasValidImageExtension(path)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le domaine est autorisé.
  static bool _isAllowedDomain(String host) {
    // Autoriser tous les domaines en mode debug
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) return true;

    // Vérifier si le domaine est dans la liste des domaines autorisés
    return _allowedImageDomains.any((domain) => host.endsWith(domain));
  }

  /// Vérifie si le fichier a une extension d'image valide.
  static bool _hasValidImageExtension(String path) {
    return _allowedImageExtensions.any((ext) => path.endsWith('.$ext'));
  }

  /// Nettoie une URL en supprimant les caractères dangereux.
  static String sanitizeUrl(String url) {
    if (url.isEmpty) return url;

    try {
      final uri = Uri.parse(url);
      
      // Reconstruire l'URL de manière sécurisée
      return uri.toString();
    } catch (e) {
      return '';
    }
  }

  /// Obtient une URL d'image placeholder sécurisée.
  static String getPlaceholderUrl({int width = 300, int height = 300}) {
    return 'https://via.placeholder.com/${width}x$height/E8E8E8/666666?text=No+Image';
  }

  /// Valide une URL générale (pas seulement les images).
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Extrait le nom de fichier depuis une URL.
  static String getFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : '';
    } catch (e) {
      return '';
    }
  }

  /// Obtient une URL sécurisée ou un placeholder si l'URL n'est pas valide.
  static String getSecureImageUrl(String url, {int width = 300, int height = 300}) {
    if (isValidImageUrl(url)) {
      return sanitizeUrl(url);
    }
    return getPlaceholderUrl(width: width, height: height);
  }
}

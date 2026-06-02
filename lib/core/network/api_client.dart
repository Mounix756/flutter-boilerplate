import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:flutter_boilerplate/core/constants/api.dart';
import 'package:flutter_boilerplate/core/constants/routes.dart';
import 'package:flutter_boilerplate/core/errors/error_reporter.dart';
import 'package:flutter_boilerplate/core/services/auth_service.dart';
import 'package:flutter_boilerplate/core/services/connectivity_service.dart';

/// Client HTTP pour les appels API de l'application Flutter Boilerplate.
///
/// Cette classe encapsule une instance de Dio et fournit des méthodes
/// simplifiées pour effectuer des requêtes HTTP (GET, POST, PUT, DELETE).
/// Elle gère automatiquement les headers communs, les timeouts et permet
/// la gestion dynamique des tokens d'authentification.
class ApiClient {
  /// Instance privée de Dio utilisée pour toutes les requêtes HTTP.
  final Dio _dio;

  /// Constructeur qui initialise le client API avec la configuration de base.
  ///
  /// Configure :
  /// - L'URL de base depuis [ApiConstants.baseUrl]
  /// - Les timeouts à 30 secondes pour connect, receive et send
  /// - Les headers par défaut : X-API-KEY, Content-Type et Accept
  /// - Un intercepteur pour gérer les erreurs de connexion
  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
          headers: {
            'X-API-KEY': ApiConstants.apiKey,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ConnectionErrorInterceptor());
  }

  /// Définit un header personnalisé pour toutes les requêtes futures.
  ///
  /// Permet d'ajouter ou de modifier n'importe quel header HTTP.
  ///
  /// Paramètres :
  /// - [key] : Le nom du header (ex: 'X-Custom-Header')
  /// - [value] : La valeur du header
  ///
  /// Exemple :
  /// ```dart
  /// apiClient.setCustomHeader('X-Device-ID', 'device-123');
  /// ```
  void setCustomHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Effectue une requête HTTP GET.
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  /// - [queryParameters] : Paramètres de requête optionnels à ajouter à l'URL
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau, timeout ou erreur HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await apiClient.get('/products', queryParameters: {'page': 1});
  /// ```
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP POST.
  ///
  /// Utilisé pour créer de nouvelles ressources ou envoyer des données au serveur.
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  /// - [data] : Les données à envoyer dans le corps de la requête (sera sérialisé en JSON)
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau, timeout ou erreur HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await apiClient.post('/auth/login', data: {'email': 'user@example.com'});
  /// ```
  Future<Response> post(
    String path, {
    dynamic data,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    CancelToken? cancelToken,
  }) async {
    try {
      final originalConnectTimeout = _dio.options.connectTimeout;
      if (connectTimeout != null) {
        _dio.options.connectTimeout = connectTimeout;
      }

      try {
        return await _dio.post(
          path,
          data: data,
          cancelToken: cancelToken,
          options: Options(
            sendTimeout: sendTimeout,
            receiveTimeout: receiveTimeout,
          ),
        );
      } finally {
        _dio.options.connectTimeout = originalConnectTimeout;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP PUT.
  ///
  /// Utilisé pour mettre à jour une ressource existante (remplacement complet).
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  /// - [data] : Les données à envoyer dans le corps de la requête (sera sérialisé en JSON)
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau, timeout ou erreur HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await apiClient.put('/products/123', data: {'name': 'Nouveau nom'});
  /// ```
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP PATCH.
  ///
  /// Utilisé pour mettre à jour partiellement une ressource existante.
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP DELETE.
  ///
  /// Utilisé pour supprimer une ressource existante.
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  /// - [data] : Les données optionnelles à envoyer dans le corps de la requête
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau, timeout ou erreur HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await apiClient.delete('/products/123');
  /// final response2 = await apiClient.delete('/wishlist', data: {'product_ids': ['id1', 'id2']});
  /// ```
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP PUT avec FormData (multipart/form-data).
  ///
  /// Utilisé pour mettre à jour une ressource avec des fichiers (images, etc.).
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  /// - [formData] : Les données FormData à envoyer
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau, timeout ou erreur HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'name': 'John',
  ///   'image': await MultipartFile.fromFile('/path/to/image.jpg'),
  /// });
  /// final response = await apiClient.putMultipart('/profile', formData: formData);
  /// ```
  Future<Response> putMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      // Sauvegarder le Content-Type actuel
      final originalContentType = _dio.options.headers['Content-Type'];

      // Retirer le Content-Type pour laisser Dio le définir automatiquement pour FormData
      _dio.options.headers.remove('Content-Type');

      try {
        return await _dio.put(path, data: formData);
      } finally {
        // Restaurer le Content-Type original
        if (originalContentType != null) {
          _dio.options.headers['Content-Type'] = originalContentType;
        } else {
          _dio.options.headers['Content-Type'] = 'application/json';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Effectue une requête HTTP POST avec FormData (multipart/form-data).
  ///
  /// Utilisé pour créer une ressource avec upload de fichiers.
  Future<Response> postMultipart(
    String path, {
    required FormData formData,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    CancelToken? cancelToken,
  }) async {
    try {
      final originalContentType = _dio.options.headers['Content-Type'];
      final originalConnectTimeout = _dio.options.connectTimeout;
      _dio.options.headers.remove('Content-Type');
      if (connectTimeout != null) {
        _dio.options.connectTimeout = connectTimeout;
      }

      try {
        return await _dio.post(
          path,
          data: formData,
          cancelToken: cancelToken,
          options: Options(
            sendTimeout: sendTimeout,
            receiveTimeout: receiveTimeout,
          ),
        );
      } finally {
        _dio.options.connectTimeout = originalConnectTimeout;
        if (originalContentType != null) {
          _dio.options.headers['Content-Type'] = originalContentType;
        } else {
          _dio.options.headers['Content-Type'] = 'application/json';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Télécharge un fichier binaire depuis l'API.
  ///
  /// Utilisé pour télécharger des fichiers (PDF, images, etc.).
  ///
  /// Paramètres :
  /// - [path] : Le chemin de l'endpoint (relatif à baseUrl)
  ///
  /// Retourne :
  /// - [Response] : La réponse HTTP de Dio contenant les données binaires
  ///
  /// Lance :
  /// - [DioException] : En cas d'erreur réseau ou HTTP
  ///
  /// Exemple :
  /// ```dart
  /// final response = await apiClient.downloadFile('/orders/123/invoice');
  /// final bytes = response.data as List<int>;
  /// ```
  Future<Response> downloadFile(String path) async {
    try {
      return await _dio.get(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Intercepteur pour gérer les erreurs de connexion réseau.
///
/// Détecte les erreurs de connexion (timeout, erreur de connexion, etc.)
/// et navigue automatiquement vers la page de problème de connexion
/// si l'utilisateur n'est pas déjà sur cette page.
class _ConnectionErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Vérifier si c'est une erreur de connexion
    final isConnectionError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown &&
            err.error?.toString().contains('SocketException') == true);

    if (isConnectionError) {
      // Vérifier si le service de connectivité est disponible
      if (Get.isRegistered<ConnectivityService>()) {
        final connectivityService = Get.find<ConnectivityService>();

        // Mettre à jour le statut de connexion
        connectivityService.checkConnectivity();

        // Vérifier si on n'est pas déjà sur la page de problème de connexion
        final currentRoute = Get.currentRoute;
        if (currentRoute != AppRoutes.noConnection) {
          // Naviguer vers la page de problème de connexion
          Get.toNamed(AppRoutes.noConnection);
        }
      }
    }

    // Continuer avec le traitement normal de l'erreur
    handler.next(err);
  }
}

class _AuthInterceptor extends Interceptor {
  static const _authorizationHeader = 'Authorization';
  static const _sessionHandledExtraKey = 'auth_session_handled';
  static const _publicAuthPrefixes = <String>{
    'auth/login',
    'auth/register',
    'auth/forgot-password',
    'auth/reset-password',
    'auth/verify-email',
    'auth/verify-phone',
    'auth/verify-code',
    'auth/verify-otp',
    'auth/resend-otp',
  };
  static const _nonSessionFailurePaths = <String>{
    'auth/profile/password',
  };

  final FlutterSecureStorage _secureStorage;

  _AuthInterceptor({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_shouldAttachToken(options)) {
      options.headers.remove(_authorizationHeader);
      handler.next(options);
      return;
    }

    options.headers.remove(_authorizationHeader);
    final token = await _secureStorage.read(key: AuthService.authTokenKey);
    if (token != null && token.trim().isNotEmpty) {
      options.headers[_authorizationHeader] = 'Bearer ${token.trim()}';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final wasAuthenticatedRequest =
        err.requestOptions.headers[_authorizationHeader] != null;

    if (wasAuthenticatedRequest &&
        (statusCode == 401 || statusCode == 403) &&
        !_canReturnBusinessUnauthorized(err.requestOptions) &&
        err.requestOptions.extra[_sessionHandledExtraKey] != true) {
      err.requestOptions.extra[_sessionHandledExtraKey] = true;
      await _expireSession(statusCode);
    }

    handler.next(err);
  }

  bool _shouldAttachToken(RequestOptions options) {
    final path = options.path.startsWith('/')
        ? options.path.substring(1)
        : options.path;
    return !_publicAuthPrefixes.any(path.startsWith);
  }

  bool _canReturnBusinessUnauthorized(RequestOptions options) {
    final path = options.path.startsWith('/')
        ? options.path.substring(1)
        : options.path;
    return _nonSessionFailurePaths.any(path.startsWith);
  }

  Future<void> _expireSession(int? statusCode) async {
    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().expireSession(reason: 'http_$statusCode');
      return;
    }

    try {
      await _secureStorage.delete(key: AuthService.authTokenKey);
      await Get.offAllNamed(AppRoutes.authOptions);
    } catch (e, stackTrace) {
      ErrorReporter.reportWarning(
        'Unable to clear auth token after unauthorized response',
        error: e,
        stackTrace: stackTrace,
        metadata: {'statusCode': statusCode},
      );
    }
  }
}

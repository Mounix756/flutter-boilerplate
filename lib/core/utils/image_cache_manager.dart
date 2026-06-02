import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Gestionnaire de cache pour les images.
///
/// Fournit une configuration optimisée pour le cache des images
/// avec gestion du cache intégré de CachedNetworkImage.
class ImageCacheManager {
  /// Précharge une image dans le cache.
  ///
  /// Utile pour précharger les images des produits à l'avance.
  static Future<void> preloadImage(String url, BuildContext context) async {
    if (url.isEmpty) return;

    try {
      final imageProvider = CachedNetworkImageProvider(url);
      await precacheImage(imageProvider, context);
    } catch (e) {
      // Erreur silencieuse lors du précache
    }
  }

  /// Précharge plusieurs images en parallèle.
  static Future<void> preloadImages(
    List<String> urls,
    BuildContext context,
  ) async {
    await Future.wait(urls.map((url) => preloadImage(url, context)));
  }

  /// Nettoie le cache des images.
  static Future<void> clearCache() async {
    try {
      // Vider le cache mémoire de Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      // Erreur silencieuse lors du nettoyage
    }
  }

  /// Obtient des informations sur le cache d'images.
  static Map<String, dynamic> getCacheInfo() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': imageCache.currentSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSize': imageCache.maximumSize,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
      'liveImageCount': imageCache.liveImageCount,
      'pendingImageCount': imageCache.pendingImageCount,
    };
  }

  /// Formate la taille du cache en format lisible.
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

/// Widget d'image optimisée avec gestion du cache.
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      // Optimisations mémoire
      // Vérifier que les dimensions sont finies avant de les convertir
      memCacheWidth: width != null && width!.isFinite
          ? (width! * 2).toInt()
          : null,
      memCacheHeight: height != null && height!.isFinite
          ? (height! * 2).toInt()
          : null,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}

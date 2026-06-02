/// Moniteur de performance pour l'application.
///
/// Permet de mesurer et logger les performances critiques :
/// - Temps de chargement des produits
/// - Temps de chargement des images
/// - Temps de réponse des API
/// - Utilisation mémoire
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};

  /// Démarre la mesure d'une opération.
  static void start(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// Termine la mesure d'une opération.
  static void end(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      return;
    }

    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operationName);

    _measurements.putIfAbsent(operationName, () => []).add(duration);
  }

  /// Mesure une opération asynchrone.
  static Future<T> measure<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    start(operationName);
    try {
      return await operation();
    } finally {
      end(operationName);
    }
  }

  /// Obtient les statistiques pour une opération.
  static PerformanceStats? getStats(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) {
      return null;
    }

    final totalMs = measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    final avgMs = totalMs / measurements.length;
    final minMs = measurements.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b);
    final maxMs = measurements.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);

    return PerformanceStats(
      operationName: operationName,
      count: measurements.length,
      averageMs: avgMs,
      minMs: minMs,
      maxMs: maxMs,
    );
  }

  /// Affiche un rapport de toutes les opérations mesurées.
  static void printReport() {
    // Désactivé par défaut
  }

  /// Réinitialise toutes les mesures.
  static void reset() {
    _startTimes.clear();
    _measurements.clear();
  }

}

/// Statistiques de performance pour une opération.
class PerformanceStats {
  final String operationName;
  final int count;
  final double averageMs;
  final int minMs;
  final int maxMs;

  const PerformanceStats({
    required this.operationName,
    required this.count,
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
  });

  @override
  String toString() {
    return 'PerformanceStats(operation: $operationName, count: $count, '
        'avg: ${averageMs.toStringAsFixed(0)}ms, min: ${minMs}ms, max: ${maxMs}ms)';
  }
}

/// Mixin pour ajouter facilement le monitoring de performance.
mixin PerformanceMonitoring {
  Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    return PerformanceMonitor.measure(operationName, operation);
  }
}

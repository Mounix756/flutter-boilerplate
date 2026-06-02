import 'package:flutter_boilerplate/features/profile/data/models/country.dart';

/// Modèle de réponse pour la liste des pays.
class CountriesResponse {
  final bool success;
  final List<Country> data;
  final int count;

  const CountriesResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  /// Crée une instance depuis un Map JSON.
  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CountriesResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((item) => Country.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((country) => country.toJson()).toList(),
      'count': count,
    };
  }

  @override
  String toString() {
    return 'CountriesResponse(success: $success, count: $count, data: ${data.length} countries)';
  }
}

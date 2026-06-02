/// Modèle représentant un pays.
class Country {
  final String id;
  final String name;
  final String code;

  const Country({
    required this.id,
    required this.name,
    required this.code,
  });

  /// Crée une instance depuis un Map JSON.
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  @override
  String toString() {
    return 'Country(id: $id, name: $name, code: $code)';
  }
}

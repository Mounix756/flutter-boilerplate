/// Modèle représentant un utilisateur.
///
/// Contient toutes les informations d'un utilisateur de l'application.
class User {
  final String id;
  final String firstname;
  final String lastname;
  final String? email; // Email peut être null
  final String phone;
  final String status;
  final String? address;
  final String? city;
  final String? countryId;
  final double? latitude;
  final double? longitude;
  final String? image;

  const User({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email, // Email optionnel
    required this.phone,
    required this.status,
    this.address,
    this.city,
    this.countryId,
    this.latitude,
    this.longitude,
    this.image,
  });

  /// Crée une instance depuis un Map JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String?, // Email peut être null
      phone: json['phone'] as String,
      status: json['status'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryId: json['country_id'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      image: json['image'] as String?,
    );
  }

  /// Convertit l'objet en Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'status': status,
      'address': address,
      'city': city,
      'country_id': countryId,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
    };
  }

  /// Retourne le nom complet de l'utilisateur.
  String get fullName => '$firstname $lastname';

  /// Indique si l'utilisateur est actif.
  bool get isActive => status == 'active';

  /// Indique si l'utilisateur s'est inscrit avec Google.
  /// Les utilisateurs Google ont un numéro de téléphone généré automatiquement
  /// au format +GOOGLE-timestamp-hash
  bool get isGoogleUser => phone.startsWith('+GOOGLE-');

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'email: $email, '
        'phone: $phone, '
        'status: $status'
        ')';
  }
}

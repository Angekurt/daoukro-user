class HebergementModel {
  final int id;
  final String nom;
  final String type; // hotel, residence, meuble
  final String? description;
  final String? adresse;
  final String? telephone;
  final double? latitude;
  final double? longitude;
  final double? prixMin;
  final double? prixMax;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final double? note;
  final int? nbAvis;
  final bool isActive;

  HebergementModel({
    required this.id,
    required this.nom,
    required this.type,
    this.description,
    this.adresse,
    this.telephone,
    this.latitude,
    this.longitude,
    this.prixMin,
    this.prixMax,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    this.note,
    this.nbAvis,
    required this.isActive,
  });

  factory HebergementModel.fromJson(Map<String, dynamic> json) {
    return HebergementModel(
      id: json['id'],
      nom: json['nom'],
      type: json['type'] ?? 'hotel',
      description: json['description'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      prixMin: json['prix_min'] != null ? double.parse(json['prix_min'].toString()) : null,
      prixMax: json['prix_max'] != null ? double.parse(json['prix_max'].toString()) : null,
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      note: json['note'] != null ? double.parse(json['note'].toString()) : null,
      nbAvis: json['nb_avis'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

class PharmacieModel {
  final int id;
  final int villeId;
  final String nom;
  final String adresse;
  final String? telephone;
  final double? latitude;
  final double? longitude;
  final String? horaires;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final bool isActive;
  final VilleModel? ville;

  PharmacieModel({
    required this.id,
    required this.villeId,
    required this.nom,
    required this.adresse,
    this.telephone,
    this.latitude,
    this.longitude,
    this.horaires,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    required this.isActive,
    this.ville,
  });

  // JSON → PharmacieModel
  factory PharmacieModel.fromJson(Map<String, dynamic> json) {
    return PharmacieModel(
      id: json['id'],
      villeId: json['ville_id'],
      nom: json['nom'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      horaires: json['horaires'],
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      ville: json['ville'] != null
          ? VilleModel.fromJson(json['ville'])
          : null,
    );
  }
}

class VilleModel {
  final int id;
  final String nom;
  final String? region;

  VilleModel({
    required this.id,
    required this.nom,
    this.region,
  });

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    return VilleModel(
      id: json['id'],
      nom: json['nom'],
      region: json['region'],
    );
  }
}
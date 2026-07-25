class ServicePublicModel {
  final int id;
  final int villeId;
  final int categorieId;
  final String nom;
  final String? description;
  final String? adresse;
  final String? telephone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String? horaires;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final bool isActive;
  final CategorieServiceModel? categorie;

  ServicePublicModel({
    required this.id,
    required this.villeId,
    required this.categorieId,
    required this.nom,
    this.description,
    this.adresse,
    this.telephone,
    this.email,
    this.latitude,
    this.longitude,
    this.horaires,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    required this.isActive,
    this.categorie,
  });

  factory ServicePublicModel.fromJson(Map<String, dynamic> json) {
    return ServicePublicModel(
      id: json['id'],
      villeId: json['ville_id'],
      categorieId: json['categorie_id'],
      nom: json['nom'],
      description: json['description'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      email: json['email'],
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
      categorie: json['categorie'] != null
          ? CategorieServiceModel.fromJson(json['categorie'])
          : null,
    );
  }
}

class CategorieServiceModel {
  final int id;
  final String nom;
  final String? icone;
  final String? couleur;

  CategorieServiceModel({
    required this.id,
    required this.nom,
    this.icone,
    this.couleur,
  });

  factory CategorieServiceModel.fromJson(Map<String, dynamic> json) {
    return CategorieServiceModel(
      id: json['id'],
      nom: json['nom'],
      icone: json['icone'],
      couleur: json['couleur'],
    );
  }
}
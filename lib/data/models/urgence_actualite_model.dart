class UrgenceModel {
  final int id;
  final String nom;
  final String categorie; // sante, securite, incendie, autre
  final String telephone;
  final String? telephone2;
  final String? adresse;
  final String? description;
  final bool isActive;

  UrgenceModel({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.telephone,
    this.telephone2,
    this.adresse,
    this.description,
    required this.isActive,
  });

  factory UrgenceModel.fromJson(Map<String, dynamic> json) {
    return UrgenceModel(
      id: json['id'],
      nom: json['nom'],
      categorie: json['categorie'] ?? 'autre',
      telephone: json['telephone'],
      telephone2: json['telephone2'],
      adresse: json['adresse'],
      description: json['description'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

class ActualiteModel {
  final int id;
  final String titre;
  final String contenu;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final String? categorie; // mairie, alerte, info, culture
  final String createdAt;
  final bool isActive;

  ActualiteModel({
    required this.id,
    required this.titre,
    required this.contenu,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    this.categorie,
    required this.createdAt,
    required this.isActive,
  });

  factory ActualiteModel.fromJson(Map<String, dynamic> json) {
    return ActualiteModel(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      categorie: json['categorie'],
      createdAt: json['created_at'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

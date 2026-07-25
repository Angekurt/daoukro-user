class ImmobilierModel {
  final int id;
  final String titre;
  final String typeOffre; // vente, location
  final String typeBien; // maison, terrain, appartement, villa
  final String? description;
  final String? adresse;
  final String? quartier;
  final double prix;
  final String? surface;
  final int? nbChambres;
  final String? telephone;
  final double? latitude;
  final double? longitude;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final bool isActive;

  ImmobilierModel({
    required this.id,
    required this.titre,
    required this.typeOffre,
    required this.typeBien,
    this.description,
    this.adresse,
    this.quartier,
    required this.prix,
    this.surface,
    this.nbChambres,
    this.telephone,
    this.latitude,
    this.longitude,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    required this.isActive,
  });

  factory ImmobilierModel.fromJson(Map<String, dynamic> json) {
    return ImmobilierModel(
      id: json['id'],
      titre: json['titre'],
      typeOffre: json['type_offre'] ?? 'vente',
      typeBien: json['type_bien'] ?? 'maison',
      description: json['description'],
      adresse: json['adresse'],
      quartier: json['quartier'],
      prix: double.parse(json['prix'].toString()),
      surface: json['surface'],
      nbChambres: json['nb_chambres'],
      telephone: json['telephone'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

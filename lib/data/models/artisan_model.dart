import '../../core/utils/parsing.dart';

class ArtisanModel {
  final int id;
  final String nom;
  final String metier;
  final String? description;
  final String? telephone;
  final String? whatsapp;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final double? note;
  final int? nbAvis;
  final bool disponible;
  final bool isActive;

  ArtisanModel({
    required this.id,
    required this.nom,
    required this.metier,
    this.description,
    this.telephone,
    this.whatsapp,
    this.adresse,
    this.latitude,
    this.longitude,
    this.photo,
    this.photoUrl,
    this.photos = const [],
    this.note,
    this.nbAvis,
    required this.disponible,
    required this.isActive,
  });

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    return ArtisanModel(
      id: json['id'],
      nom: json['nom'],
      metier: json['metier'],
      description: json['description'],
      telephone: json['telephone'],
      whatsapp: json['whatsapp'],
      adresse: json['adresse'],
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      note: json['note'] != null ? double.parse(json['note'].toString()) : null,
      nbAvis: json['nb_avis'],
      disponible: json['disponible'] == 1 || json['disponible'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

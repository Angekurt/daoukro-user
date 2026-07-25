enum CategorieSignalement { voirie, eclairage, dechets, eau, securite, autre }
enum StatutSignalement { enAttente, enCours, resolu }

class SignalementModel {
  final String id;
  final CategorieSignalement categorie;
  final String description;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final StatutSignalement statut;
  final DateTime createdAt;
  final String? auteur;
  final String? telephone;

  const SignalementModel({
    required this.id,
    required this.categorie,
    required this.description,
    this.adresse,
    this.latitude,
    this.longitude,
    this.statut = StatutSignalement.enAttente,
    required this.createdAt,
    this.auteur,
    this.telephone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categorie': categorie.name,
    'description': description,
    'adresse': adresse,
    'latitude': latitude,
    'longitude': longitude,
    'statut': statut.name,
    'created_at': createdAt.toIso8601String(),
    'auteur': auteur,
    'telephone': telephone,
  };

  factory SignalementModel.fromJson(Map<String, dynamic> json) => SignalementModel(
    id: json['id'],
    categorie: CategorieSignalement.values.firstWhere(
      (e) => e.name == json['categorie'], orElse: () => CategorieSignalement.autre),
    description: json['description'],
    adresse: json['adresse'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    statut: StatutSignalement.values.firstWhere(
      (e) => e.name == json['statut'], orElse: () => StatutSignalement.enAttente),
    createdAt: DateTime.parse(json['created_at']),
    auteur: json['auteur'],
    telephone: json['telephone'],
  );
}

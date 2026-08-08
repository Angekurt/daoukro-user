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
  // Chemin local de la photo prise/choisie sur l'appareil — permet de
  // l'afficher immédiatement dans "Mes signalements" avant même l'envoi.
  final String? photoPath;
  // URL de la photo une fois envoyée et hébergée par l'API — remplace
  // photoPath dans l'affichage dès qu'elle est connue.
  final String? photoUrl;

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
    this.photoPath,
    this.photoUrl,
  });

  SignalementModel copyWith({String? photoUrl}) => SignalementModel(
    id: id,
    categorie: categorie,
    description: description,
    adresse: adresse,
    latitude: latitude,
    longitude: longitude,
    statut: statut,
    createdAt: createdAt,
    auteur: auteur,
    telephone: telephone,
    photoPath: photoPath,
    photoUrl: photoUrl ?? this.photoUrl,
  );

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
    'photo_path': photoPath,
    'photo_url': photoUrl,
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
    photoPath: json['photo_path'],
    photoUrl: json['photo_url'],
  );
}

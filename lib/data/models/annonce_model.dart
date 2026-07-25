enum TypeAnnonce { evenement, emploi, restaurant, pub, annonce }

class AnnonceModel {
  final int id;
  final String titre;
  final String description;
  final TypeAnnonce type;
  final String categorie; // pour les listes
  final String? photo;
  final String? photoUrl;
  final List<String> photos;
  final String? lieu;
  final String? dateDebut;
  final String? dateFin;
  final String? contact;
  final String? auteur;
  final String? telephone;
  final String? email;
  final String? createdAt;
  final String? lien;
  final bool isActive;

  AnnonceModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    this.categorie = 'annonce',
    this.photo,
    this.photoUrl,
    this.photos = const [],
    this.lieu,
    this.dateDebut,
    this.dateFin,
    this.contact,
    this.auteur,
    this.telephone,
    this.email,
    this.createdAt,
    this.lien,
    required this.isActive,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) {
    return AnnonceModel(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      type: TypeAnnonce.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TypeAnnonce.annonce,
      ),
      categorie: json['categorie'] ?? json['type'] ?? 'annonce',
      photo: json['photo'],
      photoUrl: json['photo_url'],
      photos: json['photos_urls'] != null ? List<String>.from(json['photos_urls']) : const [],
      lieu: json['lieu'],
      dateDebut: json['date_debut'],
      dateFin: json['date_fin'],
      contact: json['contact'],
      auteur: json['auteur'],
      telephone: json['telephone'],
      email: json['email'],
      createdAt: json['created_at'],
      lien: json['lien'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

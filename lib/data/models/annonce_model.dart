enum TypeAnnonce { evenement, emploi, restaurant, pub, annonce }

class AnnonceModel {
  final int id;
  final String titre;
  final String description;
  final TypeAnnonce type;
  final String categorie;
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
  final int nbInterets;       // nombre de personnes intéressées (emploi)
  final bool dejaInteresse;   // si le citoyen connecté est déjà intéressé

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
    this.nbInterets = 0,
    this.dejaInteresse = false,
  });

  AnnonceModel copyWith({ int? nbInterets, bool? dejaInteresse }) {
    return AnnonceModel(
      id: id, titre: titre, description: description, type: type,
      categorie: categorie, photo: photo, photoUrl: photoUrl, photos: photos,
      lieu: lieu, dateDebut: dateDebut, dateFin: dateFin,
      contact: contact, auteur: auteur, telephone: telephone,
      email: email, createdAt: createdAt, lien: lien, isActive: isActive,
      nbInterets: nbInterets ?? this.nbInterets,
      dejaInteresse: dejaInteresse ?? this.dejaInteresse,
    );
  }

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
      nbInterets: json['nb_interets'] ?? 0,
      dejaInteresse: json['deja_interesse'] ?? false,
    );
  }
}

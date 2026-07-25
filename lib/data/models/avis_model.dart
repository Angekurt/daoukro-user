class AvisModel {
  final int id;
  final String nom;
  final int note;
  final String? commentaire;
  final DateTime createdAt;

  AvisModel({
    required this.id,
    required this.nom,
    required this.note,
    this.commentaire,
    required this.createdAt,
  });

  factory AvisModel.fromJson(Map<String, dynamic> json) {
    return AvisModel(
      id: json['id'],
      nom: json['nom'],
      note: json['note'] is int ? json['note'] : int.parse(json['note'].toString()),
      commentaire: json['commentaire'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

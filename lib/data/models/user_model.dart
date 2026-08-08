class UserModel {
  final String id;
  final String nom;
  final String? email;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.nom,
    this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'].toString(),
    nom: json['nom'] ?? json['name'] ?? '',
    email: json['email'],
    avatarUrl: json['avatar_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    'avatar_url': avatarUrl,
  };
}

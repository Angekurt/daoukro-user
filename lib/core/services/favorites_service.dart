import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Modèle d'un favori
class FavoriteItem {
  final int id;
  final String type; // pharmacie, artisan, hebergement, immobilier, service, annonce
  final String nom;
  final String? detail; // adresse, métier, etc.
  final String? telephone;
  final int savedAt;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.nom,
    this.detail,
    this.telephone,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'nom': nom,
    'detail': detail,
    'telephone': telephone,
    'savedAt': savedAt,
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> j) => FavoriteItem(
    id: j['id'],
    type: j['type'],
    nom: j['nom'],
    detail: j['detail'],
    telephone: j['telephone'],
    savedAt: j['savedAt'],
  );
}

class FavoritesService {
  static const _key = 'daoukro_favorites';

  static Future<List<FavoriteItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => FavoriteItem.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static Future<bool> isFavorite(String type, int id) async {
    final all = await getAll();
    return all.any((f) => f.type == type && f.id == id);
  }

  static Future<void> toggle(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final exists = all.any((f) => f.type == item.type && f.id == item.id);
    
    if (exists) {
      all.removeWhere((f) => f.type == item.type && f.id == item.id);
    } else {
      all.insert(0, item);
    }
    
    await prefs.setStringList(_key, all.map((f) => jsonEncode(f.toJson())).toList());
  }

  static Future<void> remove(String type, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((f) => f.type == type && f.id == id);
    await prefs.setStringList(_key, all.map((f) => jsonEncode(f.toJson())).toList());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

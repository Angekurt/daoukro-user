import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Modèle d'un avis
class ReviewItem {
  final int entityId;
  final String entityType; // artisan, hebergement, pharmacie, etc.
  final double note;        // 1.0 à 5.0
  final String? commentaire;
  final int timestamp;

  ReviewItem({
    required this.entityId,
    required this.entityType,
    required this.note,
    this.commentaire,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'entityId': entityId,
    'entityType': entityType,
    'note': note,
    'commentaire': commentaire,
    'timestamp': timestamp,
  };

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
    entityId: j['entityId'],
    entityType: j['entityType'],
    note: (j['note'] as num).toDouble(),
    commentaire: j['commentaire'],
    timestamp: j['timestamp'],
  );
}

class RatingsService {
  static const _key = 'daoukro_reviews';

  static Future<List<ReviewItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => ReviewItem.fromJson(jsonDecode(s))).toList();
  }

  static Future<ReviewItem?> getForEntity(String type, int id) async {
    final all = await getAll();
    try {
      return all.firstWhere((r) => r.entityType == type && r.entityId == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveReview(ReviewItem review) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    // Remplacer si existe déjà
    all.removeWhere((r) => r.entityType == review.entityType && r.entityId == review.entityId);
    all.insert(0, review);
    await prefs.setStringList(_key, all.map((r) => jsonEncode(r.toJson())).toList());
  }

  static Future<void> deleteReview(String type, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((r) => r.entityType == type && r.entityId == id);
    await prefs.setStringList(_key, all.map((r) => jsonEncode(r.toJson())).toList());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

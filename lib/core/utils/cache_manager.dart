import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static const String _boxName = 'daoukro_cache';

  /// Initialise Hive et ouvre la boîte de cache principale
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  /// Récupère l'instance de la boîte principale
  static Box get _box => Hive.box(_boxName);

  /// Sauvegarde des données (généralement des listes de Maps ou des Maps issues des requêtes API)
  static Future<void> save(String key, dynamic data) async {
    try {
      await _box.put(key, data);
    } catch (_) {
      // Échec silencieux en cas d'erreur d'écriture (ex. boîte fermée ou stockage saturé)
    }
  }

  /// Récupération des données en cache pour une clé donnée
  static dynamic get(String key) {
    try {
      return _box.get(key);
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si une clé existe et contient des données valides
  static bool has(String key) {
    return _box.containsKey(key) && _box.get(key) != null;
  }

  /// Supprime les données associées à une clé
  static Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (_) {}
  }

  /// Vide l'intégralité du cache local
  static Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (_) {}
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Modèle d'un appel dans l'historique
class CallEntry {
  final String nom;
  final String telephone;
  final String type; // pharmacie, artisan, urgence, etc.
  final int timestamp;

  CallEntry({
    required this.nom,
    required this.telephone,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'telephone': telephone,
    'type': type,
    'timestamp': timestamp,
  };

  factory CallEntry.fromJson(Map<String, dynamic> j) => CallEntry(
    nom: j['nom'],
    telephone: j['telephone'],
    type: j['type'],
    timestamp: j['timestamp'],
  );

  String get dateFormatted {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }
}

class CallHistoryService {
  static const _key = 'daoukro_call_history';
  static const _maxEntries = 50;

  static Future<List<CallEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => CallEntry.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> add(CallEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, entry); // plus récent en tête
    
    // Limite à 50 entrées
    final limited = all.take(_maxEntries).toList();
    await prefs.setStringList(_key, limited.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> remove(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    if (index >= 0 && index < all.length) {
      all.removeAt(index);
      await prefs.setStringList(_key, all.map((e) => jsonEncode(e.toJson())).toList());
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../utils/cache_manager.dart';

/// Contenus pilotables depuis l'admin (Filament), chargés au démarrage
/// via GET /api/v1/settings. Ne jamais coder ces valeurs en dur ailleurs
/// dans l'application — passer par ce service.
class SettingsService {
  SettingsService._();
  static final instance = SettingsService._();

  static const _cacheKey = 'settings_cache';

  Map<String, dynamic> _values = {};

  /// À appeler une fois au démarrage (main.dart), avant runApp si possible.
  /// Échec réseau silencieux : on retombe sur le cache local puis sur les
  /// valeurs par défaut codées dans chaque getter.
  Future<void> init() async {
    try {
      final response = await ApiClient.getInstance().get('/settings');
      final data = Map<String, dynamic>.from(response.data['data'] ?? {});
      if (data.isNotEmpty) {
        _values = data;
        await CacheManager.save(_cacheKey, data);
        return;
      }
    } on DioException catch (_) {
      // Pas de réseau au démarrage — on utilise le cache ci-dessous.
    } catch (_) {}

    final cached = CacheManager.get(_cacheKey);
    if (cached != null) {
      _values = Map<String, dynamic>.from(cached);
    }
  }

  String? _get(String cle) {
    final v = _values[cle];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  String? get supportWhatsapp => _get('support_whatsapp');
  String? get supportEmail => _get('support_email');
  String? get aProposTexte => _get('a_propos_texte');
  String? get messageAccueil => _get('message_accueil');
  String? get urgencesNumeros => _get('urgences_numeros');
  String? get appVersionMin => _get('app_version_min');
}

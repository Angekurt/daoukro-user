import 'package:dio/dio.dart';
import '../models/pharmacie_model.dart';
import '../models/garde_model.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/cache_manager.dart';

class PharmacieRepository {
  final Dio _dio = ApiClient.getInstance();

  // Récupère toutes les pharmacies
  Future<List<PharmacieModel>> getPharmacies() async {
    const String cacheKey = 'pharmacies_list';
    try {
      final response = await _dio.get('/pharmacies');
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => PharmacieModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => PharmacieModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw _handleError(e);
    }
  }

  // Récupère une pharmacie par son id
  Future<PharmacieModel> getPharmacie(int id) async {
    final String cacheKey = 'pharmacie_detail_$id';
    try {
      final response = await _dio.get('/pharmacies/$id');
      await CacheManager.save(cacheKey, response.data);
      return PharmacieModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        return PharmacieModel.fromJson(cached['data']);
      }
      
      // Fallback 2: chercher dans le cache de la liste globale
      final listCached = CacheManager.get('pharmacies_list');
      if (listCached != null && listCached['data'] != null) {
        final List data = listCached['data'];
        final jsonMatch = data.firstWhere((p) => p['id'] == id, orElse: () => null);
        if (jsonMatch != null) {
          return PharmacieModel.fromJson(jsonMatch);
        }
      }
      throw _handleError(e);
    }
  }

  // Récupère les pharmacies de garde actives (avec leur période de garde)
  Future<List<GardeModel>> getGardesActives() async {
    const String cacheKey = 'pharmacies_garde_actives';
    try {
      final response = await _dio.get('/pharmacies/garde/actives');
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => GardeModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => GardeModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw _handleError(e);
    }
  }

  // Gestion des erreurs
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connexion trop lente. Vérifiez votre internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Impossible de contacter le serveur.';
    } else if (e.response?.statusCode == 404) {
      return 'Ressource introuvable.';
    } else {
      return 'Une erreur est survenue.';
    }
  }
}
import 'package:dio/dio.dart';
import '../models/service_public_model.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/cache_manager.dart';

class ServicePublicRepository {
  final Dio _dio = ApiClient.getInstance();

  // Récupère tous les services publics
  Future<List<ServicePublicModel>> getServicesPublics() async {
    const String cacheKey = 'services_publics_list';
    try {
      final response = await _dio.get('/services-publics');
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => ServicePublicModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => ServicePublicModel.fromJson(json)).toList();
      }
      throw _handleError(e);
    }
  }

  // Récupère un service par son id
  Future<ServicePublicModel> getServicePublic(int id) async {
    final String cacheKey = 'service_public_detail_$id';
    try {
      final response = await _dio.get('/services-publics/$id');
      await CacheManager.save(cacheKey, response.data);
      return ServicePublicModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        return ServicePublicModel.fromJson(cached['data']);
      }
      
      // Fallback 2: chercher dans la liste globale
      final listCached = CacheManager.get('services_publics_list');
      if (listCached != null && listCached['data'] != null) {
        final List data = listCached['data'];
        final jsonMatch = data.firstWhere((s) => s['id'] == id, orElse: () => null);
        if (jsonMatch != null) {
          return ServicePublicModel.fromJson(jsonMatch);
        }
      }
      throw _handleError(e);
    }
  }

  // Récupère les services par catégorie
  Future<List<ServicePublicModel>> getServicesParCategorie(int categorieId) async {
    final String cacheKey = 'services_publics_cat_$categorieId';
    try {
      final response = await _dio.get('/services-publics/categorie/$categorieId');
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => ServicePublicModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => ServicePublicModel.fromJson(json)).toList();
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
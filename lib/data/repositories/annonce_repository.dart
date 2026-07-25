import 'package:dio/dio.dart';
import '../models/annonce_model.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/cache_manager.dart';

class AnnonceRepository {
  final Dio _dio = ApiClient.getInstance();

  Future<List<AnnonceModel>> getAnnonces() async {
    const String cacheKey = 'annonces_list';
    try {
      final response = await _dio.get('/annonces');
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => AnnonceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => AnnonceModel.fromJson(json)).toList();
      }
      throw _handleError(e);
    }
  }

  Future<List<AnnonceModel>> getAnnoncesByType(TypeAnnonce type) async {
    final String cacheKey = 'annonces_list_type_${type.name}';
    try {
      final response = await _dio.get('/annonces', queryParameters: {'type': type.name});
      final List data = response.data['data'];
      await CacheManager.save(cacheKey, response.data);
      return data.map((json) => AnnonceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final cached = CacheManager.get(cacheKey);
      if (cached != null && cached['data'] != null) {
        final List data = cached['data'];
        return data.map((json) => AnnonceModel.fromJson(json)).toList();
      }
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Impossible de contacter le serveur.';
    }
    return 'Une erreur est survenue.';
  }
}

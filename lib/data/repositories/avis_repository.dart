import 'package:dio/dio.dart';
import '../models/avis_model.dart';
import '../../core/network/api_client.dart';

class AvisRepository {
  final Dio _dio = ApiClient.getInstance();

  Future<List<AvisModel>> getAvis(String type, int id) async {
    try {
      final response = await _dio.get('/$type/$id/avis');
      final List data = response.data['data'];
      return data.map((json) => AvisModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } on DioException {
      return [];
    }
  }

  /// Renvoie le message de succès du serveur si l'envoi a réussi, sinon lève une exception.
  Future<String> envoyerAvis(
    String type,
    int id, {
    required String nom,
    required int note,
    String? commentaire,
  }) async {
    try {
      final response = await _dio.post('/$type/$id/avis', data: {
        'nom': nom,
        'note': note,
        if (commentaire != null && commentaire.trim().isNotEmpty) 'commentaire': commentaire.trim(),
      });
      return response.data['message'] ?? 'Avis envoyé.';
    } on DioException catch (e) {
      final message = e.response?.data is Map ? e.response?.data['message'] : null;
      throw message ?? "Impossible d'envoyer votre avis pour le moment.";
    }
  }
}

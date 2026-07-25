import 'package:dio/dio.dart';
import '../models/signalement_model.dart';
import '../../core/network/api_client.dart';

class SignalementRepository {
  final Dio _dio = ApiClient.getInstance();

  /// Transmet le signalement à la mairie. Best-effort : l'app garde de
  /// toute façon sa propre copie locale même si l'envoi échoue (hors ligne).
  Future<void> envoyer(SignalementModel s) async {
    await _dio.post('/signalements', data: {
      'categorie': s.categorie.name,
      'description': s.description,
      'adresse': s.adresse,
      'latitude': s.latitude,
      'longitude': s.longitude,
      'auteur': s.auteur,
      'telephone': s.telephone,
    });
  }
}

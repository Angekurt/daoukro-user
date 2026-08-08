import 'package:dio/dio.dart';
import '../models/signalement_model.dart';
import '../../core/network/api_client.dart';

class SignalementRepository {
  final Dio _dio = ApiClient.getInstance();

  /// Transmet le signalement à la mairie. Best-effort : l'app garde de
  /// toute façon sa propre copie locale même si l'envoi échoue (hors ligne).
  ///
  /// Retourne l'URL de la photo hébergée par l'API si une photo était jointe
  /// et que le serveur l'a acceptée, sinon null. Nécessite côté API que
  /// `POST /signalements` accepte un champ multipart `photo` et renvoie
  /// `data.photo_url` dans la réponse.
  Future<String?> envoyer(SignalementModel s) async {
    final champs = {
      'categorie': s.categorie.name,
      'description': s.description,
      'adresse': s.adresse,
      'latitude': s.latitude,
      'longitude': s.longitude,
      'auteur': s.auteur,
      'telephone': s.telephone,
    };

    if (s.photoPath != null) {
      final data = FormData.fromMap({
        ...champs,
        'photo': await MultipartFile.fromFile(s.photoPath!, filename: 'signalement_${s.id}.jpg'),
      });
      final response = await _dio.post(
        '/signalements',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data?['data']?['photo_url'] as String?;
    }

    await _dio.post('/signalements', data: champs);
    return null;
  }
}

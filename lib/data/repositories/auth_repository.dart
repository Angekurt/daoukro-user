import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/network/api_client.dart';

class AuthRepository {
  final Dio _dio = ApiClient.getInstance();

  /// Échange un idToken Google contre une session API : le serveur vérifie
  /// le jeton, crée ou retrouve l'utilisateur, et renvoie un token Sanctum
  /// à utiliser pour les requêtes suivantes.
  ///
  /// Endpoint `POST /auth/google` (daoukro-api), même convention que
  /// /auth/login et /auth/register : `{ success, message, token, user }`.
  Future<({String token, UserModel user})> connecterAvecGoogle(String idToken) async {
    try {
      final response = await _dio.post('/auth/google', data: {'id_token': idToken});
      return (
        token: response.data['token'] as String,
        user: UserModel.fromJson(response.data['user']),
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map ? e.response?.data['message'] : null;
      throw message ?? 'Connexion impossible pour le moment. Réessayez.';
    }
  }
}

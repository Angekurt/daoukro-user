import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static Dio? _instance;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Attache (ou retire, si null) le token Sanctum de l'utilisateur connecté
  /// à toutes les requêtes API suivantes.
  static void setAuthToken(String? token) {
    final dio = getInstance();
    if (token == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour afficher les requêtes en mode debug
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}
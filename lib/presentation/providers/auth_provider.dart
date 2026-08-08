import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

const _kTokenKey = 'auth_token';
const _kUserKey = 'auth_user';
const _storage = FlutterSecureStorage();

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

/// État de connexion citoyen — `null` = navigation anonyme (le cas par
/// défaut et volontaire de l'app : consulter les infos ne demande jamais de
/// compte). Seules certaines actions (ex. déposer un avis) exigent d'être
/// connecté, via ce provider.
class AuthNotifier extends AsyncNotifier<UserModel?> {
  final _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    // Web client ID (pas le client Android) — nécessaire pour que l'idToken
    // renvoyé soit vérifiable côté API. Voir AppConstants.googleServerClientId.
    serverClientId: AppConstants.googleServerClientId,
  );

  @override
  Future<UserModel?> build() async {
    final token = await _storage.read(key: _kTokenKey);
    final rawUser = await _storage.read(key: _kUserKey);
    if (token == null || rawUser == null) return null;
    ApiClient.setAuthToken(token);
    return UserModel.fromJson(jsonDecode(rawUser));
  }

  /// Lance le flux de connexion Google. Ne change pas l'état si l'utilisateur
  /// annule la fenêtre de compte (pas d'erreur affichée dans ce cas).
  Future<void> connecterAvecGoogle() async {
    final compte = await _googleSignIn.signIn();
    if (compte == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = await compte.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw 'Connexion Google incomplète, réessayez.';
      }
      final resultat = await ref.read(authRepositoryProvider).connecterAvecGoogle(idToken);
      await _storage.write(key: _kTokenKey, value: resultat.token);
      await _storage.write(key: _kUserKey, value: jsonEncode(resultat.user.toJson()));
      ApiClient.setAuthToken(resultat.token);
      return resultat.user;
    });
  }

  Future<void> deconnecter() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserKey);
    ApiClient.setAuthToken(null);
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

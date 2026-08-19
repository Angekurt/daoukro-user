class AppConstants {
  // URL de base de l'API Laravel — production.
  static const String baseUrl = 'https://api-daoukro.akdev.ci/api/v1';

  // Nom de l'application
  static const String appName = 'Daoukro Digital';

  // Duree du cache offline (en heures)
  static const int cacheDuration = 24;

  // Client OAuth "Web" (PAS le client Android) — depuis google-services.json
  // (oauth_client, client_type: 3). Doit être identique à GOOGLE_CLIENT_ID
  // dans le .env de daoukro-api pour que l'idToken soit vérifiable côté API.
  static const String googleServerClientId =
      '1078580649233-57u3qgnqu8bshuibemhsunraoqvkib09.apps.googleusercontent.com';
}

class AppConstants {
  // URL de base de l'API Laravel
  // IP du PC sur le reseau WiFi local - le telephone doit etre sur le meme reseau
  // Laragon local : http://localhost/daoukro-api/public/api/v1
  // Téléphone sur WiFi : remplacer localhost par l'IP du PC (ex: 192.168.1.x)
  // TODO: remettre 'https://api-daoukro.akdev.tech/api/v1' avant un build de production.
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Nom de l'application
  static const String appName = 'Daoukro Digital';

  // Duree du cache offline (en heures)
  static const int cacheDuration = 24;
}

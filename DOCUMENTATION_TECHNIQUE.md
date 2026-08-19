# 📱 RAPPORT TECHNIQUE — DAOUKRO DIGITAL
## Application mobile Flutter + API Laravel

---

## TABLE DES MATIÈRES

1. [Vue d'ensemble du projet](#1-vue-densemble)
2. [Architecture Flutter (app mobile)](#2-architecture-flutter)
3. [Architecture Laravel (API)](#3-architecture-laravel)
4. [Les notifications push (FCM)](#4-notifications-push)
5. [Où toucher quoi — guide pratique](#5-où-toucher-quoi)
6. [Commandes utiles Flutter](#6-commandes-flutter)
7. [Commandes utiles Laravel](#7-commandes-laravel)
8. [Déploiement APK Android](#8-déploiement-apk)
9. [Déploiement API en production](#9-déploiement-api)
10. [Checklist avant chaque release](#10-checklist-release)

---

## 1. VUE D'ENSEMBLE

```
daoukro_user/          ← Application Flutter (Android)
daoukro-api/           ← API REST Laravel (backend)
```

**Flux de données :**
```
Téléphone Android
      ↓ requête HTTP (Dio)
API Laravel (Laragon local / serveur en prod)
      ↓ réponse JSON
Flutter affiche les données
      ↓ stockage local
Hive (cache offline)
```

**Technologies utilisées :**
| Côté | Technologie | Rôle |
|------|-------------|------|
| Mobile | Flutter 3 / Dart | Interface utilisateur |
| Mobile | Riverpod | Gestion d'état |
| Mobile | Dio | Requêtes HTTP |
| Mobile | Hive | Cache local offline |
| Mobile | GoRouter | Navigation entre pages |
| Mobile | Firebase FCM | Notifications push |
| Mobile | flutter_local_notifications | Affichage notifs en foreground |
| API | Laravel 11 | Backend REST |
| API | SQLite (dev) / MySQL (prod) | Base de données |
| API | Filament | Panel d'administration |
| API | Sanctum | Authentification API |

---

## 2. ARCHITECTURE FLUTTER

### Structure des dossiers

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       ← Toutes les couleurs de l'app
│   │   └── app_constants.dart    ← URL API, nom app, durée cache
│   ├── network/
│   │   └── api_client.dart       ← Configuration Dio (HTTP client)
│   ├── services/
│   │   └── notification_service.dart  ← FCM + notifications locales
│   └── utils/
│       ├── cache_manager.dart    ← Gestion cache Hive
│       └── launcher.dart         ← Ouvrir URLs, téléphone, WhatsApp
│
├── data/
│   ├── models/                   ← Classes de données (ce que l'API renvoie)
│   │   ├── pharmacie_model.dart
│   │   ├── artisan_model.dart
│   │   ├── hebergement_model.dart
│   │   └── ...
│   └── repositories/             ← Couche d'accès aux données
│       ├── pharmacie_repository.dart
│       └── ...
│
├── presentation/
│   ├── providers/                ← Riverpod providers (état global)
│   │   ├── pharmacie_provider.dart
│   │   ├── modules_provider.dart ← hébergements, artisans, urgences...
│   │   └── ...
│   ├── screens/                  ← Toutes les pages de l'app
│   │   ├── home/
│   │   ├── pharmacies/
│   │   ├── artisans/
│   │   ├── notifications/        ← Écran notifications (nouveau)
│   │   └── ...
│   └── widgets/                  ← Composants réutilisables
│       ├── action_button.dart    ← Bouton animé + BoutonRetour
│       ├── meteo_widget.dart
│       └── share_button.dart
│
├── router/
│   └── app_router.dart           ← Toutes les routes de navigation
│
└── main.dart                     ← Point d'entrée de l'app
```

### Comment fonctionne Riverpod (gestion d'état)

Riverpod est le système qui permet à plusieurs pages de partager les mêmes données sans les recharger à chaque fois.

```dart
// 1. Déclarer un provider (dans providers/)
final pharmaciesProvider = FutureProvider<List<PharmacieModel>>((ref) async {
  return repository.getPharmacies(); // appel API
});

// 2. L'utiliser dans une page
class MaPage extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pharmaciesProvider); // écoute les données
    return async.when(
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Erreur: $e'),
      data: (liste) => ListView(...),
    );
  }
}

// 3. Forcer un rechargement (ex: pull-to-refresh)
ref.invalidate(pharmaciesProvider);
```

### Comment fonctionne GoRouter (navigation)

```dart
// Naviguer vers une page
context.push('/pharmacies');      // empile la page (bouton retour disponible)
context.go('/pharmacies');        // remplace (pas de retour)
context.pop();                    // retour arrière

// Naviguer avec des paramètres
context.push('/pharmacies/5');    // id = 5

// Naviguer avec des données complexes
context.push('/itineraire', extra: {'lat': 7.8, 'lng': -3.5, 'nom': 'Hôpital'});
```

### Comment fonctionne le cache Hive

```dart
// Sauvegarder
await CacheManager.save('pharmacies_list', responseData);

// Récupérer
final cached = CacheManager.get('pharmacies_list');

// Vérifier si existe
if (CacheManager.has('pharmacies_list')) { ... }

// Supprimer
await CacheManager.delete('pharmacies_list');
```

**Clés de cache utilisées :**
| Clé | Contenu |
|-----|---------|
| `pharmacies_list` | Liste des pharmacies |
| `pharmacie_detail_X` | Détail pharmacie id=X |
| `pharmacies_garde_actives` | Pharmacies de garde |
| `hebergements_list` | Liste hébergements |
| `immobilier_list` | Liste immobilier |
| `artisans_list` | Liste artisans |
| `urgences_list` | Numéros d'urgence |
| `actualites_list` | Actualités |
| `notifications_box` | Notifications push reçues |

---

## 3. ARCHITECTURE LARAVEL

### Structure des dossiers importants

```
daoukro-api/
├── app/
│   ├── Http/Controllers/Api/V1/   ← Contrôleurs API
│   │   ├── PharmacieController.php
│   │   ├── ArtisanController.php
│   │   ├── NotificationController.php  ← FCM (nouveau)
│   │   └── ...
│   ├── Models/                    ← Modèles Eloquent (tables BDD)
│   │   ├── Pharmacie.php
│   │   ├── Garde.php
│   │   ├── FcmToken.php           ← Tokens FCM (nouveau)
│   │   └── ...
│   └── Filament/Resources/        ← Panel admin
│
├── database/
│   ├── migrations/                ← Création des tables
│   └── seeders/                   ← Données de test
│
├── routes/
│   └── api.php                    ← Toutes les routes API
│
├── config/
│   └── services.php               ← Clés services externes (FCM...)
│
└── .env                           ← Variables d'environnement (secrets)
```

### Routes API disponibles

```
GET  /api/v1/pharmacies                  → Liste pharmacies
GET  /api/v1/pharmacies/garde/actives    → Pharmacies de garde
GET  /api/v1/pharmacies/{id}             → Détail pharmacie

GET  /api/v1/services-publics            → Liste services publics
GET  /api/v1/services-publics/{id}       → Détail service

GET  /api/v1/hebergements                → Liste hébergements
GET  /api/v1/hebergements/{id}           → Détail hébergement

GET  /api/v1/immobilier                  → Liste immobilier
GET  /api/v1/immobilier/{id}             → Détail bien

GET  /api/v1/artisans                    → Liste artisans
GET  /api/v1/artisans/{id}               → Détail artisan

GET  /api/v1/urgences                    → Numéros d'urgence
GET  /api/v1/actualites                  → Actualités
GET  /api/v1/annonces                    → Annonces

POST /api/v1/fcm-token                   → Enregistrer token FCM
POST /api/v1/notifications/envoyer       → Envoyer notif push (admin)

POST /api/v1/auth/register               → Inscription
POST /api/v1/auth/login                  → Connexion
```

### Format de réponse standard

Tous les endpoints retournent ce format JSON :
```json
{
  "success": true,
  "data": [ ... ]
}
```

---

## 4. NOTIFICATIONS PUSH (FCM)

### Comment ça fonctionne

```
Admin envoie notif (panel ou API)
        ↓
Laravel → Firebase Cloud Messaging (FCM)
        ↓
FCM → Téléphones enregistrés
        ↓
App Flutter reçoit et affiche
        ↓
Stocké dans Hive → visible dans écran Notifications
```

### Configuration Firebase (à faire une seule fois)

**Étape 1 — Créer le projet Firebase**
1. Aller sur https://console.firebase.google.com
2. Créer un projet "daoukro-digital"
3. Ajouter une app Android avec le package `ci.daoukro.user`
4. Télécharger `google-services.json`
5. Placer le fichier dans `daoukro_user/android/app/google-services.json`

**Étape 2 — Configurer Android**

Dans `android/build.gradle` (niveau projet), ajouter :
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Dans `android/app/build.gradle`, ajouter en bas :
```gradle
apply plugin: 'com.google.gms.google-services'
```

**Étape 3 — Récupérer la clé serveur FCM**
1. Firebase Console → Paramètres du projet → Cloud Messaging
2. Copier la "Clé du serveur" (Server Key)
3. La coller dans `.env` Laravel : `FCM_SERVER_KEY=VOTRE_CLE`

**Étape 4 — Envoyer une notification depuis l'API**
```bash
curl -X POST http://votre-api/api/v1/notifications/envoyer \
  -H "Content-Type: application/json" \
  -d '{
    "titre": "Alerte eau",
    "corps": "Coupure d eau ce soir de 18h à 22h",
    "type": "alerte"
  }'
```

**Types de notifications disponibles :**
| type | Icône affichée | Couleur |
|------|---------------|---------|
| `alerte` | ⚠️ warning | Rouge |
| `sante` | 🏥 hospital | Vert |
| `mairie` | 🏛️ account_balance | Vert primaire |
| `pharmacie` | 💊 local_pharmacy | Vert primaire |
| (vide) | 🔔 notifications | Bleu |

---

## 5. OÙ TOUCHER QUOI — GUIDE PRATIQUE

### Changer les couleurs de l'app
```
lib/core/constants/app_colors.dart
```
Modifier `primary` pour changer la couleur principale partout.

### Changer l'URL de l'API
```
lib/core/constants/app_constants.dart
```
```dart
static const String baseUrl = 'http://VOTRE_IP/daoukro-api/public/api/v1';
// En production :
static const String baseUrl = 'https://api-daoukro.akdev.ci/api/v1';
```

### Ajouter une nouvelle page
1. Créer le fichier dans `lib/presentation/screens/ma_section/ma_page.dart`
2. Ajouter la route dans `lib/router/app_router.dart`
3. Ajouter un lien depuis l'accueil ou la navigation

### Ajouter un nouveau module (ex: Marché)
1. Créer le modèle : `lib/data/models/marche_model.dart`
2. Créer le provider : `lib/presentation/providers/marche_provider.dart`
3. Créer les écrans : `lib/presentation/screens/marche/`
4. Ajouter les routes dans `app_router.dart`
5. Ajouter l'icône dans `_AccesRapide` dans `home_screen.dart`
6. Côté API : créer `MarcheController.php` + route dans `api.php`

### Modifier le texte du bouton signalement (accueil)
```
lib/presentation/screens/home/home_screen.dart
```
Chercher `_BoutonSignalement` → modifier les textes.

### Modifier les infos "À propos"
```
lib/presentation/screens/about/about_screen.dart
```

### Ajouter un artisan / pharmacie / service
→ Passer par le **panel admin Filament** :
```
http://localhost/daoukro-api/public/admin
```

### Modifier la durée du cache offline
```
lib/core/constants/app_constants.dart
static const int cacheDuration = 24; // heures
```

---

## 6. COMMANDES FLUTTER

### Installation et setup
```bash
# Vérifier que Flutter est bien installé
flutter doctor

# Installer les dépendances du projet
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade
```

### Développement
```bash
# Lancer l'app sur un émulateur ou téléphone connecté
flutter run

# Lancer avec rechargement automatique (hot reload)
flutter run --hot

# Voir les appareils disponibles
flutter devices

# Lancer sur un appareil spécifique
flutter run -d <device_id>

# Voir les logs en temps réel
flutter logs
```

### Build APK
```bash
# APK de debug (pour tester)
flutter build apk --debug

# APK de release (pour distribuer)
flutter build apk --release

# APK optimisé par architecture (plus léger)
flutter build apk --split-per-abi --release

# Localisation de l'APK généré :
# build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (pour Google Play Store)
```bash
flutter build appbundle --release
# Fichier : build/app/outputs/bundle/release/app-release.aab
```

### Nettoyage
```bash
# Nettoyer le build (résout beaucoup de problèmes)
flutter clean

# Puis réinstaller les dépendances
flutter pub get
```

### Analyse du code
```bash
# Analyser les erreurs et warnings
flutter analyze

# Formater le code automatiquement
dart format lib/
```

### Gestion des dépendances
```bash
# Voir les dépendances obsolètes
flutter pub outdated

# Ajouter une dépendance
flutter pub add nom_du_package

# Supprimer une dépendance
flutter pub remove nom_du_package
```

---

## 7. COMMANDES LARAVEL

### Développement local (Laragon)
```bash
# Lancer le serveur (Laragon le fait automatiquement)
# URL locale : http://localhost/daoukro-api/public

# Lancer les migrations (créer/mettre à jour les tables)
php artisan migrate

# Lancer les migrations + seeders (données de test)
php artisan migrate:fresh --seed

# Lancer uniquement les seeders
php artisan db:seed

# Créer la migration pour fcm_tokens
php artisan migrate --path=database/migrations/2026_07_15_000001_create_fcm_tokens_table.php
```

### Créer de nouveaux éléments
```bash
# Créer un modèle + migration + controller en une commande
php artisan make:model NomModele -mc

# Créer uniquement un controller
php artisan make:controller Api/V1/NomController

# Créer uniquement une migration
php artisan make:migration create_nom_table

# Créer un seeder
php artisan make:seeder NomSeeder
```

### Cache et optimisation
```bash
# Vider tous les caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimiser pour la production
php artisan config:cache
php artisan route:cache
```

### Tester l'API
```bash
# Lister toutes les routes API
php artisan route:list --path=api

# Tester une route depuis le terminal
curl http://localhost/daoukro-api/public/api/v1/pharmacies
```

### Logs
```bash
# Voir les logs en temps réel
tail -f storage/logs/laravel.log

# Vider les logs
php artisan log:clear
# ou manuellement :
echo "" > storage/logs/laravel.log
```

---

## 8. DÉPLOIEMENT APK ANDROID

### Préparer la signature (une seule fois)

```bash
# Générer un keystore (clé de signature)
keytool -genkey -v -keystore daoukro.keystore \
  -alias daoukro -keyalg RSA -keysize 2048 -validity 10000

# Placer le fichier dans : android/app/daoukro.keystore
```

Créer `android/key.properties` :
```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=daoukro
storeFile=daoukro.keystore
```

Dans `android/app/build.gradle`, ajouter la config de signature.

### Changer la version de l'app

Dans `pubspec.yaml` :
```yaml
version: 1.0.1+2
#        ^^^^^  ← versionName (affiché aux utilisateurs)
#              ^ ← versionCode (doit augmenter à chaque release)
```

### Générer l'APK final
```bash
# Mettre à jour l'URL API vers la production d'abord !
# lib/core/constants/app_constants.dart

flutter clean
flutter pub get
flutter build apk --release --split-per-abi

# Les APKs sont dans :
# build/app/outputs/flutter-apk/
#   app-arm64-v8a-release.apk   ← Pour téléphones récents (à privilégier)
#   app-armeabi-v7a-release.apk ← Pour anciens téléphones
#   app-x86_64-release.apk      ← Pour émulateurs
```

### Distribuer l'APK
- **Directement** : envoyer `app-arm64-v8a-release.apk` par WhatsApp/email
- **Firebase App Distribution** : distribution beta automatique
- **Google Play Store** : utiliser le `.aab` (App Bundle)

---

## 9. DÉPLOIEMENT API EN PRODUCTION

### Hébergement recommandé
- **Infomaniak** (Suisse, RGPD) — à partir de 5€/mois
- **DigitalOcean** — droplet 6$/mois
- **OVH** — hébergement mutualisé PHP

### Étapes de déploiement

**1. Préparer le serveur**
```bash
# Sur le serveur (Ubuntu)
sudo apt install php8.2 php8.2-sqlite3 php8.2-mbstring php8.2-xml nginx
```

**2. Uploader le code**
```bash
# Via Git
git clone https://github.com/votre-repo/daoukro-api.git
cd daoukro-api

# Installer les dépendances
composer install --no-dev --optimize-autoloader
```

**3. Configurer l'environnement**
```bash
cp .env.example .env
php artisan key:generate

# Éditer .env :
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api-daoukro.akdev.ci
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_DATABASE=daoukro_db
DB_USERNAME=daoukro_user
DB_PASSWORD=MOT_DE_PASSE_FORT
FCM_SERVER_KEY=VOTRE_CLE_FCM
```

**4. Migrer la base de données**
```bash
php artisan migrate --force
php artisan db:seed --force
```

**5. Optimiser**
```bash
php artisan config:cache
php artisan route:cache
php artisan storage:link
chmod -R 775 storage bootstrap/cache
```

**6. Mettre à jour l'URL dans Flutter**
```dart
// lib/core/constants/app_constants.dart
static const String baseUrl = 'https://api-daoukro.akdev.ci/api/v1';
```

---

## 10. CHECKLIST AVANT CHAQUE RELEASE

### Avant de générer l'APK
- [ ] URL API mise à jour vers la production dans `app_constants.dart`
- [ ] Version incrémentée dans `pubspec.yaml`
- [ ] `flutter clean && flutter pub get` exécuté
- [ ] `flutter analyze` sans erreurs critiques
- [ ] Testé sur un vrai téléphone Android
- [ ] Notifications push testées
- [ ] Mode offline testé (couper le WiFi)

### Avant de déployer l'API
- [ ] `APP_DEBUG=false` dans `.env` de production
- [ ] `php artisan config:cache` exécuté
- [ ] Migrations exécutées
- [ ] Clé FCM configurée
- [ ] CORS configuré pour accepter les requêtes de l'app

---

## RÉSUMÉ DES FICHIERS CLÉS

| Fichier | Quand le modifier |
|---------|------------------|
| `lib/core/constants/app_constants.dart` | Changer l'URL API |
| `lib/core/constants/app_colors.dart` | Changer les couleurs |
| `lib/router/app_router.dart` | Ajouter/modifier des routes |
| `lib/presentation/screens/home/home_screen.dart` | Modifier l'accueil |
| `lib/presentation/screens/about/about_screen.dart` | Infos contact/légal |
| `pubspec.yaml` | Ajouter des packages, changer la version |
| `android/app/google-services.json` | Config Firebase |
| `.env` (Laravel) | Secrets, BDD, FCM |
| `routes/api.php` (Laravel) | Ajouter des routes API |
| `config/services.php` (Laravel) | Clés services externes |

---

*Rapport généré pour le projet Daoukro Digital — AKDEV © 2026*

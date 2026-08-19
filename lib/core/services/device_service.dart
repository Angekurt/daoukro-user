import 'dart:io' show Platform;
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class DeviceService {
  DeviceService._();
  static final instance = DeviceService._();

  static const _keyDeviceId = 'app_persistent_device_id';
  static const _appVersion = '1.1.0';

  String? _cachedDeviceId;

  /// Initialise et enregistre l'appareil auprès du backend
  Future<void> init({String? fcmToken}) async {
    try {
      final deviceId = await getDeviceId();
      final platform = await getPlatform();
      final model = await getDeviceModel();
      final osVersion = await getOsVersion();
      final isPwa = kIsWeb;

      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      await dio.post('/devices/register', data: {
        'device_id': deviceId,
        'platform': platform,
        'device_model': model,
        'os_version': osVersion,
        'app_version': _appVersion,
        'is_pwa': isPwa,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      });
    } catch (_) {
      // Échec silencieux en mode hors-ligne
    }
  }

  /// Récupère un identifiant unique et immuable par appareil physique
  /// Sur Android : utilise l'Android ID matériel (inchangé même après réinstallation).
  /// Sur Web / PWA iOS : utilise un identifiant persistant stocké dans SharedPreferences / localStorage.
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_keyDeviceId);

    if (kIsWeb) {
      if (savedId != null && savedId.isNotEmpty) {
        _cachedDeviceId = savedId;
        return savedId;
      }
      final newId = 'pwa_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999999)}';
      await prefs.setString(_keyDeviceId, newId);
      _cachedDeviceId = newId;
      return newId;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (!kIsWeb && Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // androidInfo.id correspond à l'identifiant matériel unique de l'appareil
        final hardwareId = androidInfo.id;
        if (hardwareId.isNotEmpty) {
          _cachedDeviceId = 'android_$hardwareId';
          await prefs.setString(_keyDeviceId, _cachedDeviceId!);
          return _cachedDeviceId!;
        }
      } else if (!kIsWeb && Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final vendorId = iosInfo.identifierForVendor;
        if (vendorId != null && vendorId.isNotEmpty) {
          _cachedDeviceId = 'ios_$vendorId';
          await prefs.setString(_keyDeviceId, _cachedDeviceId!);
          return _cachedDeviceId!;
        }
      }
    } catch (_) {}

    // Fallback UUID persistant
    if (savedId != null && savedId.isNotEmpty) {
      _cachedDeviceId = savedId;
      return savedId;
    }

    final newId = 'dev_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999999)}';
    await prefs.setString(_keyDeviceId, newId);
    _cachedDeviceId = newId;
    return newId;
  }

  /// Identifie la plateforme exacte
  Future<String> getPlatform() async {
    if (kIsWeb) {
      // Détection iOS sur Safari / Web
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ios_pwa';
      }
      return 'web';
    }
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios_app';
    return 'android';
  }

  /// Récupère le modèle lisible de l'appareil
  Future<String> getDeviceModel() async {
    if (kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'iPhone / iPad (PWA iOS)';
      }
      return 'Navigateur Web';
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}'.trim();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (_) {}

    return 'Appareil Mobile';
  }

  /// Récupère la version de l'OS
  Future<String> getOsVersion() async {
    if (kIsWeb) {
      return 'PWA Web';
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      }
    } catch (_) {}

    return 'Inconnu';
  }
}

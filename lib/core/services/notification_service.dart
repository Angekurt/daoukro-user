import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

// Handler de fond — doit être une fonction top-level. Tourne dans un isolate
// séparé (app fermée ou en arrière-plan) : Hive n'y est pas déjà initialisé
// par main(), il faut le faire ici avant de pouvoir sauvegarder la notif.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.showLocalNotification(message);
  await NotificationService.instance.sauvegarderDepuisArrierePlan(message);
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  // Accès paresseux : ne construit FirebaseMessaging.instance que si on
  // l'utilise réellement (jamais sur web, où Firebase n'est pas initialisé).
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'daoukro_channel';
  static const _channelName = 'Daoukro Digital';
  static const _boxNotifs = 'notifications_box';

  Future<void> init() async {
    if (kIsWeb) return; // Firebase (et donc FCM) n'est pas configuré pour le web.

    // Demande permission notifications
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Créer le canal Android (obligatoire Android 8+)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Alertes et actualités de Daoukro',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialiser le plugin local
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _local.initialize(initSettings);

    // Ouvrir boîte Hive pour stocker les notifs
    if (!Hive.isBoxOpen(_boxNotifs)) {
      await Hive.openBox(_boxNotifs);
    }

    // Envoyer le token FCM à l'API
    final token = await _fcm.getToken();
    if (token != null) await _envoyerToken(token);
    _fcm.onTokenRefresh.listen(_envoyerToken);

    // Notif reçue en foreground → afficher + sauvegarder
    FirebaseMessaging.onMessage.listen((msg) {
      showLocalNotification(msg);
      _sauvegarderNotification(msg);
    });

    // Handler background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Notif cliquée depuis background
    FirebaseMessaging.onMessageOpenedApp.listen(_sauvegarderNotification);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // Appelé depuis l'isolate de fond : Hive n'y est jamais déjà ouvert
  // (contrairement à l'isolate principal, initialisé une fois dans main()).
  Future<void> sauvegarderDepuisArrierePlan(RemoteMessage message) async {
    if (!Hive.isBoxOpen(_boxNotifs)) {
      await Hive.initFlutter();
      await Hive.openBox(_boxNotifs);
    }
    _sauvegarderNotification(message);
  }

  void _sauvegarderNotification(RemoteMessage message) {
    if (!Hive.isBoxOpen(_boxNotifs)) return;
    final box = Hive.box(_boxNotifs);
    final notif = {
      'titre': message.notification?.title ?? '',
      'corps': message.notification?.body ?? '',
      'date': DateTime.now().toIso8601String(),
      'data': message.data,
      'lue': false,
    };
    final liste = List<dynamic>.from(box.get('liste', defaultValue: []));
    liste.insert(0, notif);
    if (liste.length > 50) liste.removeLast();
    box.put('liste', liste);
  }

  Future<void> _envoyerToken(String token) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
      ));
      await dio.post('/fcm-token', data: {'token': token});
    } catch (_) {}
  }

  List<Map<String, dynamic>> getNotifications() {
    if (!Hive.isBoxOpen(_boxNotifs)) return [];
    final box = Hive.box(_boxNotifs);
    final liste = List<dynamic>.from(box.get('liste', defaultValue: []));
    return liste.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  int getNombreNonLues() {
    return getNotifications().where((n) => n['lue'] == false).length;
  }

  Future<void> marquerToutesLues() async {
    if (!Hive.isBoxOpen(_boxNotifs)) return;
    final box = Hive.box(_boxNotifs);
    final liste = getNotifications().map((n) => {...n, 'lue': true}).toList();
    await box.put('liste', liste);
  }

  Future<void> marquerLue(int index) async {
    if (!Hive.isBoxOpen(_boxNotifs)) return;
    final box = Hive.box(_boxNotifs);
    final liste = getNotifications();
    if (index < liste.length) {
      liste[index] = {...liste[index], 'lue': true};
      await box.put('liste', liste);
    }
  }

  Future<void> supprimerTout() async {
    if (!Hive.isBoxOpen(_boxNotifs)) return;
    final box = Hive.box(_boxNotifs);
    await box.put('liste', []);
  }

  Future<void> supprimerUne(int index) async {
    if (!Hive.isBoxOpen(_boxNotifs)) return;
    final box = Hive.box(_boxNotifs);
    final liste = getNotifications();
    if (index < liste.length) {
      liste.removeAt(index);
      await box.put('liste', liste);
    }
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  // Pas de firebase_options.dart pour le web : Firebase n'y est pas
  // initialisé (voir main.dart), donc on désactive Analytics sur cette
  // plateforme plutôt que de planter au premier accès.
  FirebaseAnalytics? get _analytics => kIsWeb ? null : FirebaseAnalytics.instance;

  static const _keyLancementsCount = 'app_launches_count';

  List<NavigatorObserver> get observers =>
      kIsWeb ? [] : [FirebaseAnalyticsObserver(analytics: _analytics!)];

  Future<void> logEcran(String nomEcran) async {
    await _analytics?.logScreenView(screenName: nomEcran);
  }

  Future<void> logAction(String action, {Map<String, Object>? params}) async {
    await _analytics?.logEvent(name: action, parameters: params);
  }

  // Demander un avis après 5 lancements
  Future<void> verifierDemandeAvis() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyLancementsCount) ?? 0) + 1;
    await prefs.setInt(_keyLancementsCount, count);

    if (count == 5 || count == 20 || count == 50) {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    }
  }
}

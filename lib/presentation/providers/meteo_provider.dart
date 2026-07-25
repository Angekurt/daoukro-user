import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/cache_manager.dart';

class MeteoData {
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icone; // code OpenWeatherMap
  final int humidite;
  final double vent; // km/h
  final String ville;
  final bool horsLigne; // true si issu du cache (pas de réseau)
  final DateTime derniereMaj;

  const MeteoData({
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icone,
    required this.humidite,
    required this.vent,
    required this.ville,
    this.horsLigne = false,
    required this.derniereMaj,
  });

  factory MeteoData.fromJson(Map json, {required bool horsLigne, required DateTime derniereMaj}) {
    return MeteoData(
      temperature: (json['main']['temp'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icone: json['weather'][0]['icon'] as String,
      humidite: json['main']['humidity'] as int,
      vent: ((json['wind']['speed'] as num) * 3.6).toDouble(), // m/s → km/h
      ville: json['name'] as String,
      horsLigne: horsLigne,
      derniereMaj: derniereMaj,
    );
  }
}

// Clé OpenWeatherMap du compte Daoukro Digital.
// Peut être surchargée au build avec --dart-define=OWM_KEY=xxxxxxxx
// (utile pour basculer sur une autre clé sans recompiler le code).
const _apiKey = String.fromEnvironment(
  'OWM_KEY',
  defaultValue: '0678ed363b07d9ddbb8f210e22dec900',
);
const _ville = 'Daoukro,CI';
const _cacheKey = 'meteo_cache';
const _cacheTimeKey = 'meteo_cache_time';

final meteoProvider = FutureProvider<MeteoData>((ref) async {
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather'
    '?q=$_ville&appid=$_apiKey&units=metric&lang=fr',
  );
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    debugPrint('[METEO] status=${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Météo indisponible (HTTP ${response.statusCode})');
    }
    final json = jsonDecode(response.body);
    final maintenant = DateTime.now();
    await CacheManager.save(_cacheKey, response.body);
    await CacheManager.save(_cacheTimeKey, maintenant.toIso8601String());
    return MeteoData.fromJson(json, horsLigne: false, derniereMaj: maintenant);
  } catch (e, st) {
    debugPrint('[METEO] ERREUR: $e\n$st');
    // Pas de réseau (ou API indisponible) : on retombe sur la dernière météo connue.
    final cachedBody = CacheManager.get(_cacheKey);
    if (cachedBody != null) {
      final cachedTimeRaw = CacheManager.get(_cacheTimeKey);
      final derniereMaj = cachedTimeRaw != null
          ? DateTime.tryParse(cachedTimeRaw as String) ?? DateTime.now()
          : DateTime.now();
      final json = jsonDecode(cachedBody as String);
      return MeteoData.fromJson(json, horsLigne: true, derniereMaj: derniereMaj);
    }
    rethrow;
  }
});

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Résultat d'un calcul d'itinéraire routier : le tracé (suit les routes,
/// carrefours, virages réels) + la distance et la durée estimée en voiture.
class RouteResult {
  final List<LatLng> points;
  final double distanceMetres;
  final int dureeSecondes;

  RouteResult({
    required this.points,
    required this.distanceMetres,
    required this.dureeSecondes,
  });
}

/// Calcul d'itinéraire routier via OSRM (Open Source Routing Machine),
/// cohérent avec le choix OpenStreetMap déjà fait pour la carte — gratuit,
/// pas de facturation, contrairement à l'API Directions de Google.
///
/// Utilise le serveur de démonstration public OSRM (router.project-osrm.org),
/// prévu pour des tests légers. Pour un usage en production à plus grande
/// échelle, il faudra héberger sa propre instance OSRM.
class RoutingService {
  RoutingService._();

  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  static Future<RouteResult?> calculer({
    required double departLat,
    required double departLng,
    required double arriveeLat,
    required double arriveeLng,
  }) async {
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      final coords = '$departLng,$departLat;$arriveeLng,$arriveeLat';
      final response = await dio.get(
        '$_baseUrl/$coords',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );

      if (response.data['code'] != 'Ok') return null;
      final route = response.data['routes'][0];
      final coordinates = route['geometry']['coordinates'] as List;

      return RouteResult(
        points: coordinates
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList(),
        distanceMetres: (route['distance'] as num).toDouble(),
        dureeSecondes: (route['duration'] as num).round(),
      );
    } catch (_) {
      // Hors-ligne ou service indisponible → l'appelant doit prévoir un
      // repli (ex. ligne droite + distance à vol d'oiseau).
      return null;
    }
  }
}

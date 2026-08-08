import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/routing_service.dart';

class ItineraireScreen extends StatefulWidget {
  final double destLat;
  final double destLng;
  final String nomDestination;

  const ItineraireScreen({
    super.key,
    required this.destLat,
    required this.destLng,
    required this.nomDestination,
  });

  @override
  State<ItineraireScreen> createState() => _ItineraireScreenState();
}

class _ItineraireScreenState extends State<ItineraireScreen> {
  final MapController _mapController = MapController();
  Position? _maPosition;
  bool _chargement = true;
  String? _erreur;
  double? _distance;
  RouteResult? _itineraire;
  bool _chargementItineraire = false;

  @override
  void initState() {
    super.initState();
    _obtenirPosition();
  }

  Future<void> _obtenirPosition() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      bool serviceActif = await Geolocator.isLocationServiceEnabled();
      if (!serviceActif) {
        setState(() {
          _erreur = 'Le service de localisation est désactivé.';
          _chargement = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _erreur = 'Permission de localisation refusée.';
            _chargement = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _erreur = 'Permission refusée. Activez-la dans les paramètres.';
          _chargement = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        setState(() {
          _erreur = 'Position GPS invalide, réessayez.';
          _chargement = false;
        });
        return;
      }

      final distanceMetres = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.destLat,
        widget.destLng,
      );

      setState(() {
        _maPosition = position;
        _distance = distanceMetres;
        _chargement = false;
      });

      _centrerCarte(position);
      _calculerItineraire(position);
    } catch (e) {
      setState(() {
        _erreur = 'Impossible d\'obtenir votre position.';
        _chargement = false;
      });
    }
  }

  Future<void> _calculerItineraire(Position position) async {
    setState(() => _chargementItineraire = true);
    final route = await RoutingService.calculer(
      departLat: position.latitude,
      departLng: position.longitude,
      arriveeLat: widget.destLat,
      arriveeLng: widget.destLng,
    );
    if (!mounted) return;
    setState(() {
      _itineraire = route;
      _chargementItineraire = false;
    });
  }

  String _formaterDuree(int secondes) {
    final minutes = (secondes / 60).round();
    if (minutes < 60) return '$minutes min';
    final heures = minutes ~/ 60;
    final reste = minutes % 60;
    return reste == 0 ? '${heures}h' : '${heures}h${reste.toString().padLeft(2, '0')}';
  }

  void _centrerCarte(Position position) {
    final centerLat = (position.latitude + widget.destLat) / 2;
    final centerLng = (position.longitude + widget.destLng) / 2;

    double zoom = 14;
    if (_distance != null) {
      if (_distance! > 10000) {
        zoom = 11;
      } else if (_distance! > 5000) {
        zoom = 12;
      } else if (_distance! > 2000) {
        zoom = 13;
      } else if (_distance! > 500) {
        zoom = 14;
      } else {
        zoom = 16;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(centerLat, centerLng), zoom);
    });
  }

  String _formaterDistance(double metres) {
    if (metres >= 1000) return '${(metres / 1000).toStringAsFixed(1)} km';
    return '${metres.toInt()} m';
  }

  @override
  Widget build(BuildContext context) {
    final dest = LatLng(widget.destLat, widget.destLng);

    return Scaffold(
      body: Stack(
        children: [
          // Carte principale
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: dest,
              initialZoom: 15,
              minZoom: 8,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ci.daoukro.user',
              ),

              // Tracé du trajet — suit les routes (OSRM) si disponible,
              // sinon repli sur une ligne directe (hors-ligne / service indisponible).
              if (_maPosition != null)
                PolylineLayer(
                  polylines: [
                    if (_itineraire != null)
                      Polyline(
                        points: _itineraire!.points,
                        color: AppColors.primary,
                        strokeWidth: 5,
                      )
                    else
                      Polyline(
                        points: [
                          LatLng(_maPosition!.latitude, _maPosition!.longitude),
                          dest,
                        ],
                        color: AppColors.primary,
                        strokeWidth: 4,
                        pattern: StrokePattern.dashed(segments: const [12, 6]),
                      ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Marqueur destination
                  Marker(
                    point: dest,
                    width: 50,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: const Icon(Icons.place, color: AppColors.white, size: 20),
                        ),
                        CustomPaint(
                          size: const Size(12, 8),
                          painter: _TrianglePainter(AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                  // Marqueur position utilisateur
                  if (_maPosition != null)
                    Marker(
                      point: LatLng(_maPosition!.latitude, _maPosition!.longitude),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.securite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Bouton retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _BoutonRetour(),
            ),
          ),

          // Zoom +/-
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 180),
                  child: _BoutonZoom(mapController: _mapController),
                ),
              ),
            ),
          ),

          // Indicateur chargement
          if (_chargement)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      SizedBox(width: 10),
                      Text('Localisation en cours...', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

          // Panneau bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.place, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nomDestination,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (_chargement)
                              const Text('Calcul de la distance...',
                                  style: TextStyle(fontSize: 13, color: AppColors.textGrey))
                            else if (_erreur != null)
                              Text(_erreur!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.error))
                            else if (_chargementItineraire)
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 12, height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                  SizedBox(width: 6),
                                  Text('Calcul de l\'itinéraire...',
                                      style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                                ],
                              )
                            else if (_itineraire != null)
                              Row(
                                children: [
                                  const Icon(Icons.alt_route,
                                      size: 14, color: AppColors.textGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formaterDistance(_itineraire!.distanceMetres)} · ${_formaterDuree(_itineraire!.dureeSecondes)} de route',
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.textGrey),
                                  ),
                                ],
                              )
                            else if (_distance != null)
                              Row(
                                children: [
                                  const Icon(Icons.straighten,
                                      size: 14, color: AppColors.textGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'À ${_formaterDistance(_distance!)} de vous (à vol d\'oiseau)',
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _obtenirPosition,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text('Ma position'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _mapController.move(dest, 16),
                          icon: const Icon(Icons.center_focus_strong, size: 18),
                          label: const Text('Destination'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonZoom extends StatelessWidget {
  final MapController mapController;
  const _BoutonZoom({required this.mapController});

  void _zoomer(double delta) {
    final camera = mapController.camera;
    mapController.move(camera.center, (camera.zoom + delta).clamp(8, 18));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _zoomer(1),
            icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
            tooltip: 'Zoomer',
          ),
          Container(height: 1, color: AppColors.border),
          IconButton(
            onPressed: () => _zoomer(-1),
            icon: const Icon(Icons.remove, size: 20, color: AppColors.primary),
            tooltip: 'Dézoomer',
          ),
        ],
      ),
    );
  }
}

class _BoutonRetour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color couleur;
  _TrianglePainter(this.couleur);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = couleur;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.couleur != couleur;
}

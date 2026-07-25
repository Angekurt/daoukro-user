import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';

/// Aperçu de localisation encadré (bordure arrondie, hauteur fixe) pour les
/// fiches détail — jamais en plein écran, juste un aperçu cliquable qui
/// renvoie vers l'écran d'itinéraire complet.
class MiniMapCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final IconData icone;
  final Color couleur;
  final VoidCallback? onTap;
  final double height;

  const MiniMapCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.icone,
    required this.couleur,
    this.onTap,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.white12 : AppColors.border, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(latitude, longitude),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'ci.daoukro.user',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 40,
                      height: 40,
                      child: Icon(icone, color: couleur, size: 36),
                    ),
                  ]),
                ],
              ),
            ),
            if (onTap != null) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.directions, color: AppColors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Itinéraire', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

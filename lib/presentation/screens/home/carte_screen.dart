import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../providers/service_public_provider.dart';
import '../../../data/models/service_public_model.dart';

class CarteScreen extends ConsumerStatefulWidget {
  const CarteScreen({super.key});
  @override
  ConsumerState<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends ConsumerState<CarteScreen> {
  final MapController _mapController = MapController();
  String _filtreActif = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  Position? _maPosition;

  static const LatLng _daoukro = LatLng(7.0667, -3.9667);
  final List<String> _filtres = ['Tous', 'Santé', 'Sécurité', 'Administration', 'Education', 'Transport'];

  @override
  void initState() {
    super.initState();
    _obtenirPosition();
  }

  Future<void> _obtenirPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _maPosition = position);
    } catch (_) {}
  }

  void _ouvrirItineraire(double lat, double lng, String nom) {
    context.push('/itineraire', extra: {'lat': lat, 'lng': lng, 'nom': nom});
  }

  List<ServicePublicModel> _filtrer(List<ServicePublicModel> services) {
    var result = services;
    if (_filtreActif != 'Tous') result = result.where((s) => s.categorie?.nom == _filtreActif).toList();
    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) result = result.where((s) => s.nom.toLowerCase().contains(q)).toList();
    return result;
  }

  Color _couleur(String? cat) {
    switch (cat) {
      case 'Santé': return AppColors.sante;
      case 'Sécurité': return AppColors.securite;
      case 'Administration': return AppColors.administration;
      case 'Education': return AppColors.education;
      default: return AppColors.primary;
    }
  }

  IconData _icone(String? cat) {
    switch (cat) {
      case 'Santé': return Icons.local_hospital;
      case 'Sécurité': return Icons.local_police;
      case 'Administration': return Icons.account_balance;
      case 'Education': return Icons.school;
      default: return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesPublicsProvider);

    return Scaffold(
      body: Stack(
        children: [
          servicesAsync.when(
            loading: () => _carteVide(),
            error: (_, __) => _carteVide(),
            data: (services) {
              final filtres = _filtrer(services);
              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(initialCenter: _daoukro, initialZoom: 14, minZoom: 10, maxZoom: 18),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'ci.daoukro.user'),
                  if (_maPosition != null)
                    MarkerLayer(markers: [
                      Marker(
                        point: LatLng(_maPosition!.latitude, _maPosition!.longitude),
                        width: 20, height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.securite, shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 3),
                          ),
                        ),
                      ),
                    ]),
                  MarkerLayer(
                    markers: filtres.where((s) => s.latitude != null && s.longitude != null).map((s) {
                      final c = _couleur(s.categorie?.nom);
                      final ic = _icone(s.categorie?.nom);
                      return Marker(
                        point: LatLng(s.latitude!, s.longitude!),
                        width: 40, height: 40,
                        child: GestureDetector(
                          onTap: () => _afficherInfo(s),
                          child: Container(
                            decoration: BoxDecoration(
                              color: c, shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: Icon(ic, color: AppColors.white, size: 20),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un service ou lieu...',
                        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtres.length,
                    itemBuilder: (_, i) {
                      final f = _filtres[i];
                      final actif = f == _filtreActif;
                      return GestureDetector(
                        onTap: () => setState(() => _filtreActif = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: actif ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: actif ? AppColors.primary : AppColors.border, width: 1),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  color: actif ? AppColors.white : AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: actif ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 24, right: 16,
            child: Column(children: [
              FloatingActionButton.small(
                heroTag: 'pos',
                backgroundColor: AppColors.white,
                onPressed: () {
                  if (_maPosition != null) {
                    _mapController.move(LatLng(_maPosition!.latitude, _maPosition!.longitude), 15);
                  } else {
                    _obtenirPosition();
                  }
                },
                child: Icon(_maPosition != null ? Icons.my_location : Icons.location_searching, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'center',
                backgroundColor: AppColors.white,
                onPressed: () => _mapController.move(_daoukro, 14),
                child: const Icon(Icons.center_focus_strong, color: AppColors.primary),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _carteVide() => FlutterMap(
    options: const MapOptions(initialCenter: _daoukro, initialZoom: 14),
    children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'ci.daoukro.user')],
  );

  void _afficherInfo(ServicePublicModel service) {
    final c = _couleur(service.categorie?.nom);
    final ic = _icone(service.categorie?.nom);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(ic, color: c, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              if (service.categorie != null)
                Text(service.categorie!.nom, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ])),
          ]),
          if (service.adresse != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.textGrey),
              const SizedBox(width: 8),
              Expanded(child: Text(service.adresse!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey))),
            ]),
          ],
          const SizedBox(height: 16),
          Row(children: [
            if (service.telephone != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(context); ContactService.call(context, service.telephone!); },
                  icon: const Icon(Icons.phone),
                  label: const Text('Appeler'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
            if (service.telephone != null) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { Navigator.pop(context); context.push('/services/${service.id}'); },
                icon: const Icon(Icons.info_outline),
                label: const Text('Détails'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: service.latitude != null ? () { Navigator.pop(context); _ouvrirItineraire(service.latitude!, service.longitude!, service.nom); } : null,
                icon: const Icon(Icons.directions),
                label: const Text('Itinéraire'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

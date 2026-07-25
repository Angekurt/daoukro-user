import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import 'package:intl/intl.dart';
import '../../providers/pharmacie_provider.dart';
import '../../../data/models/garde_model.dart';
import '../../../data/models/pharmacie_model.dart';

class GardesScreen extends ConsumerWidget {
  const GardesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardesAsync = ref.watch(gardesActivesProvider);

    return Scaffold(
      backgroundColor: AppColors.dangerLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_pharmacy, size: 20),
            SizedBox(width: 8),
            Text('Pharmacies de Garde'),
          ],
        ),
        backgroundColor: AppColors.gardeActive,
        foregroundColor: AppColors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
            ),
          ),
        ),
      ),
      body: gardesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gardeActive)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: AppColors.textGrey),
              const SizedBox(height: 16),
              Text(e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(gardesActivesProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gardeActive,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (gardes) {
          if (gardes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.gardeActive.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nightlight_round,
                        size: 64, color: AppColors.gardeActive),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune pharmacie de garde\nen ce moment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revenez plus tard ou tirez vers le bas\npour actualiser',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.gardeActive,
            onRefresh: () async => ref.invalidate(gardesActivesProvider),
            child: CustomScrollView(
              slivers: [
                // Bandeau urgence
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gardeActive,
                          AppColors.gardeActive.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const _PulseDot(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SERVICE D\'URGENCE ACTIF',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${gardes.length} pharmacie(s) disponible(s) maintenant',
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GardeCard(garde: gardes[index]),
                      ),
                      childCount: gardes.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GardeCard extends StatelessWidget {
  final GardeModel garde;
  const _GardeCard({required this.garde});

  PharmacieModel get pharmacie => garde.pharmacie;

  String get _periode =>
      'Du ${DateFormat('dd/MM').format(garde.dateDebut)} au ${DateFormat('dd/MM').format(garde.dateFin)}';

  void _ouvrirItineraire(BuildContext context) {
    if (pharmacie.latitude != null && pharmacie.longitude != null) {
      context.push('/itineraire', extra: {
        'lat': pharmacie.latitude!,
        'lng': pharmacie.longitude!,
        'nom': pharmacie.nom,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = pharmacie.latitude != null && pharmacie.longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gardeActive.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          // En-tête carte
          GestureDetector(
            onTap: () => context.push('/pharmacies/${pharmacie.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gardeActive,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_pharmacy,
                        color: AppColors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pharmacie.nom,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gardeActive,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,
                                      size: 6, color: AppColors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'GARDE',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pharmacie.adresse,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (pharmacie.horaires != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 13, color: AppColors.gardeActive),
                              const SizedBox(width: 4),
                              Text(
                                pharmacie.horaires!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gardeActive,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.event_available,
                                size: 13, color: AppColors.gardeActive),
                            const SizedBox(width: 4),
                            Text(
                              _periode,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gardeActive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Séparateur
          Divider(height: 1, color: AppColors.gardeActive.withValues(alpha: 0.15)),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (pharmacie.telephone != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => ContactService.call(context, pharmacie.telephone!),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Appeler'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gardeActive,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (pharmacie.telephone != null && hasCoords)
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.gardeActive.withValues(alpha: 0.2),
                  ),
                if (hasCoords)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _ouvrirItineraire(context),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Itinéraire'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gardeActive,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.gardeActive.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.push('/pharmacies/${pharmacie.id}'),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Détails'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textGrey,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Point pulsant animé
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

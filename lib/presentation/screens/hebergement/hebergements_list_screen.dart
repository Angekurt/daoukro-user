import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../../data/models/hebergement_model.dart';

class HebergementsListScreen extends ConsumerStatefulWidget {
  const HebergementsListScreen({super.key});
  @override
  ConsumerState<HebergementsListScreen> createState() => _HebergementsListScreenState();
}

class _HebergementsListScreenState extends ConsumerState<HebergementsListScreen> {
  String _filtre = 'Tous';
  final _filtres = ['Tous', 'Hôtel', 'Résidence', 'Meublé'];

  List<HebergementModel> _filtrer(List<HebergementModel> liste) {
    if (_filtre == 'Tous') return liste;
    final map = {'Hôtel': 'hotel', 'Résidence': 'residence', 'Meublé': 'meuble'};
    return liste.where((h) => h.type == map[_filtre]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(hebergementsProvider);
    return Scaffold(
      floatingActionButton: const SupportFab(contexte: 'Liste des hébergements'),
      appBar: AppBar(
        title: const Text('Hébergements'),
        backgroundColor: AppColors.hebergement,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filtres.length,
                itemBuilder: (_, i) {
                  final f = _filtres[i];
                  final actif = f == _filtre;
                  return GestureDetector(
                    onTap: () => setState(() => _filtre = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: actif ? AppColors.hebergement : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              color: actif ? AppColors.white : AppColors.textDark,
                              fontWeight: actif ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const _ShimmerLoading(),
              error: (e, _) => _Erreur(message: e.toString(), onRetry: () => ref.invalidate(hebergementsProvider)),
              data: (liste) {
                final filtree = _filtrer(liste);
                if (filtree.isEmpty) {
                  return const EtatVide(
                    icone: PhosphorIconsRegular.bed,
                    titre: 'Aucun hébergement trouvé',
                    message: 'Essayez une autre recherche.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(hebergementsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtree.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _HebergementCard(h: filtree[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HebergementCard extends StatelessWidget {
  final HebergementModel h;
  const _HebergementCard({required this.h});

  String _formatPrix(double? min, double? max) {
    if (min == null) return 'Prix sur demande';
    final minStr = '${(min / 1000).toStringAsFixed(0)}k';
    if (max == null) return 'À partir de $minStr FCFA/nuit';
    return '$minStr – ${(max / 1000).toStringAsFixed(0)}k FCFA/nuit';
  }

  String _labelType(String type) {
    switch (type) {
      case 'hotel': return 'Hôtel';
      case 'residence': return 'Résidence';
      case 'meuble': return 'Meublé';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    const couleur = AppColors.hebergement;
    return GestureDetector(
      onTap: () => context.push('/hebergements/${h.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.hotel, color: couleur, size: 48)),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
                      child: Text(_labelType(h.type),
                          style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (h.note != null)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star, size: 13, color: AppColors.secondary),
                          const SizedBox(width: 3),
                          Text(h.note!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          if (h.nbAvis != null)
                            Text(' (${h.nbAvis})',
                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  if (h.adresse != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(h.adresse!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatPrix(h.prixMin, h.prixMax),
                          style: const TextStyle(fontSize: 13, color: couleur, fontWeight: FontWeight.w600)),
                      if (h.telephone != null)
                        GestureDetector(
                          onTap: () => ContactService.call(context, h.telephone!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.phone, color: couleur, size: 18),
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
    );
  }
}

class _Erreur extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Erreur({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 48, color: AppColors.textGrey),
      const SizedBox(height: 16),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
          child: const Text('Réessayer')),
    ]),
  );
}


class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.surfaceAlt,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

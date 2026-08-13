import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../providers/annonce_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../../data/models/annonce_model.dart';

// Supprime les balises HTML (ex: <p>, </p>, <br>, etc.) d'une chaîne
String _stripHtml(String texte) =>
    texte.replaceAll(RegExp(r'<[^>]*>'), '').trim();

class AnnoncesListScreen extends ConsumerStatefulWidget {
  const AnnoncesListScreen({super.key});
  @override
  ConsumerState<AnnoncesListScreen> createState() => _AnnoncesListScreenState();
}

class _AnnoncesListScreenState extends ConsumerState<AnnoncesListScreen> {
  TypeAnnonce? _filtre;

  static const _config = {
    TypeAnnonce.evenement: (couleur: AppColors.evenement, icone: Icons.event, label: 'Événement'),
    TypeAnnonce.emploi: (couleur: AppColors.emploi, icone: Icons.work_outline, label: 'Emploi'),
    TypeAnnonce.restaurant: (couleur: AppColors.restaurant, icone: Icons.restaurant, label: 'Restaurant'),
    TypeAnnonce.pub: (couleur: AppColors.pub, icone: Icons.local_bar_outlined, label: 'Sortie'),
    TypeAnnonce.annonce: (couleur: AppColors.annonce, icone: Icons.campaign_outlined, label: 'Annonce'),
  };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(annoncesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces & Événements'),
        backgroundColor: AppColors.annonce,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(),
      ),
      body: Column(
        children: [
          // Filtres par type
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FiltreChip(
                    label: 'Tous',
                    actif: _filtre == null,
                    couleur: AppColors.annonce,
                    onTap: () => setState(() => _filtre = null),
                  ),
                  ..._config.entries.map((e) => _FiltreChip(
                    label: e.value.label,
                    actif: _filtre == e.key,
                    couleur: e.value.couleur,
                    icone: e.value.icone,
                    onTap: () => setState(() => _filtre = _filtre == e.key ? null : e.key),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const _ShimmerLoading(),
              error: (e, _) => EtatErreur(onRetry: () => ref.invalidate(annoncesProvider)),
              data: (annonces) {
                final filtrees = _filtre == null
                    ? annonces
                    : annonces.where((a) => a.type == _filtre).toList();
                if (filtrees.isEmpty) {
                  return const EtatVide(
                    icone: PhosphorIconsRegular.megaphone,
                    titre: 'Aucune annonce trouvée',
                    message: 'Essayez une autre catégorie.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(annoncesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtrees.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AnnonceCard(annonce: filtrees[i]),
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

class _FiltreChip extends StatelessWidget {
  final String label;
  final bool actif;
  final Color couleur;
  final IconData? icone;
  final VoidCallback onTap;
  const _FiltreChip({required this.label, required this.actif, required this.couleur, this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? couleur : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: actif ? AppColors.white : couleur),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(fontSize: 12,
                  color: actif ? AppColors.white : AppColors.textDark,
                  fontWeight: actif ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  final AnnonceModel annonce;
  const _AnnonceCard({required this.annonce});

  static const _config = {
    TypeAnnonce.evenement: (couleur: AppColors.evenement, icone: Icons.event, label: 'Événement'),
    TypeAnnonce.emploi: (couleur: AppColors.emploi, icone: Icons.work_outline, label: 'Emploi'),
    TypeAnnonce.restaurant: (couleur: AppColors.restaurant, icone: Icons.restaurant, label: 'Restaurant'),
    TypeAnnonce.pub: (couleur: AppColors.pub, icone: Icons.local_bar_outlined, label: 'Sortie'),
    TypeAnnonce.annonce: (couleur: AppColors.annonce, icone: Icons.campaign_outlined, label: 'Annonce'),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _config[annonce.type]!;

    return GestureDetector(
      onTap: () => context.push('/annonces/${annonce.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cfg.couleur.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cfg.couleur.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cfg.icone, color: cfg.couleur, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cfg.couleur,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(cfg.label,
                          style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(annonce.titre,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
            // Corps
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_stripHtml(annonce.description),
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                if (annonce.lieu != null)
                  Row(children: [
                    const Icon(Icons.location_on, size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(annonce.lieu!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ]),
                if (annonce.dateDebut != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(annonce.dateDebut!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    if (annonce.dateFin != null)
                      Text(' → ${annonce.dateFin}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ]),
                ],
              ]),
            ),
            if (annonce.contact != null) ...[
              Divider(height: 1, color: AppColors.surfaceAlt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: TextButton.icon(
                  onPressed: () => ContactService.call(context, annonce.contact!),
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(annonce.contact!),
                  style: TextButton.styleFrom(foregroundColor: cfg.couleur),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

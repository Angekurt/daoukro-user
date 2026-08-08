import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../../data/models/artisan_model.dart';

class ArtisansListScreen extends ConsumerStatefulWidget {
  const ArtisansListScreen({super.key});
  @override
  ConsumerState<ArtisansListScreen> createState() => _ArtisansListScreenState();
}

class _ArtisansListScreenState extends ConsumerState<ArtisansListScreen> {
  String _metier = 'Tous';
  bool _seulementDispo = false;
  final _searchController = TextEditingController();

  static const _metiers = [
    'Tous', 'Plombier', 'Électricien', 'Maçon', 'Menuisier',
    'Peintre', 'Couturière', 'Coiffeuse', 'Mécanicien',
  ];

  List<ArtisanModel> _filtrer(List<ArtisanModel> liste) {
    var result = liste;
    if (_metier != 'Tous') result = result.where((a) => a.metier == _metier).toList();
    if (_seulementDispo) result = result.where((a) => a.disponible).toList();
    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) result = result.where((a) => a.nom.toLowerCase().contains(q) || a.metier.toLowerCase().contains(q)).toList();
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(artisansProvider);

    return Scaffold(
      floatingActionButton: const SupportFab(contexte: 'Liste des artisans'),
      appBar: AppBar(
        title: const Text('Artisans & Prestataires'),
        backgroundColor: AppColors.artisan,
        leading: const BoutonRetour(),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un artisan ou métier...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.artisan),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _seulementDispo = !_seulementDispo),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _seulementDispo ? AppColors.artisan : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check_circle_outline, size: 14,
                              color: _seulementDispo ? AppColors.white : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text('Disponibles uniquement',
                              style: TextStyle(fontSize: 12,
                                  color: _seulementDispo ? AppColors.white : AppColors.textMuted,
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _metiers.length,
                    itemBuilder: (_, i) {
                      final m = _metiers[i];
                      final actif = m == _metier;
                      return GestureDetector(
                        onTap: () => setState(() => _metier = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: actif ? AppColors.artisan : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m,
                              style: TextStyle(fontSize: 12,
                                  color: actif ? AppColors.white : AppColors.textPrimary,
                                  fontWeight: actif ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const _ShimmerLoading(),
              error: (e, _) => EtatErreur(onRetry: () => ref.invalidate(artisansProvider)),
              data: (liste) {
                final filtree = _filtrer(liste);
                if (filtree.isEmpty) {
                  return const EtatVide(
                    icone: PhosphorIconsRegular.hammer,
                    titre: 'Aucun artisan trouvé',
                    message: 'Essayez une autre recherche.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(artisansProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtree.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ArtisanCard(artisan: filtree[i]),
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

class _ArtisanCard extends StatelessWidget {
  final ArtisanModel artisan;
  const _ArtisanCard({required this.artisan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/artisans/${artisan.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.artisan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handyman, color: AppColors.artisan, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(artisan.nom,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: artisan.disponible ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.circle, size: 7,
                                  color: artisan.disponible ? AppColors.success : AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(artisan.disponible ? 'Disponible' : 'Occupé',
                                  style: TextStyle(fontSize: 10,
                                      color: artisan.disponible ? AppColors.success : AppColors.textMuted,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.artisan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(artisan.metier,
                              style: const TextStyle(fontSize: 11, color: AppColors.artisan, fontWeight: FontWeight.w500)),
                        ),
                        if (artisan.note != null) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            ...List.generate(5, (i) => Icon(
                              i < artisan.note!.floor() ? Icons.star : Icons.star_border,
                              size: 14, color: AppColors.secondary,
                            )),
                            const SizedBox(width: 4),
                            Text('${artisan.note!.toStringAsFixed(1)} (${artisan.nbAvis ?? 0} avis)',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (artisan.description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Text(artisan.description!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(children: [
                if (artisan.telephone != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse('tel:${artisan.telephone}');
                        if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Appeler'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.artisan),
                    ),
                  ),
                if (artisan.whatsapp != null) ...[
                  Container(width: 1, height: 24, color: AppColors.border),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final tel = artisan.whatsapp!.replaceAll('+', '').replaceAll(' ', '');
                        final url = Uri.parse('https://wa.me/$tel');
                        if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('WhatsApp'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.whatsapp),
                    ),
                  ),
                ],
                Container(width: 1, height: 24, color: AppColors.border),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.push('/artisans/${artisan.id}'),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Profil'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  ),
                ),
              ]),
            ),
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
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

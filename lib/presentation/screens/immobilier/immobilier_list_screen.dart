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
import '../../../data/models/immobilier_model.dart';

class ImmobilierListScreen extends ConsumerStatefulWidget {
  const ImmobilierListScreen({super.key});
  @override
  ConsumerState<ImmobilierListScreen> createState() => _ImmobilierListScreenState();
}

class _ImmobilierListScreenState extends ConsumerState<ImmobilierListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const couleur = AppColors.immobilier;
    final async = ref.watch(immobilierProvider);

    return Scaffold(
      floatingActionButton: const SupportFab(contexte: 'Liste immobilier'),
      appBar: AppBar(
        title: const Text('Immobilier'),
        backgroundColor: couleur,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white70,
          tabs: const [
            Tab(text: 'À vendre'),
            Tab(text: 'À louer'),
          ],
        ),
      ),
      body: async.when(
        loading: () => const _ShimmerLoading(),
        error: (e, _) => EtatErreur(onRetry: () => ref.invalidate(immobilierProvider)),
        data: (liste) => TabBarView(
          controller: _tabController,
          children: [
            _ListeImmobilier(
              items: liste.where((i) => i.typeOffre == 'vente').toList(),
              onRefresh: () async => ref.invalidate(immobilierProvider),
            ),
            _ListeImmobilier(
              items: liste.where((i) => i.typeOffre == 'location').toList(),
              onRefresh: () async => ref.invalidate(immobilierProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeImmobilier extends StatelessWidget {
  final List<ImmobilierModel> items;
  final Future<void> Function() onRefresh;
  const _ListeImmobilier({required this.items, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EtatVide(
        icone: PhosphorIconsRegular.houseLine,
        titre: 'Aucune offre disponible',
        message: 'Revenez plus tard, de nouvelles annonces arrivent régulièrement.',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ImmobilierCard(item: items[i]),
      ),
    );
  }
}

class _ImmobilierCard extends StatelessWidget {
  final ImmobilierModel item;
  const _ImmobilierCard({required this.item});

  static const _icones = {
    'maison': Icons.home,
    'terrain': Icons.landscape,
    'appartement': Icons.apartment,
    'villa': Icons.villa,
  };

  String _formatPrix(double prix, String typeOffre) {
    final formatted = prix >= 1000000
        ? '${(prix / 1000000).toStringAsFixed(1)} M'
        : '${(prix / 1000).toStringAsFixed(0)} k';
    return '$formatted FCFA${typeOffre == 'location' ? '/mois' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    const couleur = AppColors.immobilier;
    final icone = _icones[item.typeBien] ?? Icons.home;

    return GestureDetector(
      onTap: () => context.push('/immobilier/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icone, color: couleur, size: 48)),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.typeOffre == 'vente' ? couleur : AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.typeOffre == 'vente' ? 'VENTE' : 'LOCATION',
                        style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (item.typeBien.isNotEmpty)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text(item.typeBien.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: couleur, fontWeight: FontWeight.bold)),
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
                  Text(item.titre,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Row(children: [
                    if (item.surface != null) ...[
                      const Icon(Icons.square_foot, size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(item.surface!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      const SizedBox(width: 12),
                    ],
                    if (item.nbChambres != null) ...[
                      const Icon(Icons.bed, size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text('${item.nbChambres} ch.', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ]),
                  if (item.quartier != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(item.quartier!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ]),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatPrix(item.prix, item.typeOffre),
                          style: const TextStyle(fontSize: 15, color: couleur, fontWeight: FontWeight.bold)),
                      if (item.telephone != null)
                        ElevatedButton.icon(
                          onPressed: () => ContactService.call(context, item.telephone!),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Contacter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: couleur,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 12),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/pharmacie_provider.dart';
import '../../../data/models/pharmacie_model.dart';
import '../../widgets/etat_widgets.dart';

class PharmaciesListScreen extends ConsumerStatefulWidget {
  const PharmaciesListScreen({super.key});

  @override
  ConsumerState<PharmaciesListScreen> createState() => _PharmaciesListScreenState();
}

class _PharmaciesListScreenState extends ConsumerState<PharmaciesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PharmacieModel> _filtrer(List<PharmacieModel> pharmacies) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return pharmacies;
    return pharmacies
        .where((p) =>
            p.nom.toLowerCase().contains(query) ||
            p.adresse.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmaciesAsync = ref.watch(pharmaciesProvider);

    return Scaffold(
      floatingActionButton: const SupportFab(contexte: 'Liste des pharmacies'),
      appBar: AppBar(
        title: const Text('Pharmacies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital_outlined),
            tooltip: 'Pharmacies de garde',
            onPressed: () => context.go('/gardes'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher une pharmacie...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Liste
          Expanded(
            child: pharmaciesAsync.when(
              loading: () => const _ShimmerLoading(),
              error: (e, _) => _ErreurWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(pharmaciesProvider),
              ),
              data: (pharmacies) {
                final liste = _filtrer(pharmacies);
                if (liste.isEmpty) {
                  return const EtatVide(
                    icone: PhosphorIconsRegular.firstAidKit,
                    titre: 'Aucune pharmacie trouvée',
                    message: 'Essayez une autre recherche.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(pharmaciesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: liste.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _PharmacieCard(pharmacie: liste[index]),
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

class _PharmacieCard extends ConsumerWidget {
  final PharmacieModel pharmacie;
  const _PharmacieCard({required this.pharmacie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardesAsync = ref.watch(gardesActivesProvider);
    final estDeGarde = gardesAsync.maybeWhen(
      data: (gardes) => gardes.any((g) => g.pharmacie.id == pharmacie.id),
      orElse: () => false,
    );

    return GestureDetector(
      onTap: () => context.push('/pharmacies/${pharmacie.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: estDeGarde ? AppColors.success : AppColors.border,
            width: estDeGarde ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (estDeGarde ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_pharmacy,
                color: estDeGarde ? AppColors.success : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(
                        pharmacie.nom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (estDeGarde) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('DE GARDE',
                            style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    pharmacie.adresse,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pharmacie.horaires != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          pharmacie.horaires!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (pharmacie.telephone != null)
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primary),
                onPressed: () => ContactService.call(context, pharmacie.telephone!),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErreurWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErreurWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Réessayer'),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.surfaceAlt,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../widgets/etat_widgets.dart';
import '../../providers/service_public_provider.dart';
import '../../providers/modules_provider.dart';
import '../../providers/annonce_provider.dart';
import '../../../data/models/service_public_model.dart';

class ServicesListScreen extends ConsumerStatefulWidget {
  const ServicesListScreen({super.key});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Annuaire'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance, size: 18), text: 'Services'),
            Tab(icon: Icon(Icons.apps, size: 18), text: 'Hébergement'),
            Tab(icon: Icon(Icons.store, size: 18), text: 'Commerce'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OngletServicesPublics(),
          _OngletHebergementImmobilier(),
          _OngletCommerceArtisans(),
        ],
      ),
    );
  }
}

// ─── ONGLET 1 : SERVICES PUBLICS ────────────────────────────────────────────

class _OngletServicesPublics extends ConsumerStatefulWidget {
  const _OngletServicesPublics();

  @override
  ConsumerState<_OngletServicesPublics> createState() =>
      _OngletServicesPublicsState();
}

class _OngletServicesPublicsState
    extends ConsumerState<_OngletServicesPublics> {
  final _searchController = TextEditingController();
  String _filtreActif = 'Tous';

  static const _categories = [
    'Tous', 'Santé', 'Sécurité', 'Administration', 'Education', 'Transport',
  ];
  static const _icones = {
    'Santé': Icons.local_hospital,
    'Sécurité': Icons.local_police,
    'Administration': Icons.account_balance,
    'Education': Icons.school,
    'Transport': Icons.directions_bus,
  };
  static const _couleurs = {
    'Santé': AppColors.sante,
    'Sécurité': AppColors.securite,
    'Administration': AppColors.administration,
    'Education': AppColors.education,
    'Transport': AppColors.transport,
  };

  List<ServicePublicModel> _filtrer(List<ServicePublicModel> services) {
    var result = services;
    if (_filtreActif != 'Tous') {
      result = result.where((s) => s.categorie?.nom == _filtreActif).toList();
    }
    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((s) => s.nom.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(servicesPublicsProvider);
    return Column(
      children: [
        // Recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher un service...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      })
                  : null,
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        // Filtres
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final actif = cat == _filtreActif;
              final couleur = _couleurs[cat] ?? AppColors.primary;
              return GestureDetector(
                onTap: () => setState(() => _filtreActif = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: actif ? couleur : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: actif ? couleur : AppColors.border, width: 1),
                  ),
                  child: Row(children: [
                    if (cat != 'Tous') ...[
                      Icon(_icones[cat], size: 13,
                          color: actif ? AppColors.white : couleur),
                      const SizedBox(width: 4),
                    ],
                    Text(cat,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: actif ? FontWeight.w600 : FontWeight.normal,
                            color: actif ? AppColors.white : AppColors.textDark)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Liste
        Expanded(
          child: async.when(
            loading: () => const _ShimmerLoading(),
            error: (e, _) => EtatErreur(onRetry: () => ref.invalidate(servicesPublicsProvider)),
            data: (services) {
              final liste = _filtrer(services);
              if (liste.isEmpty) {
                return const EtatVide(
                  icone: PhosphorIconsRegular.buildings,
                  titre: 'Aucun service trouvé',
                  message: 'Essayez une autre catégorie.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(servicesPublicsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ServiceCard(service: liste[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── ONGLET 2 : HÉBERGEMENT & IMMOBILIER ────────────────────────────────────

class _OngletHebergementImmobilier extends ConsumerWidget {
  const _OngletHebergementImmobilier();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hebergementsAsync = ref.watch(hebergementsProvider);
    final immobilierAsync = ref.watch(immobilierProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            child: TabBar(
              indicatorColor: AppColors.hebergement,
              labelColor: AppColors.hebergement,
              unselectedLabelColor: AppColors.textGrey,
              tabs: const [
                Tab(text: 'Hébergements'),
                Tab(text: 'Immobilier'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HebergementsList(async: hebergementsAsync, onRefresh: () async => ref.invalidate(hebergementsProvider)),
                _ImmobilierList(async: immobilierAsync, onRefresh: () async => ref.invalidate(immobilierProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HebergementsList extends StatelessWidget {
  final AsyncValue<List<dynamic>> async;
  final Future<void> Function() onRefresh;
  const _HebergementsList({required this.async, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const _ShimmerLoading(),
      error: (e, _) => EtatErreur(onRetry: onRefresh),
      data: (liste) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: liste.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final h = liste[i];
            return GestureDetector(
              onTap: () => context.push('/hebergements/${h.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.hebergement.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hotel,
                        color: AppColors.hebergement, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.nom,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          if (h.adresse != null) ...[
                            const SizedBox(height: 4),
                            Text(h.adresse!,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ]),
                  ),
                  if (h.telephone != null)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.hebergement),
                      onPressed: () => ContactService.call(context, h.telephone!),
                    ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.hebergement),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImmobilierList extends StatelessWidget {
  final AsyncValue<List<dynamic>> async;
  final Future<void> Function() onRefresh;
  const _ImmobilierList({required this.async, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const _ShimmerLoading(),
      error: (e, _) => EtatErreur(onRetry: onRefresh),
      data: (liste) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: liste.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final bien = liste[i];
            return GestureDetector(
              onTap: () => context.push('/immobilier/${bien.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.immobilier.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_work,
                        color: AppColors.immobilier, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bien.titre,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          if (bien.adresse != null) ...[
                            const SizedBox(height: 4),
                            Text(bien.adresse!,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ]),
                  ),
                  if (bien.telephone != null)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.immobilier),
                      onPressed: () => ContactService.call(context, bien.telephone!),
                    ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.immobilier),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── ONGLET 3 : COMMERCE & ARTISANS ─────────────────────────────────────────

class _OngletCommerceArtisans extends ConsumerWidget {
  const _OngletCommerceArtisans();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(artisansProvider);
    final annoncesAsync = ref.watch(annoncesProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            child: TabBar(
              indicatorColor: AppColors.artisan,
              labelColor: AppColors.artisan,
              unselectedLabelColor: AppColors.textGrey,
              tabs: const [
                Tab(text: 'Artisans'),
                Tab(text: 'Annonces'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ArtisansList(async: artisansAsync, onRefresh: () async => ref.invalidate(artisansProvider)),
                _AnnoncsList(async: annoncesAsync, onRefresh: () async => ref.invalidate(annoncesProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtisansList extends StatelessWidget {
  final AsyncValue<List<dynamic>> async;
  final Future<void> Function() onRefresh;
  const _ArtisansList({required this.async, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const _ShimmerLoading(),
      error: (e, _) => EtatErreur(onRetry: onRefresh),
      data: (liste) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: liste.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final artisan = liste[i];
            return GestureDetector(
              onTap: () => context.push('/artisans/${artisan.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.artisan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman,
                        color: AppColors.artisan, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(artisan.nom,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          if (artisan.metier.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(artisan.metier,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ]),
                  ),
                  if (artisan.telephone != null)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.artisan),
                      onPressed: () => ContactService.call(context, artisan.telephone!),
                    ),
                  if (artisan.disponible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Dispo',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnnoncsList extends StatelessWidget {
  final AsyncValue<List<dynamic>> async;
  final Future<void> Function() onRefresh;
  const _AnnoncsList({required this.async, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const _ShimmerLoading(),
      error: (e, _) => EtatErreur(onRetry: onRefresh),
      data: (liste) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: liste.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final annonce = liste[i];
            return GestureDetector(
              onTap: () => context.push('/annonces/${annonce.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.annonce.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign,
                        color: AppColors.annonce, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(annonce.titre,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          if (annonce.auteur != null) ...[
                            const SizedBox(height: 4),
                            Text(annonce.auteur!,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ]),
                  ),
                  if (annonce.telephone != null)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.annonce),
                      onPressed: () => ContactService.call(context, annonce.telephone!),
                    ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.annonce),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServicePublicModel service;
  const _ServiceCard({required this.service});

  static const _icones = {
    'Santé': Icons.local_hospital,
    'Sécurité': Icons.local_police,
    'Administration': Icons.account_balance,
    'Education': Icons.school,
    'Transport': Icons.directions_bus,
  };
  static const _couleurs = {
    'Santé': AppColors.sante,
    'Sécurité': AppColors.securite,
    'Administration': AppColors.administration,
    'Education': AppColors.education,
    'Transport': AppColors.transport,
  };

  @override
  Widget build(BuildContext context) {
    final nomCat = service.categorie?.nom;
    final couleur = _couleurs[nomCat] ?? AppColors.primary;
    final icone = _icones[nomCat] ?? Icons.place;

    return GestureDetector(
      onTap: () => context.push('/services/${service.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: couleur, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.nom,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              if (service.adresse != null) ...[
                const SizedBox(height: 4),
                Text(service.adresse!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
              if (nomCat != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(nomCat,
                      style: TextStyle(
                          fontSize: 11,
                          color: couleur,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ]),
          ),
          if (service.telephone != null)
            IconButton(
              icon: Icon(Icons.phone, color: couleur),
              onPressed: () => ContactService.call(context, service.telephone!),
            ),
        ]),
      ),
    );
  }
}

class _ShimmerLoading extends StatelessWidget {
  final double height;
  final int count;
  const _ShimmerLoading() : count = 5, height = 80;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

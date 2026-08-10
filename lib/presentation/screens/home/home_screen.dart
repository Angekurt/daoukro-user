import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/annonce_provider.dart';
import '../../providers/connexion_provider.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/meteo_widget.dart';
import '../../../data/models/annonce_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _nbNotifs = 0;

  @override
  void initState() {
    super.initState();
    _nbNotifs = NotificationService.instance.getNombreNonLues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daoukro Digital',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Votre ville en un clic',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.8))),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await context.push('/notifications');
                      setState(() {
                        _nbNotifs = NotificationService.instance.getNombreNonLues();
                      });
                    },
                  ),
                  if (_nbNotifs > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _nbNotifs > 9 ? '9+' : '$_nbNotifs',
                            style: const TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  tooltip: 'À propos',
                  onPressed: () => context.push('/about')),
            ],
          ),
          const SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                _BandeauConnexion(),   // bandeau cache offline
                MeteoWidget(),
                _AccesRapide(),
                _BoutonSignalement(),
                _SectionActualites(),
                _SectionAnnonces(),
                _SectionHebergements(),
                _SectionArtisans(),
                _BandeauUrgences(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BOUTON SIGNALEMENT ─────────────────────────────────────────────────────

class _BoutonSignalement extends StatelessWidget {
  const _BoutonSignalement();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/signalement'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mairie,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.report_problem_outlined, color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Signaler un problème', style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Voirie, éclairage, déchets...', style: TextStyle(color: AppColors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: AppColors.white70, size: 16),
        ]),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(begin: -0.05, end: 0);
  }
}

// ─── ACCÈS RAPIDE ────────────────────────────────────────────────────────────

class _AccesRapide extends StatelessWidget {
  const _AccesRapide();

  static const _items = [
    _AccesItem(Icons.map_outlined, 'Carte', '/carte', AppColors.primaryDark),
    _AccesItem(Icons.local_pharmacy_outlined, 'Pharmacies', '/pharmacies', AppColors.sante),
    _AccesItem(Icons.account_balance_outlined, 'Services', '/services', AppColors.mairie),
    _AccesItem(Icons.hotel_outlined, 'Hôtels', '/hebergements', AppColors.hebergement),
    _AccesItem(Icons.home_work_outlined, 'Immobilier', '/immobilier', AppColors.immobilier),
    _AccesItem(Icons.handyman_outlined, 'Artisans', '/artisans', AppColors.artisan),
    _AccesItem(Icons.campaign_outlined, 'Annonces', '/annonces', AppColors.annonce),
    _AccesItem(Icons.emergency_outlined, 'Urgences', '/urgences', AppColors.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accès rapide',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: _items.map((item) => _AccesRapideItem(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AccesItem {
  final IconData icone;
  final String label;
  final String route;
  final Color couleur;
  const _AccesItem(this.icone, this.label, this.route, this.couleur);
}

class _AccesRapideItem extends StatefulWidget {
  final _AccesItem item;
  const _AccesRapideItem({required this.item});

  @override
  State<_AccesRapideItem> createState() => _AccesRapideItemState();
}

class _AccesRapideItemState extends State<_AccesRapideItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.88, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); context.go(widget.item.route); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.item.couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.item.icone, color: widget.item.couleur, size: 28),
            ),
            const SizedBox(height: 6),
            Text(widget.item.label,
                style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION ACTUALITÉS ──────────────────────────────────────────────────────

class _SectionActualites extends ConsumerWidget {
  const _SectionActualites();

  static const _couleurs = {
    'alerte': AppColors.sante,
    'mairie': AppColors.mairie,
    'sante': AppColors.success,
    'info': AppColors.hebergement,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(actualitesProvider);
    return Column(
      children: [
        const SizedBox(height: 12),
        _EnteteSection(
          titre: 'Infos locales',
          icone: Icons.newspaper_outlined,
          onVoirTout: () => context.go('/actualites'),
        ),
        async.when(
          loading: () => const _ShimmerHorizontal(height: 100, width: 280),
          error: (_, _) => const SizedBox.shrink(),
          data: (actualites) => SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: actualites.take(5).length,
              itemBuilder: (ctx, i) {
                final a = actualites[i];
                final couleur = _couleurs[a.categorie] ?? AppColors.primary;
                return GestureDetector(
                  onTap: () => context.go('/actualites'),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: couleur.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (a.categorie ?? 'info').toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                color: couleur,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(a.titre,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SECTION ANNONCES ────────────────────────────────────────────────────────

class _SectionAnnonces extends ConsumerWidget {
  const _SectionAnnonces();

  static const _config = {
    TypeAnnonce.evenement: (couleur: AppColors.evenement, icone: Icons.event, label: 'Événement'),
    TypeAnnonce.emploi: (couleur: AppColors.emploi, icone: Icons.work_outline, label: 'Emploi'),
    TypeAnnonce.restaurant: (couleur: AppColors.hebergement, icone: Icons.restaurant, label: 'Restaurant'),
    TypeAnnonce.pub: (couleur: AppColors.pub, icone: Icons.local_bar_outlined, label: 'Sortie'),
    TypeAnnonce.annonce: (couleur: AppColors.artisan, icone: Icons.campaign_outlined, label: 'Annonce'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(annoncesProvider);
    return Column(
      children: [
        const SizedBox(height: 12),
        _EnteteSection(
          titre: 'Annonces & Événements',
          icone: Icons.campaign_outlined,
          onVoirTout: () => context.go('/annonces'),
        ),
        async.when(
          loading: () => const _ShimmerHorizontal(height: 190, width: 200),
          error: (_, _) => const SizedBox.shrink(),
          data: (annonces) => SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: annonces.take(6).length,
              itemBuilder: (ctx, i) {
                final a = annonces[i];
                final cfg = _config[a.type]!;
                return GestureDetector(
                  onTap: () => context.go('/annonces'),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: cfg.couleur.withValues(alpha: 0.12),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Center(
                              child: Icon(cfg.icone,
                                  color: cfg.couleur, size: 40)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cfg.couleur.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(cfg.label,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: cfg.couleur,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 6),
                              Text(a.titre,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              if (a.lieu != null) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.location_on,
                                      size: 11, color: AppColors.textGrey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(a.lieu!,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textGrey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SECTION HÉBERGEMENTS ────────────────────────────────────────────────────

class _SectionHebergements extends ConsumerWidget {
  const _SectionHebergements();

  String _formatPrix(double? min, double? max) {
    if (min == null) return 'Prix sur demande';
    final minStr = '${(min / 1000).toStringAsFixed(0)}k';
    if (max == null) return 'À partir de $minStr FCFA';
    return '$minStr - ${(max / 1000).toStringAsFixed(0)}k FCFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hebergementsProvider);
    return Column(
      children: [
        const SizedBox(height: 12),
        _EnteteSection(
          titre: 'Hébergements',
          icone: Icons.hotel_outlined,
          onVoirTout: () => context.go('/hebergements'),
        ),
        async.when(
          loading: () => const _ShimmerHorizontal(height: 170, width: 220),
          error: (_, _) => const SizedBox.shrink(),
          data: (hebergements) => SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: hebergements.take(4).length,
              itemBuilder: (ctx, i) {
                final h = hebergements[i];
                return GestureDetector(
                  onTap: () => context.go('/hebergements'),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.hebergement.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Stack(children: [
                            const Center(
                                child: Icon(Icons.hotel,
                                    color: AppColors.hebergement, size: 40)),
                            if (h.note != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 12, color: AppColors.secondary),
                                        const SizedBox(width: 2),
                                        Text(h.note!.toStringAsFixed(1),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                ),
                              ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.nom,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(_formatPrix(h.prixMin, h.prixMax),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.hebergement,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SECTION ARTISANS ────────────────────────────────────────────────────────

class _SectionArtisans extends ConsumerWidget {
  const _SectionArtisans();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(artisansProvider);
    return Column(
      children: [
        const SizedBox(height: 12),
        _EnteteSection(
          titre: 'Artisans & Prestataires',
          icone: Icons.handyman_outlined,
          onVoirTout: () => context.go('/artisans'),
        ),
        async.when(
          loading: () => const _ShimmerListe(),
          error: (_, _) => const SizedBox.shrink(),
          data: (artisans) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artisans.take(4).length,
            itemBuilder: (ctx, i) {
              final a = artisans[i];
              return GestureDetector(
                onTap: () => context.go('/artisans'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
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
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.handyman,
                          color: AppColors.artisan, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(a.nom,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: a.disponible
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.shimmerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                a.disponible ? 'Disponible' : 'Occupé',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: a.disponible
                                        ? AppColors.success
                                        : AppColors.textGrey,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 3),
                          Text(a.metier,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    if (a.note != null) ...[
                      const SizedBox(width: 8),
                      Row(children: [
                        const Icon(Icons.star, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 2),
                        Text(a.note!.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── BANDEAU URGENCES ────────────────────────────────────────────────────────

class _BandeauUrgences extends StatelessWidget {
  const _BandeauUrgences();

  static const _urgences = [
    (nom: 'SAMU', tel: '185', icone: Icons.local_hospital),
    (nom: 'Pompiers', tel: '180', icone: Icons.local_fire_department),
    (nom: 'Police', tel: '111', icone: Icons.local_police),
    (nom: 'Gendarmerie', tel: '170', icone: Icons.security),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emergency, color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            const Text("Numéros d'urgence",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/urgences'),
              child: const Text('Voir tout',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _urgences
                .map((u) => _UrgenceBtn(nom: u.nom, tel: u.tel, icone: u.icone))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _UrgenceBtn extends StatelessWidget {
  final String nom;
  final String tel;
  final IconData icone;
  const _UrgenceBtn({required this.nom, required this.tel, required this.icone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ContactService.call(context, tel),
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icone, color: AppColors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(nom,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500)),
        Text(tel,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
      ]),
    );
  }
}

// ─── WIDGETS UTILITAIRES ─────────────────────────────────────────────────────

class _EnteteSection extends StatelessWidget {
  final String titre;
  final IconData icone;
  final VoidCallback onVoirTout;
  const _EnteteSection(
      {required this.titre, required this.icone, required this.onVoirTout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [
        Icon(icone, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(titre,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        const Spacer(),
        GestureDetector(
          onTap: onVoirTout,
          child: const Text('Voir tout',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _ShimmerHorizontal extends StatelessWidget {
  final double height;
  final double width;
  const _ShimmerHorizontal({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (_, _) => Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHigh,
          child: Container(
            width: width,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerListe extends StatelessWidget {
  const _ShimmerListe();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

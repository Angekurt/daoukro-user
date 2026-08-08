import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/avis_section.dart';

class HebergementDetailScreen extends ConsumerWidget {
  final int id;
  const HebergementDetailScreen({super.key, required this.id});

  static const _couleur = AppColors.hebergement;

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

  Future<void> _itineraire(BuildContext context, double lat, double lng, String nom) async {
    context.push('/itineraire', extra: {'lat': lat, 'lng': lng, 'nom': nom});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hebergementsProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Détail'), backgroundColor: _couleur, foregroundColor: AppColors.white),
        body: EtatErreur(onRetry: () => ref.invalidate(hebergementsProvider)),
      ),
      data: (liste) {
        final h = liste.firstWhere((e) => e.id == id, orElse: () => liste.first);
        final aDesPhotos = h.photoUrl != null || h.photos.isNotEmpty;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _couleur,
                foregroundColor: AppColors.white,
                leading: BoutonRetour(blanc: true),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(h.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  background: aDesPhotos
                      ? PhotoGallery(photoCouverture: h.photoUrl, photos: h.photos, height: 220)
                      : Container(
                          color: _couleur.withValues(alpha: 0.15),
                          child: const Center(child: Icon(Icons.hotel, size: 80, color: _couleur)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(children: [
                        _Badge(label: _labelType(h.type), couleur: _couleur),
                        if (h.note != null) ...[
                          const SizedBox(width: 8),
                          _Badge(
                            label: '★ ${h.note!.toStringAsFixed(1)}${h.nbAvis != null ? ' (${h.nbAvis} avis)' : ''}',
                            couleur: AppColors.secondary,
                          ),
                        ],
                      ]),
                      const SizedBox(height: 16),
                      // Prix
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _couleur.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.payments_outlined, color: _couleur),
                          const SizedBox(width: 10),
                          Text(_formatPrix(h.prixMin, h.prixMax),
                              style: const TextStyle(fontSize: 15, color: _couleur, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      if (h.adresse != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(icone: Icons.location_on_outlined, texte: h.adresse!),
                      ],
                      if (h.description != null) ...[
                        const SizedBox(height: 20),
                        const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(h.description!, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
                      ],
                      const SizedBox(height: 28),
                      // Boutons d'action
                      ContactActionsRow(
                        nom: h.nom,
                        telephone: h.telephone,
                        messageWhatsapp: 'Bonjour, je vous contacte via l\'application Daoukro Digital '
                            'concernant : ${h.nom}.',
                        onItineraire: (h.latitude != null && h.longitude != null)
                            ? () => _itineraire(context, h.latitude!, h.longitude!, h.nom)
                            : null,
                      ),
                      const SizedBox(height: 28),
                      AvisSection(entityType: 'hebergement', entityId: h.id, nomEntite: h.nom),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color couleur;
  const _Badge({required this.label, required this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _InfoRow({required this.icone, required this.texte});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icone, size: 16, color: AppColors.textGrey),
    const SizedBox(width: 8),
    Expanded(child: Text(texte, style: const TextStyle(fontSize: 13, color: AppColors.textGrey))),
  ]);
}

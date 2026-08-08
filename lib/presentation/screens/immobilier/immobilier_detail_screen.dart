import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/photo_gallery.dart';

class ImmobilierDetailScreen extends ConsumerWidget {
  final int id;
  const ImmobilierDetailScreen({super.key, required this.id});

  static const _couleur = AppColors.immobilier;

  String _formatPrix(double prix) =>
      '${NumberFormat('#,###', 'fr_FR').format(prix.toInt())} FCFA';

  IconData _iconeType(String type) {
    switch (type) {
      case 'terrain': return Icons.landscape;
      case 'appartement': return Icons.apartment;
      case 'villa': return Icons.villa;
      default: return Icons.home;
    }
  }

  String _labelType(String type) {
    switch (type) {
      case 'maison': return 'Maison';
      case 'terrain': return 'Terrain';
      case 'appartement': return 'Appartement';
      case 'villa': return 'Villa';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(immobilierProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Détail'), backgroundColor: _couleur, foregroundColor: AppColors.white),
        body: EtatErreur(onRetry: () => ref.invalidate(immobilierProvider)),
      ),
      data: (liste) {
        final bien = liste.firstWhere((e) => e.id == id, orElse: () => liste.first);
        final isVente = bien.typeOffre == 'vente';
        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _couleur,
                foregroundColor: AppColors.white,
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(bien.titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  background: Container(
                    color: _couleur.withValues(alpha: 0.1),
                    child: Center(child: Icon(_iconeType(bien.typeBien), size: 80, color: _couleur)),
                  ),
                ),
              ),
              if (bien.photoUrl != null || bien.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: PhotoGallery(
                    photoCouverture: bien.photoUrl,
                    photos: bien.photos,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _Badge(
                          label: isVente ? 'Vente' : 'Location',
                          couleur: isVente ? AppColors.success : _couleur,
                        ),
                        const SizedBox(width: 8),
                        _Badge(label: _labelType(bien.typeBien), couleur: _couleur),
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
                          Text(
                            '${_formatPrix(bien.prix)}${isVente ? '' : '/mois'}',
                            style: const TextStyle(fontSize: 16, color: _couleur, fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      // Caractéristiques
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        if (bien.surface != null)
                          _CaracChip(icone: Icons.square_foot, label: bien.surface!),
                        if (bien.nbChambres != null)
                          _CaracChip(icone: Icons.bed, label: '${bien.nbChambres} chambre${bien.nbChambres! > 1 ? 's' : ''}'),
                        if (bien.quartier != null)
                          _CaracChip(icone: Icons.location_city, label: bien.quartier!),
                      ]),
                      if (bien.adresse != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(icone: Icons.location_on_outlined, texte: bien.adresse!),
                      ],
                      if (bien.description != null) ...[
                        const SizedBox(height: 20),
                        const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(bien.description!, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
                      ],
                      const SizedBox(height: 28),
                      ContactActionsRow(
                        nom: bien.titre,
                        telephone: bien.telephone,
                        messageWhatsapp: 'Bonjour, je vous contacte via l\'application Daoukro Digital '
                            'concernant : ${bien.titre}.',
                        onItineraire: (bien.latitude != null && bien.longitude != null)
                            ? () => context.push('/itineraire', extra: {'lat': bien.latitude!, 'lng': bien.longitude!, 'nom': bien.titre})
                            : null,
                      ),
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

class _CaracChip extends StatelessWidget {
  final IconData icone;
  final String label;
  const _CaracChip({required this.icone, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icone, size: 14, color: AppColors.textGrey),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
    ]),
  );
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

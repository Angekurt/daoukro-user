import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/avis_section.dart';

class ArtisanDetailScreen extends ConsumerWidget {
  final int id;
  const ArtisanDetailScreen({super.key, required this.id});

  static const _couleur = AppColors.artisanBrun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(artisansProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Détail'), backgroundColor: _couleur, foregroundColor: AppColors.white),
        body: Center(child: Text(e.toString())),
      ),
      data: (liste) {
        final idx = liste.indexWhere((e) => e.id == id);
        if (idx == -1) return Scaffold(appBar: AppBar(title: const Text('Artisan'), backgroundColor: _couleur, foregroundColor: AppColors.white, leading: const BoutonRetour(blanc: true)), body: const Center(child: Text('Artisan introuvable')));
        final a = liste[idx];
        final aDesPhotos = a.photoUrl != null || a.photos.isNotEmpty;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _couleur,
                foregroundColor: AppColors.white,
                leading: const BoutonRetour(blanc: true),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(a.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  background: aDesPhotos
                      ? PhotoGallery(photoCouverture: a.photoUrl, photos: a.photos, height: 200)
                      : Container(
                          color: _couleur.withValues(alpha: 0.12),
                          child: const Center(child: Icon(Icons.handyman, size: 80, color: _couleur)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _Badge(label: a.metier, couleur: _couleur),
                        const SizedBox(width: 8),
                        _Badge(
                          label: a.disponible ? 'Disponible' : 'Indisponible',
                          couleur: a.disponible ? AppColors.success : AppColors.textMuted,
                        ),
                        if (a.note != null) ...[
                          const SizedBox(width: 8),
                          _Badge(
                            label: '★ ${a.note!.toStringAsFixed(1)}${a.nbAvis != null ? ' (${a.nbAvis})' : ''}',
                            couleur: AppColors.secondary,
                          ),
                        ],
                      ]),
                      if (a.adresse != null) ...[
                        const SizedBox(height: 14),
                        _InfoRow(icone: Icons.location_on_outlined, texte: a.adresse!),
                      ],
                      if (a.description != null) ...[
                        const SizedBox(height: 20),
                        const Text('À propos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(a.description!, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
                      ],
                      const SizedBox(height: 28),
                      if (a.telephone != null)
                        _BoutonAction(icone: Icons.phone, label: 'Appeler', couleur: _couleur, onTap: () => ContactService.call(context, a.telephone!)),
                      if (a.whatsapp != null) ...[
                        const SizedBox(height: 12),
                        _BoutonAction(
                          icone: Icons.chat,
                          label: 'WhatsApp',
                          couleur: AppColors.whatsapp,
                          onTap: () => ContactService.whatsapp(
                            context,
                            a.whatsapp!,
                            message: 'Bonjour, je vous contacte via l\'application Daoukro Digital '
                                'concernant : ${a.metier}.',
                          ),
                        ),
                      ],
                      if (a.latitude != null && a.longitude != null) ...[
                        const SizedBox(height: 12),
                        _BoutonAction(
                          icone: Icons.directions,
                          label: 'Itinéraire',
                          couleur: AppColors.primary,
                          onTap: () => context.push('/itineraire', extra: {'lat': a.latitude!, 'lng': a.longitude!, 'nom': a.nom}),
                        ),
                      ],
                      const SizedBox(height: 28),
                      AvisSection(entityType: 'artisan', entityId: a.id, nomEntite: a.nom),
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

class _BoutonAction extends StatelessWidget {
  final IconData icone;
  final String label;
  final Color couleur;
  final VoidCallback onTap;
  const _BoutonAction({required this.icone, required this.label, required this.couleur, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icone),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

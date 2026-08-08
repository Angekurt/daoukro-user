import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/service_public_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/mini_map_card.dart';
import '../../widgets/photo_gallery.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final int id;
  const ServiceDetailScreen({super.key, required this.id});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(servicePublicDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: serviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Column(children: [
          AppBar(title: const Text('Service'), backgroundColor: AppColors.primary, foregroundColor: AppColors.white, leading: const BoutonRetour(blanc: true)),
          Expanded(child: EtatErreur(onRetry: () => ref.invalidate(servicePublicDetailProvider(id)))),
        ]),
        data: (service) {
          final nomCat = service.categorie?.nom;
          final couleur = _couleurs[nomCat] ?? AppColors.primary;
          final icone = _icones[nomCat] ?? Icons.place;
          final hasCoords = service.latitude != null && service.longitude != null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: couleur,
                foregroundColor: AppColors.white,
                leading: const BoutonRetour(blanc: true),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(service.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  background: Container(
                    color: couleur,
                    child: Center(child: Icon(icone, size: 80, color: AppColors.white.withValues(alpha: 0.3))),
                  ),
                ),
              ),
              if (service.photoUrl != null || service.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: PhotoGallery(
                    photoCouverture: service.photoUrl,
                    photos: service.photos,
                  ),
                ),
              if (hasCoords)
                SliverToBoxAdapter(
                  child: MiniMapCard(
                    latitude: service.latitude!,
                    longitude: service.longitude!,
                    icone: icone,
                    couleur: couleur,
                    onTap: () => context.push('/itineraire', extra: {'lat': service.latitude!, 'lng': service.longitude!, 'nom': service.nom}),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nomCat != null) _Badge(label: nomCat, couleur: couleur, icone: icone),
                      if (nomCat != null) const SizedBox(height: 16),
                      if (service.description != null) ...[
                        Text(service.description!, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.6)),
                        const SizedBox(height: 20),
                      ],
                      if (service.adresse != null) _InfoTile(icone: Icons.location_on, label: 'Adresse', valeur: service.adresse!, couleur: couleur),
                      if (service.telephone != null) _InfoTile(icone: Icons.phone, label: 'Téléphone', valeur: service.telephone!, couleur: couleur),
                      if (service.email != null) _InfoTile(icone: Icons.email, label: 'Email', valeur: service.email!, couleur: couleur),
                      if (service.horaires != null) _InfoTile(icone: Icons.access_time, label: 'Horaires', valeur: service.horaires!, couleur: couleur),
                      const SizedBox(height: 24),
                      ContactActionsRow(
                        nom: service.nom,
                        telephone: service.telephone,
                        messageWhatsapp: 'Bonjour, je vous contacte via l\'application Daoukro Digital '
                            'concernant : ${service.nom}.',
                        onItineraire: hasCoords
                            ? () => context.push('/itineraire', extra: {'lat': service.latitude!, 'lng': service.longitude!, 'nom': service.nom})
                            : null,
                      ),
                      if (service.email != null) ...[
                        const SizedBox(height: 12),
                        ActionButton(icone: Icons.email, label: 'Email', couleur: couleur, outlined: true, onTap: () => ContactService.email(context, service.email!)),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color couleur; final IconData icone;
  const _Badge({required this.label, required this.couleur, required this.icone});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icone, size: 13, color: couleur),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: couleur, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icone; final String label; final String valeur; final Color couleur;
  const _InfoTile({required this.icone, required this.label, required this.valeur, required this.couleur});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icone, color: couleur, size: 19)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        const SizedBox(height: 2),
        Text(valeur, style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
      ])),
    ]),
  );
}

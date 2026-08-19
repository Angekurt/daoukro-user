import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/pharmacie_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/mini_map_card.dart';
import '../../widgets/photo_gallery.dart';
import '../../../data/models/garde_model.dart';
import '../../../data/models/pharmacie_model.dart';

class PharmacieDetailScreen extends ConsumerWidget {
  final int id;
  const PharmacieDetailScreen({super.key, required this.id});

  void _ouvrirItineraire(BuildContext context, double lat, double lng, String nom) {
    context.push('/itineraire', extra: {'lat': lat, 'lng': lng, 'nom': nom});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacieAsync = ref.watch(pharmacieDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: pharmacieAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Column(
          children: [
            AppBar(
              title: const Text('Pharmacie'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              leading: const BoutonRetour(blanc: true),
            ),
            EtatErreur(onRetry: () => ref.invalidate(pharmacieDetailProvider(id))),
          ],
        ),
        data: (pharmacie) {
          final hasCoords = pharmacie.latitude != null && pharmacie.longitude != null;
          final gardesAsync = ref.watch(gardesActivesProvider);
          final estDeGarde = gardesAsync.maybeWhen(
            data: (gardes) => gardes.any((g) => g.pharmacie.id == pharmacie.id),
            orElse: () => false,
          );
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                leading: const BoutonRetour(blanc: true),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(pharmacie.nom, style: const TextStyle(fontSize: 14)),
                  background: Container(
                    color: AppColors.primary,
                    child: Center(child: Icon(Icons.local_pharmacy, size: 80, color: AppColors.white.withValues(alpha: 0.3))),
                  ),
                ),
              ),
              if (pharmacie.photoUrl != null || pharmacie.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: PhotoGallery(
                    photoCouverture: pharmacie.photoUrl,
                    photos: pharmacie.photos,
                  ),
                ),
              if (hasCoords)
                SliverToBoxAdapter(
                  child: MiniMapCard(
                    latitude: pharmacie.latitude!,
                    longitude: pharmacie.longitude!,
                    icone: Icons.local_pharmacy,
                    couleur: AppColors.primary,
                    onTap: () => _ouvrirItineraire(context, pharmacie.latitude!, pharmacie.longitude!, pharmacie.nom),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (estDeGarde) ...[
                        // Période de garde affichée immédiatement à côté du badge
                        gardesAsync.maybeWhen(
                          data: (gardes) {
                            final garde = gardes.where((g) => g.pharmacie.id == pharmacie.id).firstOrNull;
                            if (garde == null) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.circle, size: 6, color: AppColors.white),
                                      SizedBox(width: 6),
                                      Text('DE GARDE', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    ]),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Du ${DateFormat('dd/MM').format(garde.dateDebut)} au ${DateFormat('dd/MM').format(garde.dateFin)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                                  ),
                                ]),
                                const SizedBox(height: 14),
                              ],
                            );
                          },
                          orElse: () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.circle, size: 6, color: AppColors.white),
                                  SizedBox(width: 6),
                                  Text('DE GARDE', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ]),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ],
                      _InfoTile(icone: Icons.location_on, label: 'Adresse', valeur: pharmacie.adresse),
                      if (pharmacie.telephone != null)
                        _InfoTile(icone: Icons.phone, label: 'Téléphone', valeur: pharmacie.telephone!),
                      if (pharmacie.horaires != null)
                        _InfoTile(icone: Icons.access_time, label: 'Horaires', valeur: pharmacie.horaires!),
                      if (pharmacie.ville != null)
                        _InfoTile(icone: Icons.location_city, label: 'Ville', valeur: pharmacie.ville!.nom),
                      const SizedBox(height: 24),
                      ContactActionsRow(
                        nom: pharmacie.nom,
                        telephone: pharmacie.telephone,
                        messageWhatsapp: 'Bonjour, je vous contacte via l\'application Daoukro Digital '
                            'concernant : ${pharmacie.nom}.',
                        onItineraire: hasCoords
                            ? () => _ouvrirItineraire(context, pharmacie.latitude!, pharmacie.longitude!, pharmacie.nom)
                            : null,
                      ),
                      const SizedBox(height: 28),
                      // Pharmacie de garde
                      _PharmacieDeGardeSection(
                        pharmacieActuelle: pharmacie,
                        estDeGarde: estDeGarde,
                        gardesAsync: gardesAsync,
                      ),
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

class _PharmacieDeGardeSection extends StatelessWidget {
  final PharmacieModel pharmacieActuelle;
  final bool estDeGarde;
  final AsyncValue<List<GardeModel>> gardesAsync;

  const _PharmacieDeGardeSection({
    required this.pharmacieActuelle,
    required this.estDeGarde,
    required this.gardesAsync,
  });

  String _periode(GardeModel g) =>
      'Du ${DateFormat('dd/MM').format(g.dateDebut)} au ${DateFormat('dd/MM').format(g.dateFin)}';

  @override
  Widget build(BuildContext context) {
    return gardesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
      ),
      error: (_, _) => _ErrorOuVide(
        titre: 'Pharmacies de garde indisponibles',
        message: "Impossible de charger les pharmacies de garde pour le moment.",
      ),
      data: (gardes) {
        // Les autres pharmacies de garde (hors celle affichée ici)
        final autres = gardes.where((g) => g.pharmacie.id != pharmacieActuelle.id).toList();

        if (gardes.isEmpty) {
          return _ErrorOuVide(
            titre: 'Aucune garde enregistrée pour aujourd\'hui',
            message: "Le planning de garde n'a pas encore été renseigné.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  estDeGarde ? 'Autre(s) pharmacie(s) de garde' : 'Pharmacie(s) de garde',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ]),
            ),
            if (estDeGarde)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _periode(gardes.firstWhere((g) => g.pharmacie.id == pharmacieActuelle.id)),
                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Cette pharmacie n'est pas de garde actuellement.",
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ),
            if (autres.isEmpty && !estDeGarde)
              const SizedBox.shrink()
            else
              ...autres.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/pharmacies/${g.pharmacie.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(g.pharmacie.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          Text(g.pharmacie.adresse, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          Text(_periode(g), style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
                        ])),
                        if (g.pharmacie.telephone != null)
                          IconButton(
                            icon: const Icon(Icons.phone, color: AppColors.primary),
                            onPressed: () => ContactService.call(context, g.pharmacie.telephone!),
                          ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ]),
                    ),
                  ),
                ),
              )),
          ],
        );
      },
    );
  }
}

/// État vide/erreur illustré, avec une action de signalement au support —
/// jamais un simple SizedBox vide.
class _ErrorOuVide extends StatelessWidget {
  final String titre;
  final String message;
  const _ErrorOuVide({required this.titre, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Icon(Icons.local_pharmacy_outlined, size: 36, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: () => ContactService.support(context, contexte: 'Aucune pharmacie de garde affichée'),
                icon: const Icon(Icons.campaign_outlined, size: 18),
                label: const Text('Signaler au support'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  const _InfoTile({required this.icone, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icone, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 2),
                Text(valeur, style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

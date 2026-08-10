import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/contact_service.dart';
import '../../providers/annonce_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/avis_section.dart';
import '../../../data/models/annonce_model.dart';

class AnnoncDetailScreen extends ConsumerWidget {
  final int id;
  const AnnoncDetailScreen({super.key, required this.id});

  Color _couleurType(TypeAnnonce type) {
    switch (type) {
      case TypeAnnonce.evenement: return AppColors.evenement;
      case TypeAnnonce.emploi: return AppColors.emploi;
      case TypeAnnonce.restaurant: return AppColors.restaurant;
      case TypeAnnonce.pub: return AppColors.pub;
      case TypeAnnonce.annonce: return AppColors.secondary;
    }
  }

  String _labelType(TypeAnnonce type) {
    switch (type) {
      case TypeAnnonce.evenement: return 'Événement';
      case TypeAnnonce.emploi: return 'Emploi';
      case TypeAnnonce.restaurant: return 'Restaurant';
      case TypeAnnonce.pub: return 'Publicité';
      case TypeAnnonce.annonce: return 'Annonce';
    }
  }

  IconData _iconeType(TypeAnnonce type) {
    switch (type) {
      case TypeAnnonce.evenement: return Icons.event;
      case TypeAnnonce.emploi: return Icons.work_outline;
      case TypeAnnonce.restaurant: return Icons.restaurant;
      case TypeAnnonce.pub: return Icons.local_bar_outlined;
      case TypeAnnonce.annonce: return Icons.announcement_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(annoncesProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Détail'), backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
        body: EtatErreur(onRetry: () => ref.invalidate(annoncesProvider)),
      ),
      data: (liste) {
        final idx = liste.indexWhere((e) => e.id == id);
        if (idx == -1) return Scaffold(appBar: AppBar(title: const Text('Annonce'), backgroundColor: AppColors.primary, foregroundColor: AppColors.white), body: const Center(child: Text('Annonce introuvable')));
        final a = liste[idx];
        final couleur = _couleurType(a.type);
        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: couleur,
                foregroundColor: AppColors.white,
                leading: const BoutonRetour(blanc: true),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(a.titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  background: Container(
                    color: couleur.withValues(alpha: 0.15),
                    child: Center(child: Icon(_iconeType(a.type), size: 80, color: couleur)),
                  ),
                ),
              ),
              if (a.photoUrl != null || a.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: PhotoGallery(
                    photoCouverture: a.photoUrl,
                    photos: a.photos,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Badge(label: _labelType(a.type), couleur: couleur),
                      const SizedBox(height: 16),
                      // Infos clés
                      if (a.lieu != null) _InfoRow(icone: Icons.location_on_outlined, texte: a.lieu!),
                      if (a.dateDebut != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icone: Icons.calendar_today_outlined,
                          texte: a.dateFin != null ? 'Du ${a.dateDebut} au ${a.dateFin}' : a.dateDebut!,
                        ),
                      ],
                      if (a.auteur != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(icone: Icons.person_outline, texte: a.auteur!),
                      ],
                      const SizedBox(height: 20),
                      const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text(a.description, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
                      const SizedBox(height: 28),
                      // Actions
                      if (a.telephone != null)
                        _BoutonAction(
                          icone: Icons.phone,
                          label: 'Appeler',
                          couleur: couleur,
                          onTap: () => ContactService.call(context, a.telephone!),
                        ),
                      if (a.lien != null) ...[
                        const SizedBox(height: 12),
                        _BoutonAction(
                          icone: Icons.open_in_new,
                          label: 'Voir plus',
                          couleur: AppColors.primary,
                          onTap: () => ContactService.web(context, a.lien!),
                        ),
                      ],
                      const SizedBox(height: 28),
                      // Bouton Intéressé pour les offres d'emploi
                      if (a.type == TypeAnnonce.emploi)
                        _BoutonInteresse(annonce: a),
                      const SizedBox(height: 28),
                      AvisSection(
                        entityType: 'annonce',
                        entityId: a.id,
                        nomEntite: a.titre,
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

// ── Bouton Intéressé (offres d'emploi uniquement) ─────────────────────────────

class _BoutonInteresse extends ConsumerStatefulWidget {
  final AnnonceModel annonce;
  const _BoutonInteresse({required this.annonce});

  @override
  ConsumerState<_BoutonInteresse> createState() => _BoutonInteresseState();
}

class _BoutonInteresseState extends ConsumerState<_BoutonInteresse> {
  late bool _interesse;
  late int _nb;
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    _interesse = widget.annonce.dejaInteresse;
    _nb        = widget.annonce.nbInterets;
  }

  Future<void> _toggle() async {
    setState(() => _enCours = true);
    try {
      final dio = ApiClient.getInstance();
      if (_interesse) {
        final res = await dio.delete('/annonces/${widget.annonce.id}/interet');
        setState(() {
          _interesse = false;
          _nb = res.data['total_interets'] ?? (_nb > 0 ? _nb - 1 : 0);
        });
      } else {
        final res = await dio.post('/annonces/${widget.annonce.id}/interet');
        setState(() {
          _interesse = true;
          _nb = res.data['total_interets'] ?? (_nb + 1);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('401')
                ? 'Connectez-vous pour marquer votre intérêt.'
                : "Impossible d'enregistrer votre intérêt."),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _enCours ? null : _toggle,
            icon: _enCours
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                : Icon(_interesse ? Icons.check_circle_rounded : Icons.thumb_up_outlined),
            label: Text(_interesse ? 'Intérêt enregistré' : 'Je suis intéressé(e)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _interesse ? AppColors.success : AppColors.emploi,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_nb > 0) ...[
          const SizedBox(height: 8),
          Text(
            '$_nb personne${_nb > 1 ? 's' : ''} ${_nb > 1 ? 'sont intéressées' : 'est intéressée'}',
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ],
    );
  }
}

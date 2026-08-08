import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/etat_widgets.dart';
import '../../widgets/photo_gallery.dart';

class ActualiteDetailScreen extends ConsumerWidget {
  final int id;
  const ActualiteDetailScreen({super.key, required this.id});

  Color _couleurCat(String? cat) {
    switch (cat) {
      case 'mairie': return AppColors.mairie;
      case 'alerte': return AppColors.dangerVif;
      case 'culture': return AppColors.culture;
      default: return AppColors.primary;
    }
  }

  String _labelCat(String? cat) {
    switch (cat) {
      case 'mairie': return 'Mairie';
      case 'alerte': return 'Alerte';
      case 'culture': return 'Culture';
      default: return 'Info';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(actualitesProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Actualité'), backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
        body: EtatErreur(onRetry: () => ref.invalidate(actualitesProvider)),
      ),
      data: (liste) {
        final actu = liste.firstWhere((e) => e.id == id, orElse: () => liste.first);
        final couleur = _couleurCat(actu.categorie);
        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: couleur,
                foregroundColor: AppColors.white,
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(actu.titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  background: Container(
                    color: couleur.withValues(alpha: 0.15),
                    child: Center(child: Icon(Icons.article_outlined, size: 80, color: couleur)),
                  ),
                ),
              ),
              if (actu.photoUrl != null || actu.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: PhotoGallery(
                    photoCouverture: actu.photoUrl,
                    photos: actu.photos,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
                          child: Text(_labelCat(actu.categorie),
                              style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(actu.createdAt, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        ]),
                      ]),
                      const SizedBox(height: 20),
                      Text(actu.contenu,
                          style: const TextStyle(fontSize: 15, color: AppColors.textDark, height: 1.7)),
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

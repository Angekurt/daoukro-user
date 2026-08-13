import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/etat_widgets.dart';
import '../../../data/models/urgence_actualite_model.dart';

// Supprime les balises HTML (ex: <p>, </p>, <br>, etc.) d'une chaîne de caractères
String _stripHtml(String texte) =>
    texte.replaceAll(RegExp(r'<[^>]*>'), '').trim();

class ActualitesListScreen extends ConsumerWidget {
  const ActualitesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(actualitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infos locales'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(blanc: true),
        elevation: 0,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EtatErreur(onRetry: () => ref.invalidate(actualitesProvider)),
        data: (actualites) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(actualitesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: actualites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ActualiteCard(actualite: actualites[i]),
          ),
        ),
      ),
    );
  }
}

class _ActualiteCard extends StatefulWidget {
  final ActualiteModel actualite;
  const _ActualiteCard({required this.actualite});

  @override
  State<_ActualiteCard> createState() => _ActualiteCardState();
}

class _ActualiteCardState extends State<_ActualiteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const _cats = {
    'alerte':  (couleur: AppColors.sante, label: 'ALERTE',  icone: Icons.warning_rounded),
    'mairie':  (couleur: AppColors.mairie, label: 'MAIRIE',  icone: Icons.account_balance),
    'sante':   (couleur: AppColors.success, label: 'SANTÉ',   icone: Icons.local_hospital),
    'info':    (couleur: AppColors.info, label: 'INFO',    icone: Icons.newspaper),
    'culture': (couleur: AppColors.culture, label: 'CULTURE', icone: Icons.theater_comedy),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.97, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cat = _cats[widget.actualite.categorie] ?? _cats['info']!;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); context.push('/actualites/${widget.actualite.id}'); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.couleur.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icone, size: 11, color: cat.couleur),
                    const SizedBox(width: 4),
                    Text(cat.label, style: TextStyle(fontSize: 10, color: cat.couleur, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                  ]),
                ),
                const Spacer(),
                Text(widget.actualite.createdAt, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ]),
              const SizedBox(height: 10),
              Text(widget.actualite.titre,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
              const SizedBox(height: 6),
              Text(_stripHtml(widget.actualite.contenu),
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Lire la suite', style: TextStyle(fontSize: 12, color: cat.couleur, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 13, color: cat.couleur),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

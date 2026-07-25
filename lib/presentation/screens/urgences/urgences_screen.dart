import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/widgets/support_fab.dart';
import '../../providers/modules_provider.dart';
import '../../widgets/action_button.dart';
import '../../../data/models/urgence_actualite_model.dart';

class UrgencesScreen extends ConsumerWidget {
  const UrgencesScreen({super.key});

  static const _cats = {
    'sante':    (label: 'Santé',     icone: Icons.local_hospital,       couleur: AppColors.sante),
    'securite': (label: 'Sécurité',  icone: Icons.local_police,         couleur: AppColors.securite),
    'incendie': (label: 'Incendie',  icone: Icons.local_fire_department, couleur: AppColors.incendie),
    'autre':    (label: 'Autres',    icone: Icons.phone_in_talk,        couleur: AppColors.artisan),
  };

  static const _rouge = AppColors.danger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(urgencesProvider);

    return Scaffold(
      floatingActionButton: const SupportFab(contexte: 'Numéros d\'urgence'),
      appBar: AppBar(
        title: const Text('Numéros d\'urgence'),
        backgroundColor: _rouge,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(blanc: true),
        elevation: 0,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _rouge)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (urgences) {
          final groupes = <String, List<UrgenceModel>>{};
          for (final u in urgences) {
            groupes.putIfAbsent(u.categorie, () => []).add(u);
          }

          return RefreshIndicator(
            color: _rouge,
            onRefresh: () async => ref.invalidate(urgencesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Bandeau info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _rouge.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rouge.withValues(alpha: 0.15)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded, color: _rouge, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Appuyez sur un numéro pour appeler directement.',
                        style: TextStyle(fontSize: 12, color: _rouge, height: 1.4),
                      ),
                    ),
                  ]),
                ),

                // Groupes par catégorie
                for (final entry in _cats.entries) ...[
                  if ((groupes[entry.key] ?? []).isNotEmpty) ...[
                    _SectionHeader(label: entry.value.label, icone: entry.value.icone, couleur: entry.value.couleur),
                    for (final u in groupes[entry.key]!)
                      _UrgenceCard(urgence: u, couleur: entry.value.couleur),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label; final IconData icone; final Color couleur;
  const _SectionHeader({required this.label, required this.icone, required this.couleur});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icone, color: couleur, size: 16),
      ),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: couleur)),
    ]),
  );
}

class _UrgenceCard extends StatefulWidget {
  final UrgenceModel urgence;
  final Color couleur;
  const _UrgenceCard({required this.urgence, required this.couleur});

  @override
  State<_UrgenceCard> createState() => _UrgenceCardState();
}

class _UrgenceCardState extends State<_UrgenceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.97, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); context.push('/urgences/${widget.urgence.id}'); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: widget.couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.phone_in_talk_rounded, color: widget.couleur, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.urgence.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  if (widget.urgence.adresse != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.urgence.adresse!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                  if (widget.urgence.description != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.urgence.description!, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  ],
                ])),
                Icon(Icons.chevron_right_rounded, color: AppColors.border),
              ]),
            ),
            Divider(height: 1, color: AppColors.surfaceAlt),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(children: [
                Expanded(child: _BtnAppel(numero: widget.urgence.telephone, couleur: widget.couleur, principal: true)),
                if (widget.urgence.telephone2 != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _BtnAppel(numero: widget.urgence.telephone2!, couleur: widget.couleur, principal: false)),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BtnAppel extends StatefulWidget {
  final String numero; final Color couleur; final bool principal;
  const _BtnAppel({required this.numero, required this.couleur, required this.principal});

  @override
  State<_BtnAppel> createState() => _BtnAppelState();
}

class _BtnAppelState extends State<_BtnAppel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.93, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        ContactService.call(context, widget.numero);
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.principal ? widget.couleur : widget.couleur.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.phone_rounded, size: 15, color: widget.principal ? AppColors.white : widget.couleur),
            const SizedBox(width: 6),
            Text(widget.numero, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.principal ? AppColors.white : widget.couleur)),
          ]),
        ),
      ),
    );
  }
}

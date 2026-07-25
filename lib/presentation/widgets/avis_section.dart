import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../providers/avis_provider.dart';
import 'etat_widgets.dart';

/// Section "Avis" pour une fiche artisan ou hébergement : liste des avis
/// validés + bouton pour en déposer un nouveau (aucun compte requis).
class AvisSection extends ConsumerWidget {
  final String entityType; // 'artisan' | 'hebergement'
  final int entityId;
  final String nomEntite;

  const AvisSection({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.nomEntite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couleurTitre = isDark ? AppColors.white : AppColors.textDark;
    final couleurCarte = isDark ? AppColors.cardDark : AppColors.surfaceAlt;
    final couleurCommentaire = isDark ? AppColors.white54 : AppColors.textGrey;
    final params = (type: entityType, id: entityId);
    final avisAsync = ref.watch(avisProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            const Icon(PhosphorIconsRegular.star, color: AppColors.secondary, size: 18),
            const SizedBox(width: 8),
            Text('Avis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: couleurTitre)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _ouvrirFormulaire(context, ref, params),
              icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 16),
              label: const Text('Donner mon avis'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        avisAsync.when(
          loading: () => const ChargementSkeleton(count: 2, height: 70),
          error: (_, __) => EtatErreur(onRetry: () => ref.invalidate(avisProvider(params))),
          data: (liste) {
            if (liste.isEmpty) {
              return const EtatVide(
                icone: PhosphorIconsRegular.chatCircleText,
                titre: 'Aucun avis pour le moment',
                message: 'Soyez la première personne à en laisser un.',
              );
            }
            return Column(
              children: liste.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: couleurCarte,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(a.nom, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: couleurTitre)),
                        ),
                        Text(DateFormat('dd/MM/yyyy').format(a.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < a.note ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                        size: 14,
                        color: AppColors.secondary,
                      )),
                    ),
                    if (a.commentaire != null && a.commentaire!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(a.commentaire!, style: TextStyle(fontSize: 13, color: couleurCommentaire, height: 1.4)),
                    ],
                  ],
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  void _ouvrirFormulaire(BuildContext context, WidgetRef ref, ({String type, int id}) params) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _FormulaireAvis(
        entityType: entityType,
        entityId: entityId,
        nomEntite: nomEntite,
        onEnvoye: () => ref.invalidate(avisProvider(params)),
      ),
    );
  }
}

class _FormulaireAvis extends ConsumerStatefulWidget {
  final String entityType;
  final int entityId;
  final String nomEntite;
  final VoidCallback onEnvoye;

  const _FormulaireAvis({
    required this.entityType,
    required this.entityId,
    required this.nomEntite,
    required this.onEnvoye,
  });

  @override
  ConsumerState<_FormulaireAvis> createState() => _FormulaireAvisState();
}

class _FormulaireAvisState extends ConsumerState<_FormulaireAvis> {
  final _nomController = TextEditingController();
  final _commentaireController = TextEditingController();
  int _note = 0;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _nomController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (_note == 0 || _nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez votre nom et une note.'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _envoiEnCours = true);
    try {
      final message = await ref.read(avisRepositoryProvider).envoyerAvis(
            widget.entityType,
            widget.entityId,
            nom: _nomController.text,
            note: _note,
            commentaire: _commentaireController.text,
          );
      if (!mounted) return;
      widget.onEnvoye();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white24 : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Votre avis sur ${widget.nomEntite}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.textDark)),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final valeur = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _note = valeur),
                    icon: Icon(
                      valeur <= _note ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                      color: AppColors.secondary,
                    ),
                    iconSize: 32,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Votre nom'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentaireController,
              decoration: const InputDecoration(labelText: 'Commentaire (optionnel)'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _envoiEnCours ? null : _envoyer,
                child: _envoiEnCours
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

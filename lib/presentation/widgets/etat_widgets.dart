import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// État vide illustré — jamais un widget vide silencieux. Toujours une
/// icône, un titre explicite, et si pertinent une action.
class EtatVide extends StatelessWidget {
  final PhosphorIconData icone;
  final String titre;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EtatVide({
    super.key,
    this.icone = PhosphorIconsRegular.empty,
    required this.titre,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couleurTitre = isDark ? AppColors.white : AppColors.textDark;
    final couleurMessage = isDark ? AppColors.white54 : AppColors.textGrey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icone, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(titre,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: couleurTitre)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: couleurMessage)),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// État d'erreur réseau — icône + message + bouton Réessayer systématique.
/// Affiche aussi les données en cache si disponibles.
class EtatErreur extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final bool donneesEnCache;

  const EtatErreur({
    super.key,
    this.message,
    required this.onRetry,
    this.donneesEnCache = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (donneesEnCache)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF8E1),
            child: Row(children: const [
              Icon(Icons.history_rounded, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Données affichées depuis le cache local',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                ),
              ),
            ]),
          ),
        EtatVide(
          icone: PhosphorIconsRegular.wifiSlash,
          titre: donneesEnCache
              ? 'Connexion indisponible'
              : 'Impossible de charger le contenu',
          message: donneesEnCache
              ? 'Les données affichées proviennent du cache local.\nElles se mettront à jour automatiquement quand internet sera disponible.'
              : (message ?? 'Vérifiez votre connexion internet.'),
          actionLabel: 'Réessayer',
          onAction: onRetry,
        ),
      ],
    );
  }
}

/// Skeleton de chargement générique — une pile de cartes rectangulaires
/// animées, à la place d'un simple spinner rond centré.
class ChargementSkeleton extends StatelessWidget {
  final int count;
  final double height;
  final EdgeInsetsGeometry padding;

  const ChargementSkeleton({
    super.key,
    this.count = 3,
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: isDark ? AppColors.cardDark : AppColors.shimmerBase,
              highlightColor: isDark ? AppColors.white12 : AppColors.shimmerHigh,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

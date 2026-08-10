import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/connexion_provider.dart';

/// Bandeau affiché en haut des listes quand l'app utilise des données
/// mises en cache (pas de connexion internet disponible).
/// Se cache automatiquement quand la connexion revient.
class BandeauCache extends ConsumerWidget {
  const BandeauCache({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLigne = ref.watch(connexionProvider);
    if (enLigne) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Données affichées depuis le cache local. Reconnectez-vous à internet pour voir les dernières informations.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF78350F),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau compact pour les listes — affiche juste une icône + texte court.
class BandeauCacheCompact extends ConsumerWidget {
  const BandeauCacheCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLigne = ref.watch(connexionProvider);
    if (enLigne) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.history_rounded, size: 14, color: Color(0xFFF59E0B)),
          SizedBox(width: 6),
          Text(
            'Données depuis le cache — actualisation en cours...',
            style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
          ),
        ],
      ),
    );
  }
}

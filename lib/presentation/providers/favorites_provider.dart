import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/favorites_service.dart';

/// Provider qui retourne la liste des favoris (réactif)
final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<FavoriteItem>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<FavoriteItem>> {
  @override
  Future<List<FavoriteItem>> build() => FavoritesService.getAll();

  Future<void> toggle(FavoriteItem item) async {
    await FavoritesService.toggle(item);
    ref.invalidateSelf();
  }

  Future<void> remove(String type, int id) async {
    await FavoritesService.remove(type, id);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    await FavoritesService.clearAll();
    ref.invalidateSelf();
  }
}

/// Provider utilitaire pour vérifier si un item est favori
final isFavoriteProvider = FutureProvider.family<bool, ({String type, int id})>(
  (ref, args) async {
    // Dépend du provider principal pour se mettre à jour automatiquement
    await ref.watch(favoritesProvider.future);
    return FavoritesService.isFavorite(args.type, args.id);
  },
);

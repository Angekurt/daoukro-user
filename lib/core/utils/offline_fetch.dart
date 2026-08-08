import 'cache_manager.dart';

/// Pattern "stale-while-revalidate" pour les listes chargées depuis l'API :
/// émet immédiatement la version en cache local (si elle existe) pour un
/// affichage instantané, pendant que [fetch] va chercher les données
/// fraîches en arrière-plan — sans jamais laisser l'utilisateur face à un
/// écran de chargement vide alors qu'une version locale est disponible.
///
/// Le repli réseau→cache en cas d'échec (hors connexion) reste géré par
/// [fetch] lui-même (déjà en place dans chaque repository) : cet emballage
/// sert uniquement à afficher le cache tout de suite plutôt que d'attendre
/// la réponse réseau quand une version locale existe déjà.
Stream<List<T>> listOfflineFirst<T>({
  required String cacheKey,
  required T Function(Map<String, dynamic> json) fromJson,
  required Future<List<T>> Function() fetch,
}) async* {
  final raw = CacheManager.get(cacheKey);
  if (raw != null && raw['data'] != null) {
    try {
      final List data = raw['data'];
      yield data.map((j) => fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (_) {
      // Cache corrompu — on ignore et on attend la réponse réseau ci-dessous.
    }
  }
  yield await fetch();
}

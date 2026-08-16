import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/offline_fetch.dart';
import '../../data/models/annonce_model.dart';
import '../../data/repositories/annonce_repository.dart';

final annonceRepositoryProvider = Provider<AnnonceRepository>((ref) {
  return AnnonceRepository();
});

final annoncesProvider = StreamProvider<List<AnnonceModel>>((ref) {
  final repo = ref.read(annonceRepositoryProvider);
  return listOfflineFirst<AnnonceModel>(
    cacheKey: 'annonces_list',
    fromJson: AnnonceModel.fromJson,
    fetch: () => repo.getAnnonces(),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/offline_fetch.dart';
import '../../data/models/pharmacie_model.dart';
import '../../data/models/garde_model.dart';
import '../../data/repositories/pharmacie_repository.dart';

// Instance du repository
final pharmacieRepositoryProvider = Provider<PharmacieRepository>((ref) {
  return PharmacieRepository();
});

// Liste toutes les pharmacies — cache affiché immédiatement, actualisé dès
// que la réponse réseau arrive (voir listOfflineFirst).
final pharmaciesProvider = StreamProvider<List<PharmacieModel>>((ref) {
  final repository = ref.read(pharmacieRepositoryProvider);
  return listOfflineFirst<PharmacieModel>(
    cacheKey: 'pharmacies_list',
    fromJson: PharmacieModel.fromJson,
    fetch: () => repository.getPharmacies(),
  );
});

// Pharmacies de garde actives
final gardesActivesProvider = StreamProvider<List<GardeModel>>((ref) {
  final repository = ref.read(pharmacieRepositoryProvider);
  return listOfflineFirst<GardeModel>(
    cacheKey: 'pharmacies_garde_actives',
    fromJson: GardeModel.fromJson,
    fetch: () => repository.getGardesActives(),
  );
});

// Détail d'une pharmacie
final pharmacieDetailProvider = FutureProvider.family<PharmacieModel, int>((ref, id) async {
  final repository = ref.read(pharmacieRepositoryProvider);
  return repository.getPharmacie(id);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pharmacie_model.dart';
import '../../data/models/garde_model.dart';
import '../../data/repositories/pharmacie_repository.dart';

// Instance du repository
final pharmacieRepositoryProvider = Provider<PharmacieRepository>((ref) {
  return PharmacieRepository();
});

// Liste toutes les pharmacies
final pharmaciesProvider = FutureProvider<List<PharmacieModel>>((ref) async {
  final repository = ref.read(pharmacieRepositoryProvider);
  return repository.getPharmacies();
});

// Pharmacies de garde actives
final gardesActivesProvider = FutureProvider<List<GardeModel>>((ref) async {
  final repository = ref.read(pharmacieRepositoryProvider);
  return repository.getGardesActives();
});

// Détail d'une pharmacie
final pharmacieDetailProvider = FutureProvider.family<PharmacieModel, int>((ref, id) async {
  final repository = ref.read(pharmacieRepositoryProvider);
  return repository.getPharmacie(id);
});
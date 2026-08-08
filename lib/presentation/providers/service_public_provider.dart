import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/offline_fetch.dart';
import '../../data/models/service_public_model.dart';
import '../../data/repositories/service_public_repository.dart';

// Instance du repository
final servicePublicRepositoryProvider = Provider<ServicePublicRepository>((ref) {
  return ServicePublicRepository();
});

// Liste tous les services publics
final servicesPublicsProvider = StreamProvider<List<ServicePublicModel>>((ref) {
  final repository = ref.read(servicePublicRepositoryProvider);
  return listOfflineFirst<ServicePublicModel>(
    cacheKey: 'services_publics_list',
    fromJson: ServicePublicModel.fromJson,
    fetch: () => repository.getServicesPublics(),
  );
});

// Détail d'un service public
final servicePublicDetailProvider = FutureProvider.family<ServicePublicModel, int>((ref, id) async {
  final repository = ref.read(servicePublicRepositoryProvider);
  return repository.getServicePublic(id);
});

// Services par catégorie
final servicesParCategorieProvider = FutureProvider.family<List<ServicePublicModel>, int>((ref, categorieId) async {
  final repository = ref.read(servicePublicRepositoryProvider);
  return repository.getServicesParCategorie(categorieId);
});
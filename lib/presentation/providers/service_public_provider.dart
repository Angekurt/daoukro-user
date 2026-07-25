import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_public_model.dart';
import '../../data/repositories/service_public_repository.dart';

// Instance du repository
final servicePublicRepositoryProvider = Provider<ServicePublicRepository>((ref) {
  return ServicePublicRepository();
});

// Liste tous les services publics
final servicesPublicsProvider = FutureProvider<List<ServicePublicModel>>((ref) async {
  final repository = ref.read(servicePublicRepositoryProvider);
  return repository.getServicesPublics();
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
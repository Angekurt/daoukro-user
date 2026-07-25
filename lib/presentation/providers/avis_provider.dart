import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/avis_model.dart';
import '../../data/repositories/avis_repository.dart';

final avisRepositoryProvider = Provider<AvisRepository>((ref) => AvisRepository());

/// Clé : (type: 'artisan'|'hebergement', id: identifiant de la fiche).
final avisProvider = FutureProvider.family<List<AvisModel>, ({String type, int id})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvis(params.type, params.id);
});

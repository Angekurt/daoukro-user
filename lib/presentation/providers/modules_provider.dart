import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/cache_manager.dart';
import '../../core/utils/offline_fetch.dart';
import '../../data/models/hebergement_model.dart';
import '../../data/models/immobilier_model.dart';
import '../../data/models/artisan_model.dart';
import '../../data/models/urgence_actualite_model.dart';

// ─── HÉBERGEMENTS ────────────────────────────────────────────────────────────

final hebergementsProvider = StreamProvider<List<HebergementModel>>((ref) {
  const String cacheKey = 'hebergements_list';
  final dio = ApiClient.getInstance();
  return listOfflineFirst<HebergementModel>(
    cacheKey: cacheKey,
    fromJson: HebergementModel.fromJson,
    fetch: () async {
      try {
        final response = await dio.get('/hebergements');
        final List data = response.data['data'];
        await CacheManager.save(cacheKey, response.data);
        return data.map((j) => HebergementModel.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        final cached = CacheManager.get(cacheKey);
        if (cached != null && cached['data'] != null) {
          final List data = cached['data'];
          return data.map((j) => HebergementModel.fromJson(Map<String, dynamic>.from(j))).toList();
        }
        rethrow;
      }
    },
  );
});

// ─── IMMOBILIER ──────────────────────────────────────────────────────────────

final immobilierProvider = StreamProvider<List<ImmobilierModel>>((ref) {
  const String cacheKey = 'immobilier_list';
  final dio = ApiClient.getInstance();
  return listOfflineFirst<ImmobilierModel>(
    cacheKey: cacheKey,
    fromJson: ImmobilierModel.fromJson,
    fetch: () async {
      try {
        final response = await dio.get('/immobilier');
        final List data = response.data['data'];
        await CacheManager.save(cacheKey, response.data);
        return data.map((j) => ImmobilierModel.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        final cached = CacheManager.get(cacheKey);
        if (cached != null && cached['data'] != null) {
          final List data = cached['data'];
          return data.map((j) => ImmobilierModel.fromJson(Map<String, dynamic>.from(j))).toList();
        }
        rethrow;
      }
    },
  );
});

// ─── ARTISANS ────────────────────────────────────────────────────────────────

final artisansProvider = StreamProvider<List<ArtisanModel>>((ref) {
  const String cacheKey = 'artisans_list';
  final dio = ApiClient.getInstance();
  return listOfflineFirst<ArtisanModel>(
    cacheKey: cacheKey,
    fromJson: ArtisanModel.fromJson,
    fetch: () async {
      try {
        final response = await dio.get('/artisans');
        final List data = response.data['data'];
        await CacheManager.save(cacheKey, response.data);
        return data.map((j) => ArtisanModel.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        final cached = CacheManager.get(cacheKey);
        if (cached != null && cached['data'] != null) {
          final List data = cached['data'];
          return data.map((j) => ArtisanModel.fromJson(Map<String, dynamic>.from(j))).toList();
        }
        rethrow;
      }
    },
  );
});

final artisansParMetierProvider = FutureProvider.family<List<ArtisanModel>, String>((ref, metier) async {
  final tous = await ref.watch(artisansProvider.future);
  if (metier == 'Tous') return tous;
  return tous.where((a) => a.metier == metier).toList();
});

// ─── URGENCES ────────────────────────────────────────────────────────────────

final urgencesProvider = StreamProvider<List<UrgenceModel>>((ref) {
  const String cacheKey = 'urgences_list';
  final dio = ApiClient.getInstance();
  return listOfflineFirst<UrgenceModel>(
    cacheKey: cacheKey,
    fromJson: UrgenceModel.fromJson,
    fetch: () async {
      try {
        final response = await dio.get('/urgences');
        final List data = response.data['data'];
        await CacheManager.save(cacheKey, response.data);
        return data.map((j) => UrgenceModel.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        final cached = CacheManager.get(cacheKey);
        if (cached != null && cached['data'] != null) {
          final List data = cached['data'];
          return data.map((j) => UrgenceModel.fromJson(Map<String, dynamic>.from(j))).toList();
        }
        rethrow;
      }
    },
  );
});

// ─── ACTUALITÉS ──────────────────────────────────────────────────────────────

final actualitesProvider = StreamProvider<List<ActualiteModel>>((ref) {
  const String cacheKey = 'actualites_list';
  final dio = ApiClient.getInstance();
  return listOfflineFirst<ActualiteModel>(
    cacheKey: cacheKey,
    fromJson: ActualiteModel.fromJson,
    fetch: () async {
      try {
        final response = await dio.get('/actualites');
        final List data = response.data['data'];
        await CacheManager.save(cacheKey, response.data);
        return data.map((j) => ActualiteModel.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        final cached = CacheManager.get(cacheKey);
        if (cached != null && cached['data'] != null) {
          final List data = cached['data'];
          return data.map((j) => ActualiteModel.fromJson(Map<String, dynamic>.from(j))).toList();
        }
        rethrow;
      }
    },
  );
});

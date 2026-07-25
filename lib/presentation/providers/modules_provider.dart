import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/cache_manager.dart';
import '../../data/models/hebergement_model.dart';
import '../../data/models/immobilier_model.dart';
import '../../data/models/artisan_model.dart';
import '../../data/models/urgence_actualite_model.dart';

// ─── HÉBERGEMENTS ────────────────────────────────────────────────────────────

final hebergementsProvider = FutureProvider<List<HebergementModel>>((ref) async {
  const String cacheKey = 'hebergements_list';
  try {
    final dio = ApiClient.getInstance();
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
    return _hebergementsDemo;
  }
});

final _hebergementsDemo = [
  HebergementModel(id: 1, nom: 'Hôtel Le Président', type: 'hotel',
    description: 'Hôtel de standing au cœur de Daoukro. Climatisation, restaurant, parking sécurisé.',
    adresse: 'Avenue Principale, Daoukro', telephone: '+225 27 00 00 01',
    prixMin: 15000, prixMax: 35000, note: 4.2, nbAvis: 38, isActive: true),
  HebergementModel(id: 2, nom: 'Résidence Les Palmiers', type: 'residence',
    description: 'Appartements meublés pour courts et longs séjours. Cuisine équipée, WiFi inclus.',
    adresse: 'Quartier Résidentiel, Daoukro', telephone: '+225 27 00 00 02',
    prixMin: 10000, prixMax: 20000, note: 4.0, nbAvis: 22, isActive: true),
  HebergementModel(id: 3, nom: 'Auberge du Voyageur', type: 'hotel',
    description: 'Hébergement simple et propre. Idéal pour les voyageurs de passage.',
    adresse: 'Près de la gare routière, Daoukro', telephone: '+225 27 00 00 03',
    prixMin: 5000, prixMax: 10000, note: 3.5, nbAvis: 15, isActive: true),
  HebergementModel(id: 4, nom: 'Villa Confort', type: 'meuble',
    description: 'Villa 3 chambres entièrement meublée. Idéale pour familles ou groupes.',
    adresse: 'Zone Résidentielle Nord, Daoukro', telephone: '+225 27 00 00 04',
    prixMin: 25000, prixMax: 50000, note: 4.7, nbAvis: 9, isActive: true),
];

// ─── IMMOBILIER ──────────────────────────────────────────────────────────────

final immobilierProvider = FutureProvider<List<ImmobilierModel>>((ref) async {
  const String cacheKey = 'immobilier_list';
  try {
    final dio = ApiClient.getInstance();
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
    return _immobilierDemo;
  }
});

final _immobilierDemo = [
  ImmobilierModel(id: 1, titre: 'Villa F4 à vendre', typeOffre: 'vente', typeBien: 'villa',
    description: 'Belle villa 4 pièces avec jardin. Titre foncier disponible. Quartier calme.',
    adresse: 'Quartier Résidentiel', quartier: 'Zone Nord',
    prix: 18000000, surface: '200 m²', nbChambres: 4,
    telephone: '+225 07 10 00 01', isActive: true),
  ImmobilierModel(id: 2, titre: 'Terrain 500m² à vendre', typeOffre: 'vente', typeBien: 'terrain',
    description: 'Terrain viabilisé, bornage effectué. Accès route bitumée.',
    adresse: 'Zone d\'extension', quartier: 'Périphérie Est',
    prix: 3500000, surface: '500 m²',
    telephone: '+225 07 10 00 02', isActive: true),
  ImmobilierModel(id: 3, titre: 'Appartement F3 à louer', typeOffre: 'location', typeBien: 'appartement',
    description: 'Appartement 3 pièces au 2ème étage. Eau et électricité disponibles.',
    adresse: 'Centre-ville', quartier: 'Centre',
    prix: 60000, surface: '80 m²', nbChambres: 2,
    telephone: '+225 07 10 00 03', isActive: true),
  ImmobilierModel(id: 4, titre: 'Maison F5 à louer', typeOffre: 'location', typeBien: 'maison',
    description: 'Grande maison familiale avec cour. Idéale pour famille nombreuse.',
    adresse: 'Quartier Calme', quartier: 'Zone Ouest',
    prix: 120000, surface: '150 m²', nbChambres: 5,
    telephone: '+225 07 10 00 04', isActive: true),
];

// ─── ARTISANS ────────────────────────────────────────────────────────────────

final artisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  const String cacheKey = 'artisans_list';
  try {
    final dio = ApiClient.getInstance();
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
    return _artisansDemo;
  }
});

final artisansParMetierProvider = FutureProvider.family<List<ArtisanModel>, String>((ref, metier) async {
  final tous = await ref.watch(artisansProvider.future);
  if (metier == 'Tous') return tous;
  return tous.where((a) => a.metier == metier).toList();
});

final _artisansDemo = [
  ArtisanModel(id: 1, nom: 'Koné Ibrahim', metier: 'Plombier',
    description: 'Plombier qualifié, 10 ans d\'expérience. Intervention rapide.',
    telephone: '+225 07 20 00 01', whatsapp: '+225 07 20 00 01',
    adresse: 'Daoukro Centre', note: 4.5, nbAvis: 28, disponible: true, isActive: true),
  ArtisanModel(id: 2, nom: 'Yao Kouassi', metier: 'Électricien',
    description: 'Installation et dépannage électrique. Devis gratuit.',
    telephone: '+225 07 20 00 02', whatsapp: '+225 07 20 00 02',
    adresse: 'Daoukro', note: 4.3, nbAvis: 19, disponible: true, isActive: true),
  ArtisanModel(id: 3, nom: 'Coulibaly Seydou', metier: 'Maçon',
    description: 'Construction, rénovation, carrelage. Travail soigné et rapide.',
    telephone: '+225 07 20 00 03',
    adresse: 'Daoukro', note: 4.1, nbAvis: 34, disponible: false, isActive: true),
  ArtisanModel(id: 4, nom: 'Adjoua Marie', metier: 'Couturière',
    description: 'Couture sur mesure, retouches, tenues traditionnelles et modernes.',
    telephone: '+225 07 20 00 04', whatsapp: '+225 07 20 00 04',
    adresse: 'Marché Central, Daoukro', note: 4.8, nbAvis: 52, disponible: true, isActive: true),
  ArtisanModel(id: 5, nom: 'Traoré Moussa', metier: 'Menuisier',
    description: 'Fabrication meubles sur mesure, portes, fenêtres.',
    telephone: '+225 07 20 00 05',
    adresse: 'Zone Artisanale, Daoukro', note: 4.0, nbAvis: 17, disponible: true, isActive: true),
  ArtisanModel(id: 6, nom: 'Bamba Fatou', metier: 'Coiffeuse',
    description: 'Coiffure africaine et moderne. Tresses, tissages, soins capillaires.',
    telephone: '+225 07 20 00 06', whatsapp: '+225 07 20 00 06',
    adresse: 'Quartier Résidentiel, Daoukro', note: 4.6, nbAvis: 41, disponible: true, isActive: true),
  ArtisanModel(id: 7, nom: 'Diallo Mamadou', metier: 'Mécanicien',
    description: 'Réparation toutes marques. Diagnostic, vidange, freins, climatisation.',
    telephone: '+225 07 20 00 07',
    adresse: 'Garage Central, Daoukro', note: 4.2, nbAvis: 63, disponible: true, isActive: true),
  ArtisanModel(id: 8, nom: 'N\'Guessan Paul', metier: 'Peintre',
    description: 'Peinture intérieure et extérieure. Décoration murale.',
    telephone: '+225 07 20 00 08',
    adresse: 'Daoukro', note: 3.9, nbAvis: 12, disponible: false, isActive: true),
];

// ─── URGENCES ────────────────────────────────────────────────────────────────

final urgencesProvider = FutureProvider<List<UrgenceModel>>((ref) async {
  const String cacheKey = 'urgences_list';
  try {
    final dio = ApiClient.getInstance();
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
    return _urgencesDemo;
  }
});

final _urgencesDemo = [
  UrgenceModel(id: 1, nom: 'SAMU / Urgences Médicales', categorie: 'sante',
    telephone: '185', telephone2: '+225 27 00 10 01',
    adresse: 'Hôpital Général de Daoukro', isActive: true),
  UrgenceModel(id: 2, nom: 'Pompiers', categorie: 'incendie',
    telephone: '180', telephone2: '+225 27 00 10 02',
    adresse: 'Caserne des Pompiers, Daoukro', isActive: true),
  UrgenceModel(id: 3, nom: 'Police Nationale', categorie: 'securite',
    telephone: '111', telephone2: '+225 27 00 10 03',
    adresse: 'Commissariat Central, Daoukro', isActive: true),
  UrgenceModel(id: 4, nom: 'Gendarmerie Nationale', categorie: 'securite',
    telephone: '170', telephone2: '+225 27 00 10 04',
    adresse: 'Brigade de Gendarmerie, Daoukro', isActive: true),
  UrgenceModel(id: 5, nom: 'Hôpital Général', categorie: 'sante',
    telephone: '+225 27 00 10 05',
    adresse: 'Avenue de la Santé, Daoukro', isActive: true),
  UrgenceModel(id: 6, nom: 'Mairie de Daoukro', categorie: 'autre',
    telephone: '+225 27 00 10 06',
    adresse: 'Place de la Mairie, Daoukro', isActive: true),
  UrgenceModel(id: 7, nom: 'CIE (Électricité)', categorie: 'autre',
    telephone: '179', telephone2: '+225 27 00 10 07',
    description: 'Signalement pannes électriques', isActive: true),
  UrgenceModel(id: 8, nom: 'SODECI (Eau)', categorie: 'autre',
    telephone: '175', telephone2: '+225 27 00 10 08',
    description: 'Signalement pannes eau', isActive: true),
];

// ─── ACTUALITÉS ──────────────────────────────────────────────────────────────

final actualitesProvider = FutureProvider<List<ActualiteModel>>((ref) async {
  const String cacheKey = 'actualites_list';
  try {
    final dio = ApiClient.getInstance();
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
    return _actualitesDemo;
  }
});

final _actualitesDemo = [
  ActualiteModel(id: 1,
    titre: 'Réhabilitation de la route principale',
    contenu: 'La mairie de Daoukro annonce le début des travaux de réhabilitation de l\'avenue principale. Les travaux débuteront le 20 février et dureront 3 mois. Des déviations seront mises en place.',
    categorie: 'mairie', createdAt: '2025-02-10', isActive: true),
  ActualiteModel(id: 2,
    titre: 'Coupure d\'eau programmée',
    contenu: 'La SODECI informe les habitants que l\'alimentation en eau sera interrompue le 15 février de 8h à 17h pour travaux de maintenance sur le réseau principal.',
    categorie: 'alerte', createdAt: '2025-02-08', isActive: true),
  ActualiteModel(id: 3,
    titre: 'Journée de vaccination gratuite',
    contenu: 'L\'hôpital général organise une journée de vaccination gratuite pour les enfants de 0 à 5 ans. Rendez-vous le 22 février à partir de 8h.',
    categorie: 'sante', createdAt: '2025-02-07', isActive: true),
  ActualiteModel(id: 4,
    titre: 'Résultats du BEPC 2024',
    contenu: 'Le taux de réussite au BEPC dans la région de Daoukro atteint 68%, en hausse de 5 points par rapport à l\'année précédente.',
    categorie: 'info', createdAt: '2025-02-05', isActive: true),
];

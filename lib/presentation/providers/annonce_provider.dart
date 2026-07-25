import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/annonce_model.dart';
import '../../data/repositories/annonce_repository.dart';

final annonceRepositoryProvider = Provider<AnnonceRepository>((ref) {
  return AnnonceRepository();
});

final annoncesProvider = FutureProvider<List<AnnonceModel>>((ref) async {
  try {
    final repo = ref.read(annonceRepositoryProvider);
    return await repo.getAnnonces();
  } catch (_) {
    // Données de démo tant que l'API n'est pas prête
    return _annoncesDemo;
  }
});

final _annoncesDemo = [
  AnnonceModel(
    id: 1,
    titre: 'Festival des Arts de Daoukro',
    description: 'Grand festival culturel avec expositions, concerts et spectacles de danse traditionnelle. Entrée libre pour tous.',
    type: TypeAnnonce.evenement,
    auteur: 'Mairie de Daoukro',
    lieu: 'Place de la Mairie, Daoukro',
    dateDebut: '15 Fév 2025',
    dateFin: '17 Fév 2025',
    contact: '+225 07 00 00 01',
    telephone: '+225 07 00 00 01',
    email: 'festival@daoukro.gov.ci',
    createdAt: '2025-02-08',
    isActive: true,
  ),
  AnnonceModel(
    id: 2,
    titre: 'Recrutement — Caissier(ère)',
    description: 'Supermarché Daoukro recrute un(e) caissier(ère) expérimenté(e). Salaire attractif + avantages. Envoyer CV par WhatsApp.',
    type: TypeAnnonce.emploi,
    auteur: 'Supermarché Daoukro',
    lieu: 'Daoukro Centre',
    dateDebut: 'Jusqu\'au 28 Fév 2025',
    contact: '+225 07 00 00 02',
    telephone: '+225 07 00 00 02',
    createdAt: '2025-02-07',
    isActive: true,
  ),
  AnnonceModel(
    id: 3,
    titre: 'Restaurant Le Baobab',
    description: 'Cuisine ivoirienne authentique. Attiéké poisson, foutou, kedjenou... Livraison disponible dans Daoukro.',
    type: TypeAnnonce.restaurant,
    auteur: 'Le Baobab',
    lieu: 'Quartier Résidentiel, Daoukro',
    contact: '+225 07 00 00 03',
    telephone: '+225 07 00 00 03',
    createdAt: '2025-02-06',
    isActive: true,
  ),
  AnnonceModel(
    id: 4,
    titre: 'Soirée Dansante — Club Étoile',
    description: 'Grande soirée chaque vendredi soir. DJ live, ambiance garantie. Réservation de table recommandée.',
    type: TypeAnnonce.pub,
    auteur: 'Club Étoile',
    lieu: 'Club Étoile, Daoukro',
    dateDebut: 'Chaque vendredi',
    contact: '+225 07 00 00 04',
    telephone: '+225 07 00 00 04',
    createdAt: '2025-02-05',
    isActive: true,
  ),
  AnnonceModel(
    id: 5,
    titre: 'Vente Terrain — Zone Résidentielle',
    description: 'Terrain de 600m² viabilisé à vendre. Titre foncier disponible. Idéal pour construction villa.',
    type: TypeAnnonce.annonce,
    auteur: 'Agence Immobilière Daoukro',
    lieu: 'Zone Nord, Daoukro',
    contact: '+225 07 00 00 05',
    telephone: '+225 07 00 00 05',
    createdAt: '2025-02-04',
    isActive: true,
  ),
  AnnonceModel(
    id: 6,
    titre: 'Tournoi de Football Inter-Quartiers',
    description: 'Inscriptions ouvertes pour le tournoi annuel. 16 équipes. Trophée et dotations pour les 3 premiers.',
    type: TypeAnnonce.evenement,
    auteur: 'Mairie - Jeunesse et Sports',
    lieu: 'Stade Municipal, Daoukro',
    dateDebut: '01 Mar 2025',
    contact: '+225 07 00 00 06',
    telephone: '+225 07 00 00 06',
    createdAt: '2025-02-03',
    isActive: true,
  ),
  AnnonceModel(
    id: 7,
    titre: 'Offre d\'emploi — Enseignant(e) Maths',
    description: 'École privée cherche enseignant(e) de mathématiques niveau lycée. CAPES ou équivalent requis.',
    type: TypeAnnonce.emploi,
    auteur: 'Groupe Scolaire Excellencia',
    lieu: 'Daoukro',
    dateDebut: 'Rentrée Sept 2025',
    contact: '+225 07 00 00 07',
    telephone: '+225 07 00 00 07',
    email: 'rh@excellencia.ci',
    createdAt: '2025-02-02',
    isActive: true,
  ),
  AnnonceModel(
    id: 8,
    titre: 'Maquis Chez Adjoua',
    description: 'Le meilleur garba de Daoukro ! Ouvert tous les jours de 7h à 22h. Plats du jour à partir de 500 FCFA.',
    type: TypeAnnonce.restaurant,
    auteur: 'Adjoua',
    lieu: 'Marché Central, Daoukro',
    contact: '+225 07 00 00 08',
    telephone: '+225 07 00 00 08',
    createdAt: '2025-02-01',
    isActive: true,
  ),
];

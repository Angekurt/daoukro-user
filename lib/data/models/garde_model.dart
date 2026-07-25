import 'pharmacie_model.dart';

/// Une garde = une pharmacie + la période durant laquelle elle est de garde.
class GardeModel {
  final PharmacieModel pharmacie;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? note;

  GardeModel({
    required this.pharmacie,
    required this.dateDebut,
    required this.dateFin,
    this.note,
  });

  factory GardeModel.fromJson(Map<String, dynamic> json) {
    return GardeModel(
      pharmacie: PharmacieModel.fromJson(Map<String, dynamic>.from(json['pharmacie'])),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      note: json['note'],
    );
  }
}

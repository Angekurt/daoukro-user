import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signalement_model.dart';
import '../../data/repositories/signalement_repository.dart';

const _kKey = 'signalements_locaux';

class SignalementsNotifier extends AsyncNotifier<List<SignalementModel>> {
  @override
  Future<List<SignalementModel>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? [];
    return raw.map((s) => SignalementModel.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> ajouter(SignalementModel s) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = <SignalementModel>[...?(state.value), s]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await prefs.setStringList(_kKey, liste.map((e) => jsonEncode(e.toJson())).toList());
    state = AsyncData(liste);

    // Transmission à la mairie — best-effort : le signalement reste
    // visible localement même si l'envoi échoue (hors ligne).
    try {
      await SignalementRepository().envoyer(s);
    } catch (e) {
      debugPrint('[SIGNALEMENT] envoi différé (hors ligne ?) : $e');
    }
  }

  Future<void> supprimer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = [...?(state.value)]..removeWhere((s) => s.id == id);
    await prefs.setStringList(_kKey, liste.map((e) => jsonEncode(e.toJson())).toList());
    state = AsyncData(liste);
  }
}

final signalementsProvider =
    AsyncNotifierProvider<SignalementsNotifier, List<SignalementModel>>(
        SignalementsNotifier.new);

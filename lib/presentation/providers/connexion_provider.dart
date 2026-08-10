import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider qui surveille l'état de la connexion réseau en temps réel.
/// true = en ligne, false = hors ligne.
/// Se met à jour automatiquement quand la connexion change.
final connexionProvider = StreamProvider<bool>((ref) async* {
  // État initial
  final initResult = await Connectivity().checkConnectivity();
  yield _estEnLigne(initResult);

  // Écoute les changements
  yield* Connectivity().onConnectivityChanged.map(_estEnLigne);
});

bool _estEnLigne(List<ConnectivityResult> results) {
  return results.any((r) =>
    r == ConnectivityResult.mobile ||
    r == ConnectivityResult.wifi ||
    r == ConnectivityResult.ethernet
  );
}

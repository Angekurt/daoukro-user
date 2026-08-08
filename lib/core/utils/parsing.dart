/// Parse une coordonnée GPS (latitude/longitude) renvoyée par l'API.
///
/// `double.parse` accepte silencieusement les littéraux "NaN"/"Infinity" —
/// si l'API ou l'admin Filament enregistre une valeur invalide, ça produit
/// un LatLng non fini qui fait planter flutter_map (Crashlytics l'a remonté
/// comme crash fatal). On rejette ces valeurs ici, à la frontière où les
/// données externes entrent dans l'app.
double? parseCoord(dynamic value) {
  if (value == null) return null;
  final parsed = double.tryParse(value.toString());
  if (parsed == null || !parsed.isFinite) return null;
  return parsed;
}

import 'package:flutter/material.dart';

class AppColors {
  // ── Primaire — vert forêt du logo ──────────────────────────────────────────
  static const Color primary      = Color(0xFF145217);
  static const Color primaryDark  = Color(0xFF0C3810);
  static const Color primaryLight = Color(0xFFE6EFE6);

  // ── Secondaire — orange baobab ─────────────────────────────────────────────
  static const Color secondary      = Color(0xFFEF8A0C);
  static const Color secondaryLight = Color(0xFFFDF0DE);

  // ── Statuts ────────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF2E7D32); // badge DE GARDE, service ouvert
  static const Color danger    = Color(0xFFB3261E); // urgences, erreurs
  static const Color whatsapp  = Color(0xFF25D366); // boutons WhatsApp uniquement

  // ── Neutres chauds ─────────────────────────────────────────────────────────
  static const Color surface      = Color(0xFFFAFAF7);
  static const Color surfaceAlt   = Color(0xFFF2F2EC);
  static const Color border       = Color(0xFFE3E2DA);
  static const Color textPrimary  = Color(0xFF1A1C19);
  static const Color textSecondary = Color(0xFF5C5F58);
  static const Color textMuted    = Color(0xFF8E918A);

  // ── Alias rétro-compatibles (anciens noms utilisés dans le code existant) ──
  static const Color white       = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color white70     = Color(0xB3FFFFFF); // texte blanc atténué sur fond coloré
  static const Color white54     = Color(0x8AFFFFFF); // libellés secondaires en mode sombre
  static const Color white24     = Color(0x3DFFFFFF); // icônes discrètes en mode sombre
  static const Color white12     = Color(0x1FFFFFFF); // séparateurs en mode sombre
  static const Color background  = surface;
  static const Color textDark    = textPrimary;
  static const Color textGrey    = textSecondary;
  static const Color error       = danger;
  static const Color warning     = secondary;
  static const Color gardeActive = success;
  static const Color primaryLightAlias = primaryLight;

  // ── Couleurs "métier" additionnelles — validées dans le cahier des charges
  //    pour les marqueurs de carte (hébergement, immobilier). Réutilisées
  //    partout ailleurs plutôt que d'inventer de nouvelles teintes : toutes
  //    les couleurs de catégorie de l'app se limitent à primary / secondary /
  //    success / danger / hebergementViolet / immobilierBleu.
  static const Color hebergementViolet = Color(0xFF6B4E9E);
  static const Color immobilierBleu    = Color(0xFF2C5F8A);
  static const Color shimmerBase  = Color(0xFFE0E0D8);
  static const Color shimmerHigh  = Color(0xFFF5F5F0);

  // ── Alias de catégories (mêmes 6 couleurs ci-dessus, réutilisées par thème) ─
  static const Color artisan        = secondary;   // secteur artisans/prestataires
  static const Color artisanBrun    = secondary;
  static const Color hebergement    = hebergementViolet;
  static const Color immobilier     = immobilierBleu;
  static const Color annonce        = secondary;
  static const Color evenement      = secondary;
  static const Color emploi         = primary;
  static const Color restaurant     = hebergementViolet;
  static const Color pub            = secondary;
  static const Color sante          = danger;      // urgences/services de santé
  static const Color securite       = danger;
  static const Color administration = primary;
  static const Color education      = primary;
  static const Color transport      = primaryDark;
  static const Color alerte         = danger;
  static const Color mairie         = primary;
  static const Color info           = primary;
  static const Color incendie       = danger;
  static const Color culture        = hebergementViolet;
  static const Color eclairage      = secondary;   // catégorie "Éclairage" (signalement)

  // ── Accents supplémentaires ──────────────────────────────────────────────
  static const Color dangerVif    = danger;
  static const Color dangerLight  = Color(0xFFFFF5F5); // fond pâle des écrans liés aux urgences
  static const Color ardoise      = textMuted;     // catégorie "Autre" (signalement)
  static const Color ardoiseFonce = textSecondary; // urgence — catégorie par défaut
  static const Color surfaceDark  = Color(0xFF121212); // fond page À propos — mode sombre
  static const Color cardDark     = Color(0xFF1E1E1E); // carte page À propos — mode sombre

  // ── Couleurs par catégorie (carte, marqueurs) ──────────────────────────────
  static Color categorie(String slug) {
    switch (slug.toLowerCase()) {
      case 'pharmacie':
      case 'pharmacies':
        return success;
      case 'service':
      case 'services':
      case 'service_public':
        return primary;
      case 'prestataire':
      case 'artisan':
      case 'artisans':
        return secondary;
      case 'urgence':
      case 'urgences':
        return danger;
      case 'hebergement':
      case 'hebergements':
        return hebergementViolet;
      case 'immobilier':
        return immobilierBleu;
      default:
        return primary;
    }
  }
}

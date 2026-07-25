// Service centralisé pour toutes les actions natives de l'application :
// appel téléphonique, WhatsApp, SMS, e-mail, itinéraire.
//
// Distinction fondamentale à respecter par les appelants :
// - ContactService.support()  → numéro du support Daoukro (global à l'app)
// - ContactService.call() / .whatsapp()  → numéro de l'entité affichée (BDD)
// Ces deux chemins ne doivent jamais être confondus.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'settings_service.dart';

class ContactService {
  ContactService._();

  /// Numéro du support Daoukro Digital.
  /// Fallback uniquement — la valeur de référence vient de
  /// GET /api/v1/settings → clé `support_whatsapp`.
  static const String supportPhoneFallback = '2250798240515';

  // ══════════════════════════════════════════════════════════
  //  NORMALISATION DES NUMÉROS IVOIRIENS
  // ══════════════════════════════════════════════════════════

  /// Convertit n'importe quel format vers le format international sans "+".
  ///
  ///   "+225 07 98 24 05 15"  →  "2250798240515"
  ///   "07 98 24 05 15"       →  "2250798240515"
  ///   "0798240515"           →  "2250798240515"
  ///   "00225 0798240515"     →  "2250798240515"
  static String normalize(String raw) {
    var n = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (n.startsWith('+')) n = n.substring(1);
    if (n.startsWith('00')) n = n.substring(2);
    if (!n.startsWith('225')) n = '225$n';
    return n;
  }

  /// Format lisible pour l'affichage : "+225 07 98 24 05 15"
  static String display(String raw) {
    final n = normalize(raw);
    if (n.length < 13) return raw;
    final local = n.substring(3);
    final buf = StringBuffer('+225 ');
    for (var i = 0; i < local.length; i += 2) {
      buf.write(local.substring(i, (i + 2).clamp(0, local.length)));
      if (i + 2 < local.length) buf.write(' ');
    }
    return buf.toString();
  }

  // ══════════════════════════════════════════════════════════
  //  ACTIONS
  // ══════════════════════════════════════════════════════════

  /// Ouvre WhatsApp sur une conversation.
  /// Bascule automatiquement sur wa.me (navigateur) si l'app n'est pas installée.
  static Future<void> whatsapp(
    BuildContext context,
    String phone, {
    String message = '',
  }) async {
    final n = normalize(phone);
    final text = Uri.encodeComponent(message);

    final appUri = Uri.parse('whatsapp://send?phone=$n&text=$text');
    final webUri = Uri.parse('https://wa.me/$n?text=$text');

    try {
      final ok = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {
      // WhatsApp non installé → on tente le fallback web
    }

    try {
      final ok = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _error(context, "Impossible d'ouvrir WhatsApp");
      }
    } catch (_) {
      if (context.mounted) _error(context, "Impossible d'ouvrir WhatsApp");
    }
  }

  /// Ouvre WhatsApp sur le support Daoukro.
  /// [supportPhone] : à ne préciser que pour forcer un numéro précis.
  /// Par défaut, on utilise la valeur pilotée depuis l'admin
  /// (GET /api/v1/settings → support_whatsapp), avec repli sur
  /// [supportPhoneFallback] si l'API n'a jamais pu être jointe.
  static Future<void> support(
    BuildContext context, {
    String? supportPhone,
    String? contexte,
  }) {
    final numero = supportPhone ?? SettingsService.instance.supportWhatsapp ?? supportPhoneFallback;
    final msg = contexte == null
        ? "Bonjour, j'ai besoin d'aide sur l'application Daoukro Digital."
        : "Bonjour, j'ai besoin d'aide sur l'application Daoukro Digital.\n\nConcernant : $contexte";
    return whatsapp(context, numero, message: msg);
  }

  /// Lance un appel téléphonique.
  static Future<void> call(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:${normalize(phone)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _error(context, "Impossible de lancer l'appel");
    } catch (_) {
      if (context.mounted) _error(context, "Impossible de lancer l'appel");
    }
  }

  /// Ouvre l'application SMS.
  static Future<void> sms(
    BuildContext context,
    String phone, {
    String body = '',
  }) async {
    final uri = Uri.parse(
      'sms:${normalize(phone)}?body=${Uri.encodeComponent(body)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _error(context, "Impossible d'ouvrir la messagerie");
    } catch (_) {
      if (context.mounted) _error(context, "Impossible d'ouvrir la messagerie");
    }
  }

  /// Ouvre le client e-mail.
  static Future<void> email(
    BuildContext context,
    String address, {
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _error(context, "Aucune application e-mail configurée");
    } catch (_) {
      if (context.mounted) _error(context, "Aucune application e-mail configurée");
    }
  }

  /// Ouvre l'itinéraire vers un point GPS dans l'application de navigation
  /// par défaut du téléphone. Fallback sur Google Maps web.
  ///
  /// Note : les fiches détail de l'application utilisent en priorité l'écran
  /// interne `/itineraire` (carte + distance en direct) ; cette méthode sert
  /// pour les cas où l'on veut déléguer directement à l'app de navigation
  /// externe (ex. popup de la carte).
  static Future<void> itinerary(
    BuildContext context,
    double lat,
    double lng, {
    String? label,
  }) async {
    final geo = Uri.parse(
      'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label ?? '')})',
    );
    final web = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      final ok = await launchUrl(geo, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {
      // aucune app de navigation → fallback web
    }

    try {
      final ok = await launchUrl(web, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _error(context, "Impossible d'ouvrir l'itinéraire");
    } catch (_) {
      if (context.mounted) _error(context, "Impossible d'ouvrir l'itinéraire");
    }
  }

  /// Ouvre un lien web externe.
  static Future<void> web(BuildContext context, String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _error(context, "Impossible d'ouvrir le lien");
    } catch (_) {
      if (context.mounted) _error(context, "Impossible d'ouvrir le lien");
    }
  }

  // ══════════════════════════════════════════════════════════

  static void _error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

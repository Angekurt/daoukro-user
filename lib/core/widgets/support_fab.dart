// Bouton flottant de support WhatsApp, à placer dans le Scaffold
// des écrans principaux :
//
//   Scaffold(floatingActionButton: const SupportFab(), ...)

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../services/contact_service.dart';
import '../theme/app_colors.dart';

class SupportFab extends StatelessWidget {
  /// Numéro provenant de l'API (/api/v1/settings → support_whatsapp).
  /// Si null, ContactService utilise son fallback.
  final String? supportPhone;

  /// Contexte transmis dans le message pré-rempli
  /// (ex. "Fiche pharmacie — Pharmacie Centrale").
  final String? contexte;

  const SupportFab({
    super.key,
    this.supportPhone,
    this.contexte,
  });

  void _onTap(BuildContext context) => ContactService.support(
        context,
        supportPhone: supportPhone,
        contexte: contexte,
      );

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // Ce FAB apparaît sur plusieurs écrans à la fois dans la pile de
      // navigation : sans heroTag désactivé, Flutter tente une animation
      // Hero entre deux FAB partageant le tag par défaut et plante.
      heroTag: null,
      onPressed: () => _onTap(context),
      backgroundColor: AppColors.whatsapp,
      foregroundColor: AppColors.white,
      elevation: 1,
      tooltip: 'Contacter le support',
      child: PhosphorIcon(
        PhosphorIcons.whatsappLogo(PhosphorIconsStyle.fill),
        size: 26,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BOUTONS D'ACTION — fiches prestataire / service / pharmacie
// ═══════════════════════════════════════════════════════════

/// Rangée d'actions à placer en bas d'une fiche détail.
///
///   ContactActionsRow(
///     nom: prestataire.nom,
///     telephone: prestataire.telephone,
///     latitude: prestataire.latitude,
///     longitude: prestataire.longitude,
///     messageWhatsapp: "Bonjour, je vous contacte via Daoukro Digital "
///                      "concernant : ${prestataire.metier}",
///   )
class ContactActionsRow extends StatelessWidget {
  final String? telephone;
  final double? latitude;
  final double? longitude;
  final String nom;
  final String? messageWhatsapp;
  final VoidCallback? onItineraire;

  const ContactActionsRow({
    super.key,
    required this.nom,
    this.telephone,
    this.latitude,
    this.longitude,
    this.messageWhatsapp,
    this.onItineraire,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = telephone != null && telephone!.trim().isNotEmpty;
    final hasGeo = onItineraire != null || (latitude != null && longitude != null);

    if (!hasPhone && !hasGeo) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasPhone) ...[
          Expanded(
            child: ContactActionButton(
              icon: PhosphorIcons.phone(PhosphorIconsStyle.fill),
              label: 'Appeler',
              color: AppColors.primary,
              filled: true,
              onTap: () => ContactService.call(context, telephone!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ContactActionButton(
              icon: PhosphorIcons.whatsappLogo(PhosphorIconsStyle.fill),
              label: 'WhatsApp',
              color: AppColors.whatsapp,
              filled: true,
              onTap: () => ContactService.whatsapp(
                context,
                telephone!,
                message: messageWhatsapp ??
                    'Bonjour, je vous contacte via l\'application Daoukro Digital.',
              ),
            ),
          ),
        ],
        if (hasPhone && hasGeo) const SizedBox(width: 8),
        if (hasGeo)
          Expanded(
            child: ContactActionButton(
              icon: PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
              label: 'Itinéraire',
              color: AppColors.secondary,
              filled: false,
              onTap: onItineraire ??
                  () => ContactService.itinerary(
                        context,
                        latitude!,
                        longitude!,
                        label: nom,
                      ),
            ),
          ),
      ],
    );
  }
}

class ContactActionButton extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const ContactActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : AppColors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                icon,
                size: 19,
                color: filled ? AppColors.white : color,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: filled ? AppColors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

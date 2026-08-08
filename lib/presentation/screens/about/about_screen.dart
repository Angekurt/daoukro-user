import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/services/settings_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/action_button.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _ouvrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final card = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary = isDark ? AppColors.white : AppColors.textDark;
    final textSec = isDark ? AppColors.white54 : AppColors.textGrey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(blanc: true),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo / identité app
          Center(
            child: Column(children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 14),
              Text('Daoukro Digital', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 4),
              Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: textSec)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Votre ville en un clic', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // Mon compte (connexion Google optionnelle)
          _Section(
            titre: 'Mon compte',
            card: card,
            textPrimary: textPrimary,
            textSec: textSec,
            child: const _CompteTile(),
          ),
          const SizedBox(height: 16),

          // Apparence (clair / sombre / système)
          _Section(
            titre: 'Apparence',
            card: card,
            textPrimary: textPrimary,
            textSec: textSec,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _ThemeOption(
                    label: 'Système',
                    icone: Icons.brightness_auto_rounded,
                    selectionne: themeMode == ThemeMode.system,
                    isDark: isDark,
                    onTap: () => ref.read(themeModeProvider.notifier).changer(ThemeMode.system),
                  ),
                  const SizedBox(width: 10),
                  _ThemeOption(
                    label: 'Clair',
                    icone: Icons.light_mode_rounded,
                    selectionne: themeMode == ThemeMode.light,
                    isDark: isDark,
                    onTap: () => ref.read(themeModeProvider.notifier).changer(ThemeMode.light),
                  ),
                  const SizedBox(width: 10),
                  _ThemeOption(
                    label: 'Sombre',
                    icone: Icons.dark_mode_rounded,
                    selectionne: themeMode == ThemeMode.dark,
                    isDark: isDark,
                    onTap: () => ref.read(themeModeProvider.notifier).changer(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          _Section(
            titre: "L'application",
            card: card,
            textPrimary: textPrimary,
            textSec: textSec,
            child: Text(
              SettingsService.instance.aProposTexte ??
                  "Daoukro Digital est l'application officielle de la ville de Daoukro, en Côte d'Ivoire. "
                      "Elle centralise les services essentiels : pharmacies de garde, services publics, "
                      "artisans locaux, hébergements, annonces, urgences et actualités de la ville.",
              style: TextStyle(fontSize: 14, color: textSec, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),

          // Contact & support
          _Section(
            titre: 'Contact & Support',
            card: card,
            textPrimary: textPrimary,
            textSec: textSec,
            child: Column(children: [
              _ContactTile(
                icone: Icons.support_agent_rounded,
                label: 'Support WhatsApp',
                valeur: ContactService.display(
                    SettingsService.instance.supportWhatsapp ?? ContactService.supportPhoneFallback),
                couleur: AppColors.whatsapp,
                isDark: isDark,
                onTap: () => ContactService.support(context, contexte: 'Page À propos'),
              ),
              Divider(height: 1, color: isDark ? AppColors.white12 : AppColors.surfaceAlt),
              _ContactTile(
                icone: Icons.email_outlined,
                label: 'Email',
                valeur: SettingsService.instance.supportEmail ?? 'contact@akdev.tech',
                couleur: AppColors.primary,
                isDark: isDark,
                onTap: () => _ouvrir('mailto:${SettingsService.instance.supportEmail ?? 'contact@akdev.tech'}'),
              ),
              Divider(height: 1, color: isDark ? AppColors.white12 : AppColors.surfaceAlt),
              _ContactTile(
                icone: Icons.language_rounded,
                label: 'Site web',
                valeur: 'www.daoukro-digital.akdev.tech',
                couleur: AppColors.primary,
                isDark: isDark,
                onTap: () => _ouvrir('https://www.daoukro-digital.akdev.tech'),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Légal
          _Section(
            titre: 'Informations légales',
            card: card,
            textPrimary: textPrimary,
            textSec: textSec,
            child: Column(children: [
              _LegalTile(label: 'Développé par', valeur: 'AKDEV.TECH', textSec: textSec),
              Divider(height: 1, color: isDark ? AppColors.white12 : AppColors.surfaceAlt),
              _LegalTile(label: 'Plateforme', valeur: 'Android (Flutter)', textSec: textSec),
              Divider(height: 1, color: isDark ? AppColors.white12 : AppColors.surfaceAlt),
              _LegalTile(label: 'Données', valeur: 'Stockage local uniquement', textSec: textSec),
              Divider(height: 1, color: isDark ? AppColors.white12 : AppColors.surfaceAlt),
              _LegalTile(label: "Droits d'auteur", valeur: '© 2026 AKDEV', textSec: textSec),
            ]),
          ),
          const SizedBox(height: 32),

          // CTA support
          ActionButton(
            icone: Icons.support_agent_rounded,
            label: 'Contacter le support',
            couleur: AppColors.whatsapp,
            width: double.infinity,
            onTap: () => ContactService.support(context, contexte: 'Bouton support — page À propos'),
          ),
          const SizedBox(height: 12),
          ActionButton(
            icone: Icons.flag_outlined,
            label: 'Voir mes signalements',
            couleur: AppColors.primary,
            width: double.infinity,
            outlined: true,
            onTap: () => context.push('/signalement'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Section "Mon compte" — connexion Google optionnelle. Ne bloque jamais la
/// navigation : seules certaines actions (ex. déposer un avis) la déclenchent.
class _CompteTile extends ConsumerWidget {
  const _CompteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, _) => _BoutonConnexionGoogle(isDark: isDark),
      data: (user) => user == null
          ? _BoutonConnexionGoogle(isDark: isDark)
          : _ProfilConnecte(user: user, isDark: isDark),
    );
  }
}

class _BoutonConnexionGoogle extends ConsumerWidget {
  final bool isDark;
  const _BoutonConnexionGoogle({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        await ref.read(authProvider.notifier).connecterAvecGoogle();
        final state = ref.read(authProvider);
        if (state.hasError && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString()), backgroundColor: AppColors.danger),
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.login_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Se connecter avec Google',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.textDark)),
            const SizedBox(height: 2),
            Text('Pour publier des avis en votre nom',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.white54 : AppColors.textGrey)),
          ])),
          Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.white24 : AppColors.border, size: 20),
        ]),
      ),
    );
  }
}

class _ProfilConnecte extends ConsumerWidget {
  final UserModel user;
  final bool isDark;
  const _ProfilConnecte({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = isDark ? AppColors.white : AppColors.textDark;
    final textSec = isDark ? AppColors.white54 : AppColors.textGrey;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.nom, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
          if (user.email != null) Text(user.email!, style: TextStyle(fontSize: 12, color: textSec)),
        ])),
        TextButton(
          onPressed: () => ref.read(authProvider.notifier).deconnecter(),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Déconnexion'),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  final Color card;
  final Color textPrimary;
  final Color textSec;
  const _Section({required this.titre, required this.child, required this.card, required this.textPrimary, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(titre.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.8)),
      ),
      Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: child,
      ),
    ]);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  final Color couleur;
  final bool isDark;
  final VoidCallback? onTap;
  const _ContactTile({required this.icone, required this.label, required this.valeur, required this.couleur, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, color: couleur, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.white54 : AppColors.textGrey)),
            const SizedBox(height: 2),
            Text(valeur, style: TextStyle(fontSize: 14, color: isDark ? AppColors.white : AppColors.textDark, fontWeight: FontWeight.w500)),
          ])),
          if (onTap != null) Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.white24 : AppColors.border, size: 20),
        ]),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icone;
  final bool selectionne;
  final bool isDark;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.label,
    required this.icone,
    required this.selectionne,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectionne ? AppColors.primary : (isDark ? AppColors.surfaceDark : AppColors.surfaceAlt),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectionne ? AppColors.primary : (isDark ? AppColors.white12 : AppColors.border),
            ),
          ),
          child: Column(
            children: [
              Icon(icone, size: 20, color: selectionne ? AppColors.white : (isDark ? AppColors.white54 : AppColors.textGrey)),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectionne ? AppColors.white : (isDark ? AppColors.white54 : AppColors.textGrey),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final String label;
  final String valeur;
  final Color textSec;
  const _LegalTile({required this.label, required this.valeur, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: textSec)),
        Text(valeur, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ]),
    );
  }
}

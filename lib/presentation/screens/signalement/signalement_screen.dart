import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/signalement_provider.dart';
import '../../../data/models/signalement_model.dart';

class SignalementScreen extends ConsumerStatefulWidget {
  const SignalementScreen({super.key});
  @override
  ConsumerState<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends ConsumerState<SignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  CategorieSignalement _categorie = CategorieSignalement.voirie;
  bool _loading = false;
  double? _lat, _lng;
  File? _photo;
  final _picker = ImagePicker();

  static const _categories = {
    CategorieSignalement.voirie:    (icone: Icons.construction,            label: 'Voirie',    couleur: AppColors.administration),
    CategorieSignalement.eclairage: (icone: Icons.lightbulb_outline,       label: 'Éclairage', couleur: AppColors.eclairage),
    CategorieSignalement.dechets:   (icone: Icons.delete_outline,          label: 'Déchets',   couleur: AppColors.success),
    CategorieSignalement.eau:       (icone: Icons.water_drop_outlined,     label: 'Eau',       couleur: AppColors.mairie),
    CategorieSignalement.securite:  (icone: Icons.security,                label: 'Sécurité',  couleur: AppColors.dangerVif),
    CategorieSignalement.autre:     (icone: Icons.report_problem_outlined, label: 'Autre',     couleur: AppColors.ardoise),
  };

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _descCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  Future<void> _localiser() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _adresseCtrl.text = 'GPS: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (_) {}
  }

  Future<void> _choisirPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1600);
      if (image != null) setState(() => _photo = File(image.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible d\'accéder à la caméra/galerie.'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _envoyer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final s = SignalementModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categorie: _categorie,
      description: _descCtrl.text.trim(),
      adresse: _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
      latitude: _lat,
      longitude: _lng,
      createdAt: DateTime.now(),
      auteur: _nomCtrl.text.trim().isEmpty ? null : _nomCtrl.text.trim(),
      telephone: _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
      photoPath: _photo?.path,
    );
    await ref.read(signalementsProvider.notifier).ajouter(s);
    setState(() => _loading = false);
    if (!mounted) return;
    _descCtrl.clear();
    _adresseCtrl.clear();
    _nomCtrl.clear();
    _telCtrl.clear();
    setState(() { _lat = null; _lng = null; _photo = null; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: AppColors.white),
        SizedBox(width: 10),
        Text('Signalement envoyé avec succès !'),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final signalements = ref.watch(signalementsProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Signalement citoyen'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'Signalez un problème dans votre quartier. La mairie sera notifiée.',
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                )),
              ]),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Catégorie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: _categories.entries.map((e) {
                    final actif = _categorie == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _categorie = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: actif ? e.value.couleur : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: actif ? e.value.couleur : AppColors.border,
                            width: actif ? 2 : 1,
                          ),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(e.value.icone, color: actif ? AppColors.white : e.value.couleur, size: 28),
                          const SizedBox(height: 6),
                          Text(e.value.label,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: actif ? AppColors.white : AppColors.textDark),
                            textAlign: TextAlign.center),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text('Vos coordonnées (optionnel)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: InputDecoration(
                    hintText: 'Nom ou pseudonyme',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true, fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Numéro de téléphone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true, fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Décrivez le problème (min. 10 caractères)' : null,
                  decoration: InputDecoration(
                    hintText: 'Ex: Nid de poule dangereux devant l\'école...',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Photo (optionnel)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(children: [
                          Image.file(_photo!, height: 160, width: double.infinity, fit: BoxFit.cover),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _photo = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: AppColors.white, size: 18),
                              ),
                            ),
                          ),
                        ]),
                      )
                    : GestureDetector(
                        onTap: _choisirPhoto,
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey, size: 26),
                              SizedBox(height: 6),
                              Text('Ajouter une photo du problème',
                                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 14),
                const Text('Localisation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _adresseCtrl,
                      decoration: InputDecoration(
                        hintText: 'Adresse ou quartier (optionnel)',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _localiser,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _lat != null ? AppColors.primaryLight : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _lat != null ? AppColors.success : AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.my_location, color: _lat != null ? AppColors.success : AppColors.primary, size: 22),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _envoyer,
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_loading ? 'Envoi...' : 'Envoyer le signalement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 28),

            signalements.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (liste) {
                if (liste.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mes signalements (${liste.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    ...liste.take(5).map((s) => _SignalementTile(
                      s: s,
                      config: _categories[s.categorie]!,
                      onSupprimer: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Supprimer ?'),
                            content: const Text('Ce signalement sera supprimé définitivement.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) ref.read(signalementsProvider.notifier).supprimer(s.id);
                      },
                    )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Vignette 44×44 : photo du signalement si disponible (réseau en priorité,
/// puis copie locale), sinon l'icône de catégorie en repli.
class _Vignette extends StatelessWidget {
  final SignalementModel s;
  final ({IconData icone, String label, Color couleur}) config;
  const _Vignette({required this.s, required this.config});

  Widget _icone() => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(color: config.couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
    child: Icon(config.icone, color: config.couleur, size: 20),
  );

  @override
  Widget build(BuildContext context) {
    if (s.photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: s.photoUrl!,
          width: 44, height: 44, fit: BoxFit.cover,
          placeholder: (_, _) => _icone(),
          errorWidget: (_, _, _) => _icone(),
        ),
      );
    }
    if (s.photoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(s.photoPath!),
          width: 44, height: 44, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _icone(),
        ),
      );
    }
    return _icone();
  }
}

class _SignalementTile extends StatelessWidget {
  final SignalementModel s;
  final ({IconData icone, String label, Color couleur}) config;
  final VoidCallback onSupprimer;
  const _SignalementTile({required this.s, required this.config, required this.onSupprimer});

  Color _couleurStatut(StatutSignalement st) {
    switch (st) {
      case StatutSignalement.enAttente: return AppColors.secondary;
      case StatutSignalement.enCours:   return AppColors.mairie;
      case StatutSignalement.resolu:    return AppColors.success;
    }
  }

  String _labelStatut(StatutSignalement st) {
    switch (st) {
      case StatutSignalement.enAttente: return 'En attente';
      case StatutSignalement.enCours:   return 'En cours';
      case StatutSignalement.resolu:    return 'Résolu';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: Row(children: [
      _Vignette(s: s, config: config),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(config.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text(s.description, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _couleurStatut(s.statut).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(_labelStatut(s.statut),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _couleurStatut(s.statut))),
      ),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: onSupprimer,
        child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
      ),
    ]),
  ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
}

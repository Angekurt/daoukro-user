import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/contact_service.dart';
import '../../providers/modules_provider.dart';

class UrgenceDetailScreen extends ConsumerWidget {
  final int id;
  const UrgenceDetailScreen({super.key, required this.id});

  Color _couleurCat(String cat) {
    switch (cat) {
      case 'sante': return AppColors.dangerVif;
      case 'securite': return AppColors.securite;
      case 'incendie': return AppColors.incendie;
      default: return AppColors.ardoiseFonce;
    }
  }

  String _labelCat(String cat) {
    switch (cat) {
      case 'sante': return 'Santé';
      case 'securite': return 'Sécurité';
      case 'incendie': return 'Incendie';
      default: return 'Autre';
    }
  }

  IconData _iconeCat(String cat) {
    switch (cat) {
      case 'sante': return Icons.local_hospital;
      case 'securite': return Icons.local_police;
      case 'incendie': return Icons.local_fire_department;
      default: return Icons.emergency;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(urgencesProvider);
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Urgence'), backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
        body: Center(child: Text(e.toString())),
      ),
      data: (liste) {
        final u = liste.firstWhere((e) => e.id == id, orElse: () => liste.first);
        final couleur = _couleurCat(u.categorie);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: couleur,
                foregroundColor: AppColors.white,
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(u.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  background: Container(
                    color: couleur.withValues(alpha: 0.15),
                    child: Center(child: Icon(_iconeCat(u.categorie), size: 80, color: couleur)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
                        child: Text(_labelCat(u.categorie),
                            style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      if (u.adresse != null) ...[
                        const SizedBox(height: 14),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textGrey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(u.adresse!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey))),
                        ]),
                      ],
                      if (u.description != null) ...[
                        const SizedBox(height: 20),
                        const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(u.description!, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
                      ],
                      const SizedBox(height: 28),
                      const Text('Numéros d\'urgence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      _BoutonAppel(label: u.telephone, couleur: couleur, onTap: () => ContactService.call(context, u.telephone)),
                      if (u.telephone2 != null) ...[
                        const SizedBox(height: 12),
                        _BoutonAppel(label: u.telephone2!, couleur: couleur, onTap: () => ContactService.call(context, u.telephone2!)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BoutonAppel extends StatelessWidget {
  final String label;
  final Color couleur;
  final VoidCallback onTap;
  const _BoutonAppel({required this.label, required this.couleur, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.phone),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

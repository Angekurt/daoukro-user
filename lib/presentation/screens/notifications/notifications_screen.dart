import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/action_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    setState(() {
      _notifications = NotificationService.instance.getNotifications();
    });
  }

  Future<void> _marquerToutesLues() async {
    await NotificationService.instance.marquerToutesLues();
    _charger();
  }

  Future<void> _marquerLue(int index) async {
    await NotificationService.instance.marquerLue(index);
    _charger();
  }

  Future<void> _viderTout() async {
    await NotificationService.instance.supprimerTout();
    _charger();
  }

  Future<void> _supprimerUne(int index) async {
    await NotificationService.instance.supprimerUne(index);
    _charger();
  }

  void _ouvrirNotification(BuildContext context, Map<String, dynamic> n, int index) {
    _marquerLue(index);
    final data = Map<String, dynamic>.from(n['data'] ?? {});
    final type = (data['type'] ?? '').toString();
    final id = data['id']?.toString();

    switch (type) {
      case 'annonce':
        if (id != null) context.push('/annonces/$id');
        break;
      case 'actualite':
        if (id != null) context.push('/actualites/$id');
        break;
      case 'pharmacie':
      case 'sante':
        if (id != null) context.push('/pharmacies/$id');
        else context.push('/pharmacies');
        break;
      case 'service':
      case 'mairie':
        if (id != null) context.push('/services/$id');
        else context.push('/services');
        break;
      case 'urgence':
      case 'alerte':
        context.push('/urgences');
        break;
      default:
        _afficherDetail(context, n);
    }
  }

  void _afficherDetail(BuildContext context, Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n['titre'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text(n['corps'] ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.6)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return "À l'instant";
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return ''; }
  }

  IconData _icone(Map<String, dynamic> data) {
    switch ((data['type'] ?? '').toString()) {
      case 'alerte': case 'urgence': return Icons.warning_amber_rounded;
      case 'sante': case 'pharmacie': return Icons.local_hospital;
      case 'mairie': case 'service': return Icons.account_balance;
      case 'annonce': return Icons.campaign_rounded;
      case 'actualite': return Icons.newspaper_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _couleur(Map<String, dynamic> data) {
    switch ((data['type'] ?? '').toString()) {
      case 'alerte': case 'urgence': return AppColors.sante;
      case 'sante': case 'pharmacie': return AppColors.success;
      case 'mairie': case 'service': return AppColors.primary;
      case 'annonce': return AppColors.info;
      case 'actualite': return AppColors.mairie;
      default: return AppColors.mairie;
    }
  }

  int get _nonLues => _notifications.where((n) => n['lue'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifications'),
          if (_nonLues > 0) ...[ const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12)),
              child: Text('$_nonLues', style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: const BoutonRetour(blanc: true),
        actions: [
          if (_nonLues > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tout marquer lu',
              onPressed: _marquerToutesLues,
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Tout effacer',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Effacer tout ?'),
                    content: const Text('Toutes les notifications seront supprimées.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Effacer', style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
                );
                if (ok == true) _viderTout();
              },
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.border),
              const SizedBox(height: 16),
              Text('Aucune notification', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Text('Vous serez alerté des actualités\net urgences de Daoukro',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _notifications[i];
                final data = Map<String, dynamic>.from(n['data'] ?? {});
                final lue = n['lue'] == true;
                final couleur = _couleur(data);
                return Dismissible(
                  key: ValueKey('${n['date']}_${n['titre']}_$i'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _supprimerUne(i),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 0),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.delete_outline, color: AppColors.white),
                  ),
                  child: GestureDetector(
                  onTap: () => _ouvrirNotification(context, n, i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lue ? AppColors.white : couleur.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: lue ? AppColors.border : couleur.withValues(alpha: 0.2)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_icone(data), color: couleur, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(n['titre'] ?? '',
                            style: TextStyle(fontSize: 14, fontWeight: lue ? FontWeight.w500 : FontWeight.w700, color: AppColors.textDark))),
                          if (!lue)
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: couleur, shape: BoxShape.circle)),
                        ]),
                        if ((n['corps'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(n['corps'], style: const TextStyle(fontSize: 13, color: AppColors.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 6),
                        Row(children: [
                          Text(_formatDate(n['date'] ?? ''), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const Spacer(),
                          Text('Voir →', style: TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w600)),
                        ]),
                      ])),
                    ]),
                  ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 40));
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../core/constants/app_colors.dart';

/// Bouton de partage animé — utilisable sur toutes les pages détail
class ShareButton extends StatefulWidget {
  final String titre;
  final String? detail;
  final String? telephone;
  final String? adresse;
  final String type; // pharmacie, artisan, etc.

  const ShareButton({
    super.key,
    required this.titre,
    required this.type,
    this.detail,
    this.telephone,
    this.adresse,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _buildMessage() {
    final buf = StringBuffer();
    buf.writeln('📍 ${widget.titre}');
    if (widget.detail != null) buf.writeln('   ${widget.detail}');
    if (widget.adresse != null) buf.writeln('📌 ${widget.adresse}');
    if (widget.telephone != null) buf.writeln('📞 ${widget.telephone}');
    buf.writeln();
    buf.writeln('Trouvé sur Daoukro Digital — Votre ville en un clic');
    return buf.toString().trim();
  }

  void _partager() async {
    HapticFeedback.mediumImpact();
    await Share.share(_buildMessage());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); _partager(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Partager', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

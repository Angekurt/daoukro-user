import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Bouton d'action animé avec effet de scale + haptic feedback
/// Utilisé sur toutes les pages détail
class ActionButton extends StatefulWidget {
  final IconData icone;
  final String label;
  final Color couleur;
  final bool outlined;
  final VoidCallback onTap;
  final double? width;

  const ActionButton({
    super.key,
    required this.icone,
    required this.label,
    required this.couleur,
    required this.onTap,
    this.outlined = false,
    this.width,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    HapticFeedback.lightImpact();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.width,
          child: widget.outlined
              ? OutlinedButton.icon(
                  onPressed: null, // géré par GestureDetector
                  icon: Icon(widget.icone),
                  label: Text(widget.label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.couleur,
                    side: BorderSide(color: widget.couleur, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(widget.icone),
                  label: Text(widget.label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.couleur,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: widget.couleur,
                    disabledForegroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Bouton retour animé standard pour toutes les pages
class BoutonRetour extends StatefulWidget {
  final bool blanc;
  const BoutonRetour({super.key, this.blanc = false});

  @override
  State<BoutonRetour> createState() => _BoutonRetourState();
}

class _BoutonRetourState extends State<BoutonRetour>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.85, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          HapticFeedback.lightImpact();
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            router.go('/');
          }
        },
        onTapCancel: () => _ctrl.forward(),
        child: ScaleTransition(
          scale: _ctrl,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.blanc
                  ? AppColors.white.withValues(alpha: 0.25)
                  : AppColors.white,
              shape: BoxShape.circle,
              border: widget.blanc
                  ? null
                  : Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: widget.blanc ? AppColors.white : AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

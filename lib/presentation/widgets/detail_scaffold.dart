import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Scaffold standard pour toutes les pages détail.
/// Règle le problème d'écran noir en garantissant un fond blanc.
class DetailScaffold extends StatelessWidget {
  final Widget body;
  const DetailScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: body,
    );
  }
}

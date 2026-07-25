import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

/// Bandeau discret affiché en haut de l'app dès que la connexion est perdue.
/// À placer une seule fois, au niveau du shell de l'application (main.dart).
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _horsLigne = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _verifierEtat();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      setState(() => _horsLigne = results.every((r) => r == ConnectivityResult.none));
    });
  }

  Future<void> _verifierEtat() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) setState(() => _horsLigne = results.every((r) => r == ConnectivityResult.none));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _horsLigne
              ? Container(
                  width: double.infinity,
                  color: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PhosphorIcon(PhosphorIconsRegular.wifiSlash, size: 14, color: AppColors.white),
                        const SizedBox(width: 8),
                        const Text('Hors connexion — affichage des données en cache',
                            style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

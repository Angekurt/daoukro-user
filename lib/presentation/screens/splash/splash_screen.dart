import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/analytics_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();

    // Naviguer après 2.5s
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    await AnalyticsService.instance.verifierDemandeAvis();
    if (!mounted) return;
    context.go(done ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône principale
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Nom de l'app
                    const Text(
                      'Daoukro Digital',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre ville en un clic',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Indicateur discret
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

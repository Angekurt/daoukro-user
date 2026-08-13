import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/analytics_service.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/about/about_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/carte_screen.dart';
import '../presentation/screens/pharmacies/pharmacies_list_screen.dart';
import '../presentation/screens/pharmacies/pharmacie_detail_screen.dart';
import '../presentation/screens/pharmacies/gardes_screen.dart';
import '../presentation/screens/services/services_list_screen.dart';
import '../presentation/screens/services/service_detail_screen.dart';
import '../presentation/screens/itineraire/itineraire_screen.dart';
import '../presentation/screens/hebergement/hebergements_list_screen.dart';
import '../presentation/screens/hebergement/hebergement_detail_screen.dart';
import '../presentation/screens/immobilier/immobilier_list_screen.dart';
import '../presentation/screens/immobilier/immobilier_detail_screen.dart';
import '../presentation/screens/artisans/artisans_list_screen.dart';
import '../presentation/screens/artisans/artisan_detail_screen.dart';
import '../presentation/screens/urgences/urgences_screen.dart';
import '../presentation/screens/urgences/urgence_detail_screen.dart';
import '../presentation/screens/actualites/actualites_list_screen.dart';
import '../presentation/screens/actualites/actualite_detail_screen.dart';
import '../presentation/screens/annonces/annonces_list_screen.dart';
import '../presentation/screens/annonces/annonce_detail_screen.dart';
import '../presentation/screens/signalement/signalement_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../core/constants/app_colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  observers: AnalyticsService.instance.observers,
  redirect: (context, state) async {
    // Splash et onboarding gérés directement, pas de redirect
    if (state.matchedLocation == '/splash') return null;
    if (state.matchedLocation == '/onboarding') return null;
    return null;
  },
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (_, _) => const SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),

    // À propos
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (_, _) => const AboutScreen(),
    ),

    // Shell avec bottom nav — routes principales
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/carte', builder: (_, _) => const CarteScreen()),
        GoRoute(path: '/pharmacies', builder: (_, _) => const PharmaciesListScreen()),
        GoRoute(path: '/gardes', builder: (_, _) => const GardesScreen()),
        GoRoute(path: '/services', builder: (_, _) => const ServicesListScreen()),
        GoRoute(path: '/hebergements', builder: (_, _) => const HebergementsListScreen()),
        GoRoute(path: '/immobilier', builder: (_, _) => const ImmobilierListScreen()),
        GoRoute(path: '/artisans', builder: (_, _) => const ArtisansListScreen()),
        GoRoute(path: '/urgences', builder: (_, _) => const UrgencesScreen()),
        GoRoute(path: '/actualites', builder: (_, _) => const ActualitesListScreen()),
        GoRoute(path: '/annonces', builder: (_, _) => const AnnoncesListScreen()),
      ],
    ),
    // Pages détail — avec parentNavigatorKey pour s'afficher par-dessus le shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/pharmacies/:id',
      builder: (_, state) => PharmacieDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/services/:id',
      builder: (_, state) => ServiceDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/hebergements/:id',
      builder: (_, state) => HebergementDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/immobilier/:id',
      builder: (_, state) => ImmobilierDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/artisans/:id',
      builder: (_, state) => ArtisanDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/urgences/:id',
      builder: (_, state) => UrgenceDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/actualites/:id',
      builder: (_, state) => ActualiteDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/annonces/:id',
      builder: (_, state) => AnnoncDetailScreen(
          id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/signalement',
      builder: (_, _) => const SignalementScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/notifications',
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/itineraire',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ItineraireScreen(
          destLat: extra['lat'] as double,
          destLng: extra['lng'] as double,
          nomDestination: extra['nom'] as String,
        );
      },
    ),
  ],
);

// ─── SHELL PRINCIPAL ─────────────────────────────────────────────────────────
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc == '/') return 0;
    if (loc == '/carte') return 1;
    if (loc == '/pharmacies' || loc == '/gardes') return 2;
    if (loc == '/services') return 3;
    if (loc == '/hebergements' || loc == '/immobilier' || loc == '/artisans' ||
        loc == '/urgences' || loc == '/actualites' || loc == '/annonces') {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: null,
      bottomNavigationBar: _BottomNav(
        currentIndex: _index(context),
        onTap: (i) {
          switch (i) {
            case 0: context.go('/'); break;
            case 1: context.go('/carte'); break;
            case 2: context.go('/pharmacies'); break;
            case 3: context.go('/services'); break;
            case 4: context.go('/annonces'); break;
          }
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icone: Icons.home_outlined, label: 'Accueil', actif: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icone: Icons.map_outlined, label: 'Carte', actif: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icone: Icons.local_pharmacy_outlined, label: 'Pharmacies', actif: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icone: Icons.account_balance_outlined, label: 'Services', actif: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icone: Icons.apps_outlined, label: 'Plus', actif: currentIndex == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icone;
  final String label;
  final bool actif;
  final VoidCallback onTap;
  const _NavItem({required this.icone, required this.label, required this.actif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icone, color: actif ? AppColors.primary : AppColors.textGrey, size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: actif ? FontWeight.w600 : FontWeight.normal,
                  color: actif ? AppColors.primary : AppColors.textGrey)),
        ]),
      ),
    );
  }
}


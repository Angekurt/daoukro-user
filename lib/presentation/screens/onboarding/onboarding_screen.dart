import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icone: Icons.location_city,
      titre: 'Bienvenue à Daoukro',
      description:
          'Accédez à tous les services essentiels de votre ville en un seul endroit.',
      couleur: AppColors.primary,
    ),
    _OnboardingData(
      icone: Icons.local_pharmacy,
      titre: 'Pharmacies de Garde',
      description:
          'Trouvez facilement les pharmacies ouvertes près de vous, même la nuit.',
      couleur: AppColors.success,
    ),
    _OnboardingData(
      icone: Icons.account_balance,
      titre: 'Services Publics',
      description:
          'Mairie, hôpital, police, gendarmerie... tout est à portée de main.',
      couleur: AppColors.securite,
    ),
  ];

  Future<void> _terminer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton passer
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _terminer,
                child: const Text(
                  'Passer',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône
                        index == 0
                          ? Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: page.couleur.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(page.icone, size: 64, color: page.couleur),
                            ),

                        const SizedBox(height: 48),

                        // Titre
                        Text(
                          page.titre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicateur de page
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.primary.withValues(alpha: 0.3),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),

            const SizedBox(height: 32),

            // Bouton suivant / démarrer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _terminer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Suivant' : 'Démarrer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icone;
  final String titre;
  final String description;
  final Color couleur;

  _OnboardingData({
    required this.icone,
    required this.titre,
    required this.description,
    required this.couleur,
  });
}
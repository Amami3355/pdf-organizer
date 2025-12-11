import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/services/storage_service.dart';

/// 📱 Onboarding Screen
/// 
/// First-launch tutorial with feature highlights.

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final pages = [
      _OnboardingPage(
        icon: Icons.document_scanner,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      _OnboardingPage(
        icon: Icons.folder_copy,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingPage(
        icon: Icons.edit_document,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
      _OnboardingPage(
        icon: Icons.cloud_sync,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
      ),
    ];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  l10n.skip,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),
            
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 40),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == pages.length - 1
                  ? PrimaryButton(
                      label: l10n.getStarted,
                      onPressed: _finishOnboarding,
                    )
                  : PrimaryButton(
                      label: l10n.continue_,
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  Future<void> _finishOnboarding() async {
    await StorageService.instance.setHasSeenOnboarding(true);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  
  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  
  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.document_scanner,
      title: 'Scan Documents',
      description: 'Quickly scan documents with your camera and convert them to high-quality PDFs.',
    ),
    _OnboardingPage(
      icon: Icons.folder_copy,
      title: 'Organize Files',
      description: 'Keep all your documents organized with folders, tags, and smart search.',
    ),
    _OnboardingPage(
      icon: Icons.edit_document,
      title: 'Edit & Sign',
      description: 'Add signatures, annotations, and merge multiple PDFs with ease.',
    ),
    _OnboardingPage(
      icon: Icons.cloud_sync,
      title: 'Sync Everywhere',
      description: 'Access your documents from any device with secure cloud sync.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Text(
                  'Skip',
                  style: TextStyle(
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
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 40),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == _pages.length - 1
                  ? PrimaryButton(
                      label: 'Get Started',
                      onPressed: _finishOnboarding,
                    )
                  : PrimaryButton(
                      label: 'Continue',
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
            style: TextStyle(
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

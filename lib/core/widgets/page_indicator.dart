import 'package:flutter/material.dart';

/// 🔘 Reusable Page Indicator Widget
///
/// Extracted from OnboardingScreen for reuse in carousels, tutorials, etc.
/// Displays animated dots indicating current page position.

class PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  
  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => _PageIndicatorDot(
          isActive: currentPage == index,
          activeColor: activeColor ?? Theme.of(context).primaryColor,
          inactiveColor: inactiveColor ?? Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

class _PageIndicatorDot extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicatorDot({
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

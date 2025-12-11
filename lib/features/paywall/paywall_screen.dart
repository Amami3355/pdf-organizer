import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/providers.dart';

/// 💰 Paywall Screen
/// 
/// Lifetime purchase screen with features list.
/// Uses Riverpod for reactive state management.

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close, color: Theme.of(context).hintColor),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Premium icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      l10n.unlockProTitle(AppConstants.appName),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      l10n.oneTimePayment,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Features list
                    _buildFeatureItem(context, Icons.all_inclusive, l10n.featureUnlimitedPdf),
                    _buildFeatureItem(context, Icons.cloud_sync, l10n.featureCloudSync),
                    _buildFeatureItem(context, Icons.security, l10n.featureAdvancedEncryption),
                    _buildFeatureItem(context, Icons.support_agent, l10n.featurePrioritySupport),
                    _buildFeatureItem(context, Icons.update, l10n.featureFreeUpdates),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Purchase buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PrimaryButton(
                    label: l10n.getLifetimeAccess,
                    icon: Icons.lock_open,
                    isLoading: _isLoading,
                    onPressed: _purchase,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _restore,
                    child: Text(
                      l10n.restorePurchases,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
  
  Future<void> _purchase() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    
    try {
      // Use Riverpod provider instead of direct service call
      final success = await ref.read(purchaseProvider.notifier).purchaseLifetime();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.thankYouPurchase)),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.purchaseCancelledOrUnavailable)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    LoadingOverlay.show(context, message: l10n.restoring);
    
    try {
      // Use Riverpod provider instead of direct service call
      final restored = await ref.read(purchaseProvider.notifier).restore();
      
      if (mounted) {
        LoadingOverlay.hide(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored 
                  ? l10n.purchasesRestoredSuccess 
                  : l10n.noPreviousPurchases,
            ),
          ),
        );
        
        if (restored) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
      }
    }
  }
}

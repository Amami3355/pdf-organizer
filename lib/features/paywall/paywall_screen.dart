import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/purchase_service.dart';

/// 💰 Paywall Screen
/// 
/// Lifetime purchase screen with features list.

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
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
                            color: AppColors.primary.withValues(alpha: 0.4),
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
                      'Unlock ${AppConstants.appName} Pro',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'One-time payment. Lifetime access.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Features list
                    _buildFeatureItem(Icons.all_inclusive, 'Unlimited PDF processing'),
                    _buildFeatureItem(Icons.cloud_sync, 'Cloud sync across devices'),
                    _buildFeatureItem(Icons.security, 'Advanced encryption'),
                    _buildFeatureItem(Icons.support_agent, 'Priority support'),
                    _buildFeatureItem(Icons.update, 'Free lifetime updates'),
                    
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
                    label: 'Get Lifetime Access',
                    icon: Icons.lock_open,
                    isLoading: _isLoading,
                    onPressed: _purchase,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _restore,
                    child: const Text(
                      'Restore Purchases',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
  
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
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
    setState(() => _isLoading = true);
    
    try {
      final success = await PurchaseService.instance.purchaseLifetime();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you for your purchase!')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase cancelled or unavailable')),
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
    LoadingOverlay.show(context, message: 'Restoring...');
    
    try {
      final restored = await PurchaseService.instance.restore();
      
      if (mounted) {
        LoadingOverlay.hide(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored 
                  ? 'Purchases restored successfully!' 
                  : 'No previous purchases found.',
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

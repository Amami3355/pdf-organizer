import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../core/widgets/settings_tile.dart';
import '../../core/widgets/app_card.dart';
import '../../core/services/purchase_service.dart';

/// ⚙️ Settings Screen
/// 
/// App settings with cross-promotion section.

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pro Status Banner
            _buildProBanner(context),
            
            // Purchases Section
            SettingsSection(
              title: 'Purchases',
              children: [
                SettingsTile(
                  icon: Icons.workspace_premium,
                  title: 'Upgrade to Pro',
                  subtitle: 'Unlock all features',
                  iconColor: Colors.amber,
                  onTap: () => context.push(AppRoutes.paywall),
                ),
                SettingsTile(
                  icon: Icons.restore,
                  title: 'Restore Purchases',
                  onTap: () => _restorePurchases(context),
                ),
              ],
            ),
            
            // General Section
            SettingsSection(
              title: 'General',
              children: [
                SettingsTile(
                  icon: Icons.star_rate,
                  title: 'Rate the App',
                  iconColor: Colors.orange,
                  onTap: _rateApp,
                ),
                SettingsTile(
                  icon: Icons.share,
                  title: 'Share with Friends',
                  iconColor: AppColors.primary,
                  onTap: _shareApp,
                ),
                SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Contact Support',
                  onTap: _contactSupport,
                ),
              ],
            ),
            
            // Legal Section
            SettingsSection(
              title: 'Legal',
              children: [
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _openUrl(AppConstants.termsOfServiceUrl),
                ),
              ],
            ),
            
            // Cross-Promo Section
            const SizedBox(height: 24),
            _buildCrossPromoSection(context),
            
            // Version
            const SizedBox(height: 32),
            Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProBanner(BuildContext context) {
    if (PurchaseService.instance.isPro) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B85FF), Color(0xFF0056D2)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Colors.white, size: 32),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'All features unlocked',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  Widget _buildCrossPromoSection(BuildContext context) {
    if (OtherApps.apps.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'MORE APPS BY US',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: OtherApps.apps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final app = OtherApps.apps[index];
              return CrossPromoCard(
                name: app['name']!,
                description: app['description']!,
                iconPath: app['icon'],
                onTap: () {
                  final url = (!kIsWeb && Platform.isIOS)
                      ? app['iosUrl']!
                      : app['androidUrl']!;
                  _openUrl(url);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Future<void> _restorePurchases(BuildContext context) async {
    final restored = await PurchaseService.instance.restore();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored 
                ? 'Purchases restored successfully!' 
                : 'No previous purchases found.',
          ),
        ),
      );
    }
  }
  
  Future<void> _rateApp() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
  
  void _shareApp() {
    final url = (!kIsWeb && Platform.isIOS) 
        ? AppConstants.appStoreUrl 
        : AppConstants.playStoreUrl;
    Share.share(
      'Check out ${AppConstants.appName}! $url',
      subject: AppConstants.appName,
    );
  }
  
  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: 'subject=${AppConstants.appName} Support',
    );
    await launchUrl(uri);
  }
  
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

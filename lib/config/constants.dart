// ⚙️ Micro-SaaS Factory: App Constants
//
// All configurable values in one place.
// Update these for each new app.

class AppConstants {
  // App Info
  static const String appName = 'PDF Organizer';
  static const String appVersion = '1.0.0';
  
  // 💰 RevenueCat Configuration
  // Your RevenueCat public API key
  static const String revenueCatApiKey = 'test_keneRPXbFxNPZPubzBptqWXUFqN';
  static const String revenueCatApiKeyIOS = revenueCatApiKey;
  static const String revenueCatApiKeyAndroid = revenueCatApiKey;
  static const String lifetimeEntitlementId = 'pro';
  static const String lifetimeProductId = 'pdf_organizer_lifetime';
  
  // URLs
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@example.com';
  
  // App Store URLs (for cross-promo)
  static const String appStoreUrl = 'https://apps.apple.com/app/id0000000000';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.pdforganizer';
  
  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableOnboarding = true;
}

/// 🔄 Cross-Promotion: Other Apps
/// 
/// Add your other apps here for the "More Apps" section in Settings.
class OtherApps {
  static const List<Map<String, String>> apps = [];
}

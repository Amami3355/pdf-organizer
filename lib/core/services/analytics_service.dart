import 'package:flutter/foundation.dart';

/// 📊 Micro-SaaS Factory: Analytics Service
/// 
/// Optional analytics tracking placeholder.
/// Replace with your preferred analytics solution (PostHog, Firebase, etc.)
/// 
/// Usage:
/// ```dart
/// AnalyticsService.instance.logEvent('button_clicked', {'button': 'purchase'});
/// AnalyticsService.instance.setUserProperty('plan', 'pro');
/// ```

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();
  
  bool _isInitialized = false;
  
  /// Initialize analytics.
  /// Call this in main() if analytics is enabled.
  Future<void> init() async {
    if (_isInitialized) return;
    
    // TODO: Initialize your analytics SDK here
    // Example with PostHog:
    // await Posthog().setup(PostHogConfig('YOUR_API_KEY'));
    
    _isInitialized = true;
    debugPrint('AnalyticsService: Initialized (placeholder)');
  }
  
  /// Log a custom event.
  void logEvent(String name, [Map<String, dynamic>? properties]) {
    if (!_isInitialized) return;
    
    // TODO: Send event to your analytics
    debugPrint('Analytics: $name ${properties ?? {}}');
  }
  
  /// Set a user property.
  void setUserProperty(String name, dynamic value) {
    if (!_isInitialized) return;
    
    // TODO: Set user property in your analytics
    debugPrint('Analytics: Set property $name = $value');
  }
  
  /// Identify a user (after login/signup).
  void identify(String userId, [Map<String, dynamic>? traits]) {
    if (!_isInitialized) return;
    
    // TODO: Identify user in your analytics
    debugPrint('Analytics: Identify $userId ${traits ?? {}}');
  }
  
  /// Track screen view.
  void logScreenView(String screenName) {
    logEvent('screen_view', {'screen': screenName});
  }
  
  /// Track purchase.
  void logPurchase(String productId, double price) {
    logEvent('purchase', {
      'product_id': productId,
      'price': price,
    });
  }
}

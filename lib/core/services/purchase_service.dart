import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../config/constants.dart';
import 'storage_service.dart';

/// 💰 Micro-SaaS Factory: Purchase Service
/// 
/// RevenueCat integration for lifetime purchases.
/// Singleton pattern for global access.
/// 
/// Usage:
/// ```dart
/// // Initialize on app start
/// await PurchaseService.instance.init();
/// 
/// // Check pro status
/// if (PurchaseService.instance.isPro) { ... }
/// 
/// // Purchase
/// await PurchaseService.instance.purchaseLifetime();
/// ```

class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();
  
  bool _isPro = false;
  bool _isInitialized = false;
  
  /// Whether the user has purchased the lifetime plan.
  /// Cached locally for offline-first access.
  bool get isPro => _isPro;
  
  /// Whether RevenueCat has been initialized.
  bool get isInitialized => _isInitialized;
  
  /// Initialize RevenueCat SDK.
  /// Call this in main() before runApp().
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Load cached pro status for instant offline access
    _isPro = await StorageService.instance.getProStatus();
    
    // Skip RevenueCat on web
    if (kIsWeb) {
      _isInitialized = true;
      debugPrint('PurchaseService: Web platform, skipping RevenueCat');
      return;
    }
    
    try {
      final apiKey = Platform.isIOS 
          ? AppConstants.revenueCatApiKeyIOS 
          : AppConstants.revenueCatApiKeyAndroid;
      
      // Skip if using placeholder keys
      if (apiKey.startsWith('YOUR_')) {
        debugPrint('PurchaseService: Using placeholder API key, skipping init');
        _isInitialized = true;
        return;
      }
      
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      
      // Check current entitlements
      await _refreshProStatus();
      
      // Listen for updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateProStatus(customerInfo);
      });
      
      _isInitialized = true;
      debugPrint('PurchaseService: Initialized, isPro = $_isPro');
    } catch (e) {
      debugPrint('PurchaseService: Init error - $e');
      _isInitialized = true; // Still mark as initialized to avoid retries
    }
  }
  
  /// Trigger the lifetime purchase flow.
  /// Returns true if purchase was successful.
  Future<bool> purchaseLifetime() async {
    if (kIsWeb) {
      debugPrint('PurchaseService: Purchases not available on web');
      return false;
    }
    
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      
      if (offering == null) {
        debugPrint('PurchaseService: No offerings available');
        return false;
      }
      
      // Find the lifetime package
      final package = offering.lifetime ?? offering.availablePackages.firstOrNull;
      
      if (package == null) {
        debugPrint('PurchaseService: No lifetime package found');
        return false;
      }
      
      final result = await Purchases.purchasePackage(package);
      _updateProStatus(result);
      
      return _isPro;
    } catch (e) {
      debugPrint('PurchaseService: Purchase error - $e');
      return false;
    }
  }
  
  /// Restore previous purchases.
  /// Returns true if a valid purchase was found.
  Future<bool> restore() async {
    if (kIsWeb) {
      debugPrint('PurchaseService: Restore not available on web');
      return false;
    }
    
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('PurchaseService: Restore error - $e');
      return false;
    }
  }
  
  Future<void> _refreshProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);
    } catch (e) {
      debugPrint('PurchaseService: Refresh error - $e');
    }
  }
  
  void _updateProStatus(CustomerInfo customerInfo) {
    final hasEntitlement = customerInfo.entitlements.active
        .containsKey(AppConstants.lifetimeEntitlementId);
    
    if (hasEntitlement != _isPro) {
      _isPro = hasEntitlement;
      // Persist for offline access
      StorageService.instance.setProStatus(_isPro);
      debugPrint('PurchaseService: Pro status updated to $_isPro');
    }
  }
}

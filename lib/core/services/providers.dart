import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'purchase_service.dart';

/// 💰 Purchase Provider (Riverpod)
/// 
/// Reactive state management for purchase status.
/// Wraps PurchaseService for reactive UI updates.

class PurchaseNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initialize with cached value
    return PurchaseService.instance.isPro;
  }
  
  /// Purchase lifetime access.
  /// Returns true if successful.
  Future<bool> purchaseLifetime() async {
    final success = await PurchaseService.instance.purchaseLifetime();
    if (success) {
      state = true;
    }
    return success;
  }
  
  /// Restore previous purchases.
  /// Returns true if a valid purchase was found.
  Future<bool> restore() async {
    final restored = await PurchaseService.instance.restore();
    if (restored) {
      state = true;
    }
    return restored;
  }
  
  /// Refresh pro status from server.
  Future<void> refresh() async {
    // Re-read from service after it syncs
    state = PurchaseService.instance.isPro;
  }
}

/// Provider for purchase/pro status
final purchaseProvider = NotifierProvider<PurchaseNotifier, bool>(
  PurchaseNotifier.new,
);

/// Convenience provider to check if user is pro
final isProProvider = Provider<bool>((ref) {
  return ref.watch(purchaseProvider);
});

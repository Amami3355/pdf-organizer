import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'purchase_service.dart';
import 'storage_service.dart';

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

// ─────────────────────────────────────────────────────────────────
// 🎨 Theme Provider (Riverpod)
// ─────────────────────────────────────────────────────────────────

/// Theme mode notifier for dark/light mode toggle.
/// Persists user preference via StorageService.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Initialize from stored preference
    final isDarkMode = StorageService.instance.isDarkMode;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  
  /// Toggle between dark and light mode.
  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      StorageService.instance.setDarkMode(false);
    } else {
      state = ThemeMode.dark;
      StorageService.instance.setDarkMode(true);
    }
  }
  
  /// Set to a specific theme mode.
  void setThemeMode(ThemeMode mode) {
    state = mode;
    StorageService.instance.setDarkMode(mode == ThemeMode.dark);
  }
  
  /// Check if currently in dark mode.
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Provider for theme mode (dark/light)
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

/// Convenience provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider) == ThemeMode.dark;
});

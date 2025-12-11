import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 💾 Micro-SaaS Factory: Storage Service
/// 
/// SharedPreferences wrapper for persistent settings.
/// Singleton pattern for global access.
/// 
/// Usage:
/// ```dart
/// // Initialize on app start
/// await StorageService.instance.init();
/// 
/// // Use
/// await StorageService.instance.setBool('darkMode', true);
/// final isDark = StorageService.instance.getBool('darkMode');
/// ```

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  
  SharedPreferences? _prefs;
  
  // Keys
  static const String _keyProStatus = 'is_pro_user';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyDarkMode = 'dark_mode';
  
  /// Initialize SharedPreferences.
  /// Call this in main() before runApp().
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    debugPrint('StorageService: Initialized');
  }
  
  SharedPreferences get _safePrefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  // ─────────────────────────────────────────────────────────────────
  // Pro Status (for offline-first purchase verification)
  // ─────────────────────────────────────────────────────────────────
  
  Future<bool> getProStatus() async {
    await init();
    return _safePrefs.getBool(_keyProStatus) ?? false;
  }
  
  Future<void> setProStatus(bool isPro) async {
    await init();
    await _safePrefs.setBool(_keyProStatus, isPro);
  }
  
  // ─────────────────────────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────────────────────────
  
  bool get hasSeenOnboarding =>
      _safePrefs.getBool(_keyHasSeenOnboarding) ?? false;
  
  Future<void> setHasSeenOnboarding(bool value) async {
    await _safePrefs.setBool(_keyHasSeenOnboarding, value);
  }
  
  // ─────────────────────────────────────────────────────────────────
  // Theme
  // ─────────────────────────────────────────────────────────────────
  
  bool get isDarkMode => _safePrefs.getBool(_keyDarkMode) ?? true;
  
  Future<void> setDarkMode(bool value) async {
    await _safePrefs.setBool(_keyDarkMode, value);
  }
  
  // ─────────────────────────────────────────────────────────────────
  // Generic Methods
  // ─────────────────────────────────────────────────────────────────
  
  String? getString(String key) => _safePrefs.getString(key);
  
  Future<void> setString(String key, String value) async {
    await _safePrefs.setString(key, value);
  }
  
  bool? getBool(String key) => _safePrefs.getBool(key);
  
  Future<void> setBool(String key, bool value) async {
    await _safePrefs.setBool(key, value);
  }
  
  int? getInt(String key) => _safePrefs.getInt(key);
  
  Future<void> setInt(String key, int value) async {
    await _safePrefs.setInt(key, value);
  }
  
  Future<void> remove(String key) async {
    await _safePrefs.remove(key);
  }
  
  Future<void> clear() async {
    await _safePrefs.clear();
  }
}

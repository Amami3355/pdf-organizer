import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/document_manager.dart';
import 'core/services/providers.dart';

/// 🏭 PDF Organizer - Micro-SaaS Factory Architecture
///
/// Entry point with service initialization and Riverpod state management.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await Hive.initFlutter();
  await StorageService.instance.init();
  await PurchaseService.instance.init();
  await DocumentManager.instance.init();

  // Optional: Initialize analytics
  if (AppConstants.enableAnalytics) {
    await AnalyticsService.instance.init();
  }

  // Wrap app with ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode for reactive theme switching
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // 🎨 Dynamic theme support
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: appRouter,

      // 🌍 Internationalization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Use device locale, fallback to English
      locale: null, // null = auto-detect
    );
  }
}

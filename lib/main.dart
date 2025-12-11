import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/analytics_service.dart';

/// 🏭 PDF Organizer - Micro-SaaS Factory Architecture
/// 
/// Entry point with service initialization.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await StorageService.instance.init();
  await PurchaseService.instance.init();
  
  // Optional: Initialize analytics
  if (AppConstants.enableAnalytics) {
    await AnalyticsService.instance.init();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

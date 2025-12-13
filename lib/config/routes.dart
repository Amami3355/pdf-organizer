import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/editor/editor_screen.dart';
import '../features/editor/edit_page_screen.dart';
import '../features/editor/manage_pages_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/camera/camera_screen.dart';

/// 🧭 Micro-SaaS Factory: Router Configuration
/// 
/// All app routes defined in one place.
/// Uses GoRouter for declarative, URL-based navigation.

class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
  static const String onboarding = '/onboarding';
  static const String camera = '/camera';
  static const String editPage = '/edit-page/:id'; // Added new route constant
  static const String managePages = '/manage-pages/:id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.editor,
      builder: (context, state) => const EditorScreen(),
    ),
    GoRoute(
      path: AppRoutes.editPage, // Added new route
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditPageScreen(pageId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.managePages,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ManagePagesScreen(documentId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.paywall,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.camera,
      builder: (context, state) => const CameraScreen(),
    ),
  ],
);

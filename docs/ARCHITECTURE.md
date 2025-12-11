# Micro-SaaS Factory Architecture

## Overview

The **Micro-SaaS Factory** is an architectural pattern designed to accelerate the development of mobile SaaS applications. It provides a reusable foundation that can be quickly customized for new app ideas.

## Core Principles

### 1. Separation of Concerns

```
┌─────────────────────────────────────────────────────────────┐
│                        FEATURES                              │
│  (App-specific screens and logic - CHANGES per app)          │
├─────────────────────────────────────────────────────────────┤
│                          CORE                                │
│  (Reusable services & widgets - STAYS the same)              │
├─────────────────────────────────────────────────────────────┤
│                         CONFIG                               │
│  (Theme, routes, constants - CUSTOMIZE per app)              │
└─────────────────────────────────────────────────────────────┘
```

### 2. The Three Layers

| Layer | Purpose | Modification Frequency |
|-------|---------|----------------------|
| **Config** | App identity (colors, keys, URLs) | Once per app |
| **Core** | Business logic infrastructure | Rarely |
| **Features** | UI screens and app logic | Frequently |

---

## Directory Structure

```
lib/
├── config/                    # 🎨 App Configuration
│   ├── theme.dart             # Colors, typography, ThemeData
│   ├── routes.dart            # GoRouter navigation setup
│   └── constants.dart         # API keys, URLs, feature flags
│
├── core/                      # 🔧 Reusable Infrastructure
│   ├── services/
│   │   ├── purchase_service.dart   # RevenueCat integration
│   │   ├── storage_service.dart    # SharedPreferences wrapper
│   │   └── analytics_service.dart  # Analytics placeholder
│   │
│   └── widgets/
│       ├── primary_button.dart     # CTA buttons with loading
│       ├── app_card.dart           # Cards & cross-promo
│       ├── settings_tile.dart      # Settings menu items
│       └── loading_overlay.dart    # Full-screen loading
│
├── features/                  # 📱 App-Specific Screens
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── data/
│   │   ├── models/
│   │   └── widgets/
│   ├── editor/
│   ├── settings/
│   ├── paywall/
│   └── onboarding/
│
├── l10n/                      # 🌍 Internationalization
│   ├── app_en.arb
│   ├── app_fr.arb
│   └── app_localizations.dart (generated)
│
└── main.dart                  # 🚀 Entry Point
```

---

## Config Layer

### theme.dart

Centralized visual configuration.

```dart
class AppColors {
  // 🎨 Change this to rebrand the entire app
  static const Color primary = Color(0xFF2B85FF);
  
  // Derived colors
  static const Color background = Color(0xFF0F151F);
  static const Color surface = Color(0xFF1A212E);
  // ...
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(...);
}
```

### routes.dart

Declarative navigation with GoRouter.

```dart
class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
  static const String onboarding = '/onboarding';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    // ...
  ],
);
```

### constants.dart

All configurable values in one place.

```dart
class AppConstants {
  // App Identity
  static const String appName = 'PDF Organizer';
  static const String appVersion = '1.0.0';
  
  // RevenueCat
  static const String revenueCatApiKey = 'YOUR_KEY';
  static const String lifetimeEntitlementId = 'pro';
  
  // URLs
  static const String privacyPolicyUrl = '...';
  static const String supportEmail = '...';
  
  // Feature Flags
  static const bool enableAnalytics = false;
}
```

---

## Core Layer

### Services

#### PurchaseService

Singleton managing RevenueCat integration.

```dart
class PurchaseService {
  static final instance = PurchaseService._();
  
  bool get isPro => _isPro;  // Cached for offline
  
  Future<void> init() async { ... }
  Future<bool> purchaseLifetime() async { ... }
  Future<bool> restore() async { ... }
}
```

**Key Features:**
- ✅ Offline-first (caches Pro status)
- ✅ Platform-aware (iOS/Android keys)
- ✅ Error handling with fallback

#### StorageService

SharedPreferences wrapper.

```dart
class StorageService {
  static final instance = StorageService._();
  
  // Pro status
  Future<void> setIsPro(bool value) async { ... }
  bool getIsPro() { ... }
  
  // Onboarding
  Future<void> setHasSeenOnboarding(bool value) async { ... }
  bool hasSeenOnboarding() { ... }
}
```

### Widgets

#### PrimaryButton

```dart
PrimaryButton(
  label: 'Get Lifetime Access',
  icon: Icons.lock_open,
  isLoading: _isLoading,
  onPressed: _purchase,
)
```

#### SettingsTile

```dart
SettingsSection(
  title: 'General',
  children: [
    SettingsTile(
      icon: Icons.star,
      title: 'Rate App',
      onTap: _rateApp,
    ),
    SettingsTileToggle(
      icon: Icons.dark_mode,
      title: 'Dark Mode',
      value: isDark,
      onChanged: (v) => toggleTheme(),
    ),
  ],
)
```

---

## Features Layer

Each feature is self-contained:

```
features/home/
├── home_screen.dart      # Main screen
├── data/
│   └── dummy_data.dart   # Mock data / repositories
├── models/
│   └── document_model.dart
└── widgets/
    ├── document_card.dart
    └── quick_action_button.dart
```

### Feature Communication

Features communicate via:
1. **GoRouter** - Navigation with parameters
2. **Services** - Shared state (PurchaseService.isPro)
3. **Callbacks** - Parent-child widget communication

---

## Data Flow

```
┌──────────┐     ┌──────────────┐     ┌─────────────┐
│   UI     │────▶│   Service    │────▶│  External   │
│ (Screen) │◀────│  (singleton) │◀────│ (RevenueCat)│
└──────────┘     └──────────────┘     └─────────────┘
      │                 │
      │                 ▼
      │          ┌──────────────┐
      └─────────▶│   Storage    │
                 │ (SharedPrefs)│
                 └──────────────┘
```

---

## Creating a New App

### Step 1: Clone & Rename

```bash
git clone <repo> my_new_app
cd my_new_app
```

### Step 2: Update Config

**config/constants.dart:**
```dart
static const String appName = 'My New App';
static const String revenueCatApiKey = 'NEW_KEY';
```

**config/theme.dart:**
```dart
static const Color primary = Color(0xFFFF5722);  // New brand color
```

### Step 3: Replace Features

Delete `features/` content, keep structure:
```
features/
├── home/       # Your main screen
├── settings/   # Keep as template
├── paywall/    # Keep as template
└── onboarding/ # Update content
```

### Step 4: Update Translations

Edit `l10n/app_en.arb` and `l10n/app_fr.arb`:
```json
{
  "appName": "My New App",
  "onboardingTitle1": "New Feature 1",
  ...
}
```

Run:
```bash
flutter gen-l10n
```

### Step 5: Configure Stores

1. Update `pubspec.yaml` package name
2. Configure RevenueCat products
3. Submit to App Store / Play Store

---

## Best Practices

### DO ✅

1. **Keep Core generic** - No app-specific logic
2. **Use Services for state** - Not StatefulWidget
3. **Localize all strings** - Use AppLocalizations
4. **Cache Pro status** - For offline access
5. **Document constants** - Comments in constants.dart

### DON'T ❌

1. **Modify Core** unless fixing bugs
2. **Hardcode strings** in UI
3. **Skip error handling** in services
4. **Forget to run gen-l10n** after ARB changes

---

## Extension Points

### Adding a New Service

```dart
// core/services/new_service.dart
class NewService {
  static final instance = NewService._();
  NewService._();
  
  Future<void> init() async { ... }
}

// main.dart
void main() async {
  await NewService.instance.init();
  runApp(const MyApp());
}
```

### Adding a New Feature Screen

1. Create `features/new_feature/new_feature_screen.dart`
2. Add route in `config/routes.dart`
3. Add translations in `l10n/app_*.arb`
4. Run `flutter gen-l10n`

### Adding a New Language

1. Create `l10n/app_XX.arb`
2. Copy structure from `app_en.arb`
3. Translate values
4. Run `flutter gen-l10n`

---

## Testing Strategy

| Layer | Test Type | Coverage Target |
|-------|-----------|-----------------|
| Services | Unit tests | 90% |
| Widgets | Widget tests | 70% |
| Features | Integration | 50% |
| E2E | Manual + Automated | Key flows |

---

## Maintenance

### Weekly
- [ ] Check RevenueCat dashboard
- [ ] Review crash reports

### Monthly
- [ ] Update dependencies
- [ ] Review analytics

### Per Release
- [ ] Run full test suite
- [ ] Update version in constants.dart
- [ ] Update changelogs

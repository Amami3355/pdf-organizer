# Changelog

All notable changes to PDF Organizer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Riverpod** state management (replacing Provider)
- `purchaseProvider` and `isProProvider` for reactive Pro status
- All screens now use `ConsumerWidget` / `ConsumerStatefulWidget`
- **Light Mode** theme with dynamic switching
- `themeProvider` and `isDarkModeProvider` for reactive theme state
- Dark/Light mode toggle in Settings > Appearance section

### Changed
- Migrated from `Provider` to `flutter_riverpod: ^2.6.1`
- `main.dart` now wraps app with `ProviderScope`
- `MyApp` converted to `ConsumerWidget` for theme reactivity

### Planned
- OCR text recognition
- Cloud sync
- Digital signatures
- PDF merge/split

---

## [1.0.0] - 2025-12-11

### Added

#### Architecture
- Implemented **Micro-SaaS Factory** architecture
- Three-layer structure: Config, Core, Features
- Singleton services for business logic

#### Config Layer
- `config/theme.dart` - Dark theme with customizable primary color
- `config/routes.dart` - GoRouter navigation
- `config/constants.dart` - Centralized app configuration

#### Core Services
- `PurchaseService` - RevenueCat integration with offline caching
- `StorageService` - SharedPreferences wrapper
- `AnalyticsService` - Placeholder for future analytics

#### Core Widgets
- `PrimaryButton` - Gradient CTA with loading state
- `SecondaryButton` - Outlined variant
- `AppCard` - Elevated card component
- `CrossPromoCard` - For app promotion
- `SettingsTile` - Settings menu item
- `SettingsTileToggle` - Toggle variant
- `SettingsSection` - Grouped settings
- `LoadingOverlay` - Full-screen loading

#### Features
- **Home** - Dashboard with documents list
- **Editor** - PDF page management
- **Settings** - App preferences and cross-promo
- **Paywall** - Lifetime Pro purchase
- **Onboarding** - 4-page tutorial

#### Internationalization
- Flutter Localizations setup
- English (en) - Complete
- French (fr) - Complete
- ARB-based translation system

#### Monetization
- RevenueCat SDK integration
- Lifetime purchase model
- Restore purchases support
- Offline Pro status caching

### Technical Details
- Flutter 3.9+
- Dart 3.9+
- Dependencies: go_router, purchases_flutter, shared_preferences, google_fonts, etc.

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.0.0 | 2025-12-11 | Initial release with Micro-SaaS Factory |

---

## Migration Notes

### From 0.x to 1.0.0

Complete rewrite. Not backwards compatible.

Key changes:
1. New folder structure (`config/`, `core/`, `features/`)
2. GoRouter instead of Navigator
3. RevenueCat for payments
4. Flutter Localizations for i18n

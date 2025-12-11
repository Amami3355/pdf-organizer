# Developer Guide

## Prerequisites

- Flutter SDK 3.9.0+
- Dart 3.9.0+
- Android Studio / VS Code
- iOS: Xcode 14+ (for iOS development)

## Getting Started

### 1. Clone & Install

```bash
git clone <repository-url>
cd pdf-organizer

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n
```

### 2. Run the App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# All devices
flutter devices
flutter run -d <device-id>
```

### 3. Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## Development Workflow

### Adding a New Feature

1. **Create feature folder:**
```
lib/features/my_feature/
├── my_feature_screen.dart
├── widgets/
├── models/
└── data/
```

2. **Add route in `config/routes.dart`:**
```dart
GoRoute(
  path: '/my-feature',
  builder: (context, state) => const MyFeatureScreen(),
),
```

3. **Add translations in `l10n/app_en.arb`:**
```json
{
  "myFeatureTitle": "My Feature",
  "myFeatureDescription": "Description here"
}
```

4. **Regenerate localizations:**
```bash
flutter gen-l10n
```

5. **Use in screen:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myFeatureTitle)
```

### Code Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Fix issues automatically
dart fix --apply
```

---

## Key Files Reference

| File | Purpose | When to Modify |
|------|---------|---------------|
| `config/constants.dart` | API keys, URLs | New app / config change |
| `config/theme.dart` | Colors, typography | Branding changes |
| `config/routes.dart` | Navigation | Adding screens |
| `l10n/app_*.arb` | Translations | Any UI text change |
| `pubspec.yaml` | Dependencies | Adding packages |

---

## Services Usage

### PurchaseService (via Riverpod)

All screens use Riverpod for reactive state management. Extend `ConsumerWidget` or `ConsumerStatefulWidget`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/providers.dart';

// In a ConsumerWidget or ConsumerStatefulWidget:

// Watch Pro status (reactive - UI updates automatically)
final isPro = ref.watch(isProProvider);

if (isPro) {
  // Show Pro features
}

// Trigger purchase
final success = await ref.read(purchaseProvider.notifier).purchaseLifetime();

// Restore purchases
final restored = await ref.read(purchaseProvider.notifier).restore();
```

> **Note**: `ref.watch()` for reactive UI updates, `ref.read()` for one-time actions.

### StorageService

```dart
import 'core/services/storage_service.dart';

// Check onboarding status
if (!StorageService.instance.hasSeenOnboarding()) {
  // Show onboarding
}

// Save preference
await StorageService.instance.setString('key', 'value');
String? value = StorageService.instance.getString('key');
```

### AnalyticsService (placeholder)

```dart
import 'core/services/analytics_service.dart';

// Log event
await AnalyticsService.instance.logEvent('button_pressed', {
  'button_name': 'upgrade',
});
```

---

## Localization

### Structure

```
lib/l10n/
├── app_en.arb          # English (template)
├── app_fr.arb          # French
└── app_localizations.dart (generated)
```

### ARB File Format

```json
{
  "@@locale": "en",
  
  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  
  "itemCount": "{count} items",
  "@itemCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

### Usage in Code

```dart
import '../../l10n/app_localizations.dart';

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Column(
    children: [
      Text(l10n.greeting('Alex')),      // "Hello, Alex!"
      Text(l10n.itemCount(5)),          // "5 items"
    ],
  );
}
```

### Adding a Language

1. Create `lib/l10n/app_XX.arb` (copy from `app_en.arb`)
2. Translate all values
3. Run `flutter gen-l10n`

---

## Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

### Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Debugging

### Common Issues

#### 1. Google Fonts Network Error

**Error:** `Failed to load font with url fonts.gstatic.com`

**Solution:** This is a network issue. The app works fine; just needs internet for first font load.

#### 2. RevenueCat Not Working

**Check:**
1. API key in `constants.dart`
2. Products configured in RevenueCat dashboard
3. Sandbox tester configured (iOS/Android)

#### 3. Localizations Not Updating

```bash
# Regenerate
flutter gen-l10n

# If still not working, clean and rebuild
flutter clean
flutter pub get
flutter gen-l10n
```

### Useful Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated

# Doctor check
flutter doctor -v
```

---

## Deployment

### Android (Play Store)

1. Update version in `pubspec.yaml`
2. Build: `flutter build appbundle --release`
3. Upload to Play Console
4. Configure RevenueCat products

### iOS (App Store)

1. Update version in `pubspec.yaml`
2. In Xcode: Update version/build number
3. Archive: `flutter build ios --release`
4. Upload via Xcode or Transporter
5. Configure RevenueCat products

### Pre-Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update version in `constants.dart`
- [ ] Run `flutter analyze`
- [ ] Run all tests
- [ ] Test on physical device
- [ ] Test purchase flow (sandbox)
- [ ] Check all translations
- [ ] Update changelog

---

## Architecture Decisions

### Why GoRouter?

- Declarative routing
- Deep linking support
- Web URL support
- Type-safe navigation

### Why RevenueCat?

- Cross-platform
- Sandbox testing
- Analytics included
- Receipt validation

### Why Singletons for Services?

- Global access without context
- Initialized once at app start
- Easy mocking for tests

---

## Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes
3. Run `flutter analyze` and `flutter test`
4. Commit with clear message
5. Push and create PR

### Commit Message Format

```
type(scope): description

Examples:
feat(home): add document search
fix(paywall): handle restore error
docs(readme): update installation steps
refactor(services): extract storage logic
```

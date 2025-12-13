# Monetization Guide (RevenueCat)

## Overview

PDF Organizer uses RevenueCat for in-app purchases and subscription management. The current model is a **lifetime purchase** (one-time payment for permanent Pro access).

## Configuration

### RevenueCat Dashboard Setup

1. Create account at [revenuecat.com](https://www.revenuecat.com)
2. Create new project: "PDF Organizer"
3. Add platforms: iOS and Android
4. Create entitlement: `pro`
5. Create product: `pdf_organizer_lifetime`
6. Link product to entitlement

### App Configuration

**lib/config/constants.dart:**
```dart
class AppConstants {
  // RevenueCat API Key (from RevenueCat dashboard)
  static const String revenueCatApiKey = 'test_keneRPXbFxNPZPubzBptqWXUFqN';
  
  // Entitlement ID (matches RevenueCat dashboard)
  static const String lifetimeEntitlementId = 'pro';
  
  // Product ID (matches store and RevenueCat)
  static const String lifetimeProductId = 'pdf_organizer_lifetime';
}
```

---

## PurchaseService

### Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│    UI       │────▶│ PurchaseServ │────▶│  RevenueCat │
│  (Paywall)  │◀────│   (cached)   │◀────│    (API)    │
└─────────────┘     └──────────────┘     └─────────────┘
                          │
                          ▼
                    ┌──────────────┐
                    │ StorageServ  │
                    │ (SharedPrefs)│
                    └──────────────┘
```

### Key Features

| Feature | Description |
|---------|-------------|
| **Singleton** | Single instance across app |
| **Offline-first** | Pro status cached locally |
| **Platform-aware** | Handles iOS/Android (mobile only) |
| **Error handling** | Graceful fallbacks |

### Usage

The app uses **Riverpod** for reactive state management. All screens extend `ConsumerWidget` or `ConsumerStatefulWidget`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/providers.dart';

// In a ConsumerWidget/ConsumerStatefulWidget:

// Watch Pro status (reactive - UI updates automatically when status changes)
final isPro = ref.watch(isProProvider);

if (isPro) {
  // Show Pro features
} else {
  // Show limited features or paywall
}

// Trigger purchase
onPressed: () async {
  final success = await ref.read(purchaseProvider.notifier).purchaseLifetime();
  if (success) {
    // Show success message
    Navigator.pop(context);
  }
}

// Restore purchases
onPressed: () async {
  final restored = await ref.read(purchaseProvider.notifier).restore();
  if (restored) {
    // Pro restored successfully
  } else {
    // No previous purchases found
  }
}
```

> **Key difference from direct service access**: Using `ref.watch(isProProvider)` makes the UI automatically rebuild when the Pro status changes, without needing manual `setState()` calls.

---

## Implementation Details

### Initialization (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService.instance.init();
  await PurchaseService.instance.init();  // Initialize RevenueCat
  
  runApp(const MyApp());
}
```

### PurchaseService.init()

```dart
Future<void> init() async {
  // Load cached Pro status first (offline-first)
  _isPro = StorageService.instance.getIsPro();
  
  // Skip RevenueCat on web
  if (kIsWeb) return;
  
  // Configure RevenueCat
  await Purchases.configure(
    PurchasesConfiguration(AppConstants.revenueCatApiKey),
  );
  
  // Sync with server
  await _syncProStatus();
}
```

### Offline Support

The Pro status is cached in SharedPreferences:

```dart
// After successful purchase
await StorageService.instance.setIsPro(true);
_isPro = true;

// On app start
_isPro = StorageService.instance.getIsPro();

// Later sync with server when online
if (connected) await _syncProStatus();
```

---

## Paywall Screen

### Location

`lib/features/paywall/paywall_screen.dart`

### Key Components

1. **Premium icon** with gradient
2. **Title** ("Unlock PDF Organizer Pro")
3. **Features list** with checkmarks
4. **Primary CTA button** ("Get Lifetime Access")
5. **Restore link** ("Restore Purchases")

### Showing the Paywall

```dart
// From Settings
SettingsTile(
  icon: Icons.workspace_premium,
  title: l10n.upgradeToPro,
  onTap: () => context.push(AppRoutes.paywall),
)

// When hitting Pro feature limit
if (!PurchaseService.instance.isPro) {
  context.push(AppRoutes.paywall);
  return;
}
// Proceed with Pro feature...
```

---

## Store Configuration

### iOS (App Store Connect)

1. Go to App Store Connect > Your App > In-App Purchases
2. Create new In-App Purchase:
   - Type: **Non-Consumable**
   - Reference Name: "Lifetime Pro"
   - Product ID: `pdf_organizer_lifetime`
   - Price: $29.99 (or your choice)

3. Add localized display name and description

4. In RevenueCat: Link this product to the `pro` entitlement

### Android (Play Console)

1. Go to Play Console > Your App > Monetize > Products
2. Create new product:
   - Product ID: `pdf_organizer_lifetime`
   - Type: **One-time product**
   - Price: $29.99

3. In RevenueCat: Link this product to the `pro` entitlement

---

## Testing

### Sandbox Testing (iOS)

1. Create sandbox tester in App Store Connect
2. Sign out of App Store on device
3. When prompted during purchase, use sandbox account
4. Purchase completes without real charge

### Testing (Android)

1. Add license testers in Play Console
2. Use real Google account as tester
3. Purchases in testing mode are free

### RevenueCat Debug Mode

```dart
// In init(), before configure
Purchases.setLogLevel(LogLevel.debug);
```

Check logs for:
- Configuration success
- Entitlement status
- Purchase flow events

---

## Analytics

RevenueCat provides built-in analytics:

| Metric | Description |
|--------|-------------|
| **Revenue** | Total and per product |
| **Active Trials** | (if using subscriptions) |
| **Conversion Rate** | Installs to paid |
| **MRR** | Monthly Recurring Revenue |

Access at: dashboard.revenuecat.com

---

## Pricing Strategy

### Current Model

| Tier | Price | Access |
|------|-------|--------|
| Free | $0 | Basic features, limited usage |
| Lifetime | $29.99 | All features, forever |

### Recommended A/B Tests

1. **Price points**: $19.99 vs $29.99 vs $39.99
2. **Trial period**: 3-day vs 7-day free trial
3. **Paywall design**: Minimal vs feature-rich
4. **Paywall timing**: After 3 uses vs after 7 days

---

## Error Handling

### Common Errors

| Error | Cause | Handling |
|-------|-------|----------|
| `purchaseNotAvailable` | Store not configured | Show "Coming soon" message |
| `paymentPending` | Payment delayed | Show "Payment pending" |
| `productNotFound` | Wrong product ID | Check configuration |
| `networkError` | No connection | Use cached status |

### Implementation

```dart
Future<bool> purchaseLifetime() async {
  try {
    final offerings = await Purchases.getOfferings();
    if (offerings.current == null) {
      return false;  // No offerings available
    }
    
    // Find lifetime package
    final package = offerings.current!.availablePackages.firstWhere(
      (p) => p.identifier == AppConstants.lifetimeProductId,
      orElse: () => throw Exception('Product not found'),
    );
    
    // Make purchase
    final result = await Purchases.purchasePackage(package);
    
    // Check entitlement
    if (result.customerInfo.entitlements.all[AppConstants.lifetimeEntitlementId]?.isActive == true) {
      await StorageService.instance.setIsPro(true);
      _isPro = true;
      return true;
    }
    
    return false;
  } catch (e) {
    // Log error for debugging
    debugPrint('Purchase error: $e');
    return false;
  }
}
```

---

## Best Practices

### DO ✅

1. **Cache Pro status** for offline access
2. **Handle all error cases** gracefully
3. **Test with sandbox** before release
4. **Show clear value proposition** on paywall
5. **Provide restore option** prominently

### DON'T ❌

1. **Gate critical features** behind paywall on first use
2. **Show paywall immediately** after install
3. **Use fake scarcity** ("Limited time offer" that never ends)
4. **Forget to validate** receipts server-side for sensitive features

---

## Migration to Subscriptions

If you later want to add subscriptions:

1. Create subscription product in stores
2. Add to RevenueCat entitlement
3. Update paywall UI with subscription option
4. Handle subscription status in `_syncProStatus()`

```dart
// Example: Check for any active subscription OR lifetime
final hasActiveEntitlement = customerInfo
    .entitlements
    .all[AppConstants.lifetimeEntitlementId]
    ?.isActive == true;
```

---

## Troubleshooting

### Purchases Not Working

1. Check API key in constants.dart
2. Verify products in RevenueCat dashboard
3. Ensure products linked to entitlement
4. Check store product status (approved/active)

### Restore Not Finding Purchases

1. Use same store account as original purchase
2. Wait for store sync (can take minutes)
3. Check RevenueCat dashboard for customer history

### Pro Status Not Persisting

1. Verify StorageService is initialized before PurchaseService
2. Check that setIsPro is called after successful purchase
3. Verify SharedPreferences is working (test with other values)

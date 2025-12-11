# PDF Organizer Documentation

Welcome to the PDF Organizer documentation. This app is built using the **Micro-SaaS Factory** architecture, designed for rapid development and easy replication for new app projects.

## 📚 Table of Contents

| Document | Description |
|----------|-------------|
| [PRD](./PRD.md) | Product Requirements Document |
| [Architecture](./ARCHITECTURE.md) | Micro-SaaS Factory architecture |
| [Developer Guide](./DEVELOPER_GUIDE.md) | Setup and development workflow |
| [Internationalization](./I18N.md) | Multi-language support |
| [Monetization](./MONETIZATION.md) | RevenueCat integration |

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run the app
flutter run
```

## 🏗️ Project Structure

```
lib/
├── config/         # App configuration (theme, routes, constants)
├── core/           # Reusable services and widgets
│   ├── services/   # Business logic (purchases, storage, analytics)
│   └── widgets/    # UI components
├── features/       # App-specific screens
│   ├── home/
│   ├── editor/
│   ├── settings/
│   ├── paywall/
│   └── onboarding/
└── l10n/           # Translations (EN, FR)
```

## 🛠️ Tech Stack

- **Navigation**: GoRouter
- **Payments**: RevenueCat
- **Storage**: SharedPreferences
- **i18n**: Flutter Localizations + intl
- **Fonts**: Google Fonts (Inter)

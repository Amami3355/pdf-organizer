# PDF Organizer

Mobile-first PDF scanner and organizer (Android/iOS).

## Docs

See `docs/README.md`.

## Getting Started

```bash
flutter pub get
flutter gen-l10n
flutter run -d android
```

## Highlights

- Native document scanning via `cunning_document_scanner` (auto borders + crop, multi-page)
- Local library using Hive + filesystem (relative filenames only)
- Page editing (reorder, rotate, extract, merge) + PDF export/share
- Signature capture + placement (non-destructive overlay + flatten on export)

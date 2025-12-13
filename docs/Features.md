**Core Features (MVP):**
1. **Document Scanner:** Native scan UI via `cunning_document_scanner` (Android ML Kit / iOS VisionKit), auto-edge detection + crop, multi-page.
2. **PDF Import:** Import PDFs and rasterize pages to images (unified scan/import pipeline).
3. **Local Library (offline-first):** Persist documents using Hive (metadata) + filesystem (PDF/pages/thumbnails). Only relative filenames are stored.
4. **Editor (pages):** Reorder (persisted), rotate, delete, extract selected pages (split), merge documents (multi-select in Home).
5. **Signatures (non-destructive):** Create signatures (canvas), place on pages (drag + pinch), visible in previews, flattened at PDF export.
6. **Export/Share:** PDF generation (`pdf`) + native share sheet (`share_plus`).

**Pro Features (Locked behind RevenueCat, planned):**
1. **On-Device OCR:** Extract/search text from pages using Google ML Kit.
2. **Compression:** Adjustable image quality for smaller PDFs.
3. **Security:** PDF password/encryption.
4. **Cloud Sync:** Multi-device sync.

**Notes / Limitations (current):**
- No Web support (Android/iOS only).
- Manual crop / corner adjustment in the editor is not implemented yet (scan cropping is handled by the native scanner via `cunning_document_scanner`).
- Advanced perspective transform post-processing is planned (see `docs/ROADMAP.md`).

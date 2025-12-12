**Core Features (MVP):**
1.  **Document Scanner:** Native scan UI via `cunning_document_scanner` (Android ML Kit / iOS VisionKit), auto-edge detection, crop, multi-page.
2.  **Image Processing:** Perspective transform, Filters (B&W, Magic Color, Grayscale).
3.  **Editor:** Grid view reordering, page rotation, crop, delete page.
4.  **Export:** PDF generation, Share sheet integration.

**Pro Features (Locked behind RevenueCat):**
1.  **On-Device OCR:** Extract text from images using Google ML Kit.
2.  **Signature Pad:** Vector drawing on canvas + placing on PDF.
3.  **Compression:** Adjustable image quality for PDF size reduction.
4.  **Security:** PDF Password encryption.
5.  **Remove Ads/Watermark:** Clean output.

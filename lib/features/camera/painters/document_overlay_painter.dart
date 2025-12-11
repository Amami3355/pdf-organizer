import 'package:flutter/material.dart';

/// 📷 Document Overlay Painter
/// 
/// Draws the document detection polygon overlay on the camera preview.
/// - Shows a semi-transparent overlay with the detected document highlighted
/// - Animates corner positions for smooth transitions
/// - Changes color based on detection stability (yellow = detecting, green = stable)

class DocumentOverlayPainter extends CustomPainter {
  /// The four corner points of the detected document (in preview coordinates)
  final List<Offset>? corners;
  
  /// Whether the document detection is stable (not moving)
  final bool isStable;
  
  /// Animation value for smooth transitions (0.0 - 1.0)
  final double animationValue;
  
  /// The size of the preview for coordinate mapping
  final Size previewSize;

  DocumentOverlayPainter({
    this.corners,
    this.isStable = false,
    this.animationValue = 1.0,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners == null || corners!.length != 4) {
      // No document detected - draw scan guide
      _drawScanGuide(canvas, size);
      return;
    }

    // Scale corners to canvas size
    final scaledCorners = corners!.map((corner) {
      return Offset(
        corner.dx * size.width / previewSize.width,
        corner.dy * size.height / previewSize.height,
      );
    }).toList();

    // Draw semi-transparent overlay outside the document
    _drawOverlay(canvas, size, scaledCorners);
    
    // Draw the document border
    _drawDocumentBorder(canvas, scaledCorners);
    
    // Draw corner indicators
    _drawCornerIndicators(canvas, scaledCorners);
  }

  void _drawScanGuide(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw a centered rectangle guide
    final guideRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.6,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(guideRect, paint);

    // Draw corner brackets
    final bracketLength = 40.0;
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rect = guideRect.outerRect;
    
    // Top-left
    _drawCornerBracket(canvas, rect.topLeft, bracketLength, cornerPaint, topLeft: true);
    // Top-right
    _drawCornerBracket(canvas, rect.topRight, bracketLength, cornerPaint, topRight: true);
    // Bottom-left
    _drawCornerBracket(canvas, rect.bottomLeft, bracketLength, cornerPaint, bottomLeft: true);
    // Bottom-right
    _drawCornerBracket(canvas, rect.bottomRight, bracketLength, cornerPaint, bottomRight: true);
  }

  void _drawCornerBracket(
    Canvas canvas,
    Offset corner,
    double length,
    Paint paint, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final path = Path();
    
    if (topLeft) {
      path.moveTo(corner.dx, corner.dy + length);
      path.lineTo(corner.dx, corner.dy);
      path.lineTo(corner.dx + length, corner.dy);
    } else if (topRight) {
      path.moveTo(corner.dx - length, corner.dy);
      path.lineTo(corner.dx, corner.dy);
      path.lineTo(corner.dx, corner.dy + length);
    } else if (bottomLeft) {
      path.moveTo(corner.dx, corner.dy - length);
      path.lineTo(corner.dx, corner.dy);
      path.lineTo(corner.dx + length, corner.dy);
    } else if (bottomRight) {
      path.moveTo(corner.dx - length, corner.dy);
      path.lineTo(corner.dx, corner.dy);
      path.lineTo(corner.dx, corner.dy - length);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawOverlay(Canvas canvas, Size size, List<Offset> corners) {
    // Create a path for the entire canvas
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the document polygon
    final documentPath = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    // Combine paths to create overlay with document cutout
    final combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      documentPath,
    );

    // Draw semi-transparent overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4 * animationValue)
      ..style = PaintingStyle.fill;

    canvas.drawPath(combinedPath, overlayPaint);
  }

  void _drawDocumentBorder(Canvas canvas, List<Offset> corners) {
    final borderColor = isStable 
        ? const Color(0xFF4CAF50) // Green when stable
        : const Color(0xFFFFEB3B); // Yellow when detecting
    
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    canvas.drawPath(path, borderPaint);

    // Draw glow effect when stable
    if (isStable) {
      final glowPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.3 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glowPaint);
    }
  }

  void _drawCornerIndicators(Canvas canvas, List<Offset> corners) {
    final cornerColor = isStable 
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFFEB3B);

    for (final corner in corners) {
      // Outer circle
      final outerPaint = Paint()
        ..color = cornerColor.withValues(alpha: animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(corner, 8, outerPaint);

      // Inner circle (white)
      final innerPaint = Paint()
        ..color = Colors.white.withValues(alpha: animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(corner, 4, innerPaint);
    }
  }

  @override
  bool shouldRepaint(DocumentOverlayPainter oldDelegate) {
    return corners != oldDelegate.corners ||
        isStable != oldDelegate.isStable ||
        animationValue != oldDelegate.animationValue ||
        previewSize != oldDelegate.previewSize;
  }
}

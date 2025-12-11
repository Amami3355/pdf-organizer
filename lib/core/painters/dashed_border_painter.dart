import 'package:flutter/material.dart';

/// 📐 Dashed Border Painter
///
/// Custom painter for drawing dashed borders around widgets.
/// Useful for add/upload placeholders and drop zones.

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashWidth = gap;
    final double dashSpace = gap;
    
    // Top
    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
    
    // Right
    double currentY = 0;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(size.width, currentY),
        Offset(size.width, currentY + dashWidth),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }

    // Bottom
    currentX = size.width;
    while (currentX > 0) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(currentX - dashWidth, size.height),
        paint,
      );
      currentX -= dashWidth + dashSpace;
    }

    // Left
    currentY = size.height;
    while (currentY > 0) {
      canvas.drawLine(
        Offset(0, currentY),
        Offset(0, currentY - dashWidth),
        paint,
      );
      currentY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

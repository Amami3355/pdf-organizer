import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';

/// ✏️ Editor Screen
/// 
/// PDF page management and editing tools.
/// Uses Riverpod for consistency across the app.

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Contract_Scan_FINAL.pdf',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${l10n.pages(3)} • 2.4 MB',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              l10n.export,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.70,
              children: [
                _buildPageCard(context, 1, false),
                _buildPageCard(context, 2, false),
                _buildPageCard(context, 3, true),
                _buildAddPageCard(context, l10n),
              ],
            ),
          ),
          
          // Bottom Toolbar with Glassmorphism
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2633).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildToolbarItem(Icons.edit_outlined, l10n.sign),
                        _buildToolbarItem(Icons.compress, l10n.compress),
                        _buildToolbarItem(Icons.crop, l10n.extract),
                        _buildToolbarItem(Icons.more_horiz, l10n.more),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, int pageNumber, bool isSelected) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 8, width: 60, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      for (int i = 0; i < 6; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(height: 4, width: double.infinity, color: Colors.grey[300]),
                        ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$pageNumber',
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPageCard(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              strokeWidth: 1.5,
              gap: 5,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                      ),
                      child: const Icon(Icons.add, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addPage,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(''),
      ],
    );
  }

  Widget _buildToolbarItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

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

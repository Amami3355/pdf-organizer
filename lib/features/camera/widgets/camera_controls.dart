import 'package:flutter/material.dart';
import '../models/scan_result.dart';

/// 📷 Flash Button Widget
/// 
/// A button to toggle flash modes (auto, on, off).

class FlashButton extends StatelessWidget {
  final CameraFlashMode flashMode;
  final VoidCallback onPressed;

  const FlashButton({
    super.key,
    required this.flashMode,
    required this.onPressed,
  });

  IconData get _icon {
    switch (flashMode) {
      case CameraFlashMode.auto:
        return Icons.flash_auto;
      case CameraFlashMode.on:
        return Icons.flash_on;
      case CameraFlashMode.off:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CameraControlButton(
      icon: _icon,
      label: flashMode.displayName,
      onPressed: onPressed,
    );
  }
}

/// 📷 Batch Counter Widget
/// 
/// Shows the number of pages scanned in the current batch.

class BatchCounter extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const BatchCounter({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📷 Gallery Button Widget
/// 
/// Button to open gallery for importing images.

class GalleryButton extends StatelessWidget {
  final String? lastImagePath;
  final VoidCallback onPressed;

  const GalleryButton({
    super.key,
    this.lastImagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: lastImagePath != null
              ? Image.asset(
                  lastImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.photo_library, color: Colors.white, size: 24),
    );
  }
}

/// 📷 Done Button Widget
/// 
/// Button to finish scanning and proceed to editor.

class DoneButton extends StatelessWidget {
  final int pageCount;
  final VoidCallback onPressed;

  const DoneButton({
    super.key,
    required this.pageCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pageCount > 0 ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: pageCount > 0
              ? Theme.of(context).primaryColor
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              color: pageCount > 0 ? Colors.white : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'Done ($pageCount)',
              style: TextStyle(
                color: pageCount > 0 ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal helper widget for camera control buttons
class _CameraControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CameraControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

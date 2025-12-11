import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// 🏷️ Reusable Status Chip Widget
///
/// Extracted from DocumentCard for reuse across the app.
/// Displays a colored chip with icon and text based on status.

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({
    super.key,
    required this.status,
  });

  Color _getBackgroundColor() {
    switch (status) {
      case 'SYNCED':
        return AppColors.statusSyncedBg;
      case 'OCR READY':
        return AppColors.statusOcrBg;
      case 'SECURED':
        return AppColors.statusSecuredBg;
      default:
        return AppColors.surfaceLight;
    }
  }

  Color _getForegroundColor() {
    switch (status) {
      case 'SYNCED':
        return AppColors.statusSyncedFg;
      case 'OCR READY':
        return AppColors.statusOcrFg;
      case 'SECURED':
        return AppColors.statusSecuredFg;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'SYNCED':
        return Icons.sync;
      case 'OCR READY':
        return Icons.text_fields;
      case 'SECURED':
        return Icons.lock_outline;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 10,
            color: _getForegroundColor(),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: _getForegroundColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

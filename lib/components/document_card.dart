import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../theme/app_theme.dart';
import '../screens/editor_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'SYNCED':
        return AppTheme.statusSyncedBg;
      case 'OCR READY':
        return AppTheme.statusOcrBg;
      case 'SECURED':
        return AppTheme.statusSecuredBg;
      default:
        return AppTheme.surfaceLight;
    }
  }

  Color _getStatusFgColor(String status) {
    switch (status) {
      case 'SYNCED':
        return AppTheme.statusSyncedFg;
      case 'OCR READY':
        return AppTheme.statusOcrFg;
      case 'SECURED':
        return AppTheme.statusSecuredFg;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
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
    return GestureDetector(
      onTap: () {
        // Navigate to Editor on tap
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditorScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // File Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: document.isSecured
                    ? const Icon(Icons.lock, color: AppTheme.textSecondary)
                    : const Icon(Icons.picture_as_pdf, color: AppTheme.pdfRed),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${document.size} • ${document.timeAgo}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(document.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(document.status),
                          size: 10,
                          color: _getStatusFgColor(document.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          document.status,
                          style: TextStyle(
                            color: _getStatusFgColor(document.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // More Button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

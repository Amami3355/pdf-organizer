import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/services/document_models.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '—';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  String _status() {
    if (document.isSigned) return 'SIGNED';
    return switch (document.source) {
      DocumentSource.importPdf => 'IMPORTED',
      DocumentSource.scan => 'SCANNED',
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          context.push('${AppRoutes.editor}?docId=${document.id}');
        }
      },
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // File Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).cardTheme.shadowColor ??
                    AppColors
                        .surfaceLight, // Fallback or specific secondary surface
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.pdfRed,
                ),
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
                        '${_formatBytes(document.pdfSizeBytes)} • ${_timeAgo(document.updatedAt)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status Chip
                  StatusChip(status: _status()),
                ],
              ),
            ),
            // More Button
            isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                : IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withValues(alpha: 0.5),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

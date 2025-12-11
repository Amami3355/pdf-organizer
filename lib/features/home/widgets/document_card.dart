import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/document_model.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          context.push(AppRoutes.editor);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // File Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.shadowColor ?? AppColors.surfaceLight, // Fallback or specific secondary surface
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: document.isSecured
                    ? Icon(Icons.lock, color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.5))
                    : const Icon(Icons.picture_as_pdf, color: AppColors.pdfRed),
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
                  StatusChip(status: document.status),
                ],
              ),
            ),
            // More Button
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

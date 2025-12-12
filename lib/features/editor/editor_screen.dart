import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/widgets/glass_toolbar.dart';
import '../../core/painters/dashed_border_painter.dart';
import 'providers/editor_provider.dart';

/// ✏️ Editor Screen
///
/// PDF page management and editing tools.
/// Uses Riverpod for consistency across the app.

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  Future<void> _exportPdf() async {
    final editorState = ref.read(editorProvider);
    if (editorState.pages.isEmpty) return;

    // Show loading
    // For now simple sync block or snackbar?
    // Better to have local loading state if lengthy.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final pdfService = ref.read(pdfGeneratorServiceProvider);
      // Generate PDF
      final file = await pdfService.generatePdf(editorState.pages);

      // Share
      await Share.shareXFiles([XFile(file.path)], text: 'Scanned Document');
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    // Total items = pages + add button
    // final int totalItems = editorState.pages.length + 1; // Unused

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'New_Scan.pdf', // TODO: Make editable
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              l10n.pages(editorState.pageCount),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _exportPdf,
            child: Text(
              l10n.export,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
            child: ReorderableGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.70,
              padding: const EdgeInsets.only(bottom: 100), // Space for toolbar
              onReorder: (oldIndex, newIndex) {
                // Prevent moving the "Add Page" button (last index)
                if (oldIndex >= editorState.pages.length) return;

                // Adjust newIndex if it targets the "Add Page" button
                if (newIndex >= editorState.pages.length) {
                  newIndex = editorState.pages.length - 1;
                }

                editorNotifier.reorderPages(oldIndex, newIndex);
              },
              children: [
                // Render Pages
                for (int i = 0; i < editorState.pages.length; i++)
                  _buildPageCard(
                    context,
                    i,
                    editorState.pages[i].id,
                    editorState.pages[i].imagePath,
                    editorState.selectedPageIds.contains(
                      editorState.pages[i].id,
                    ),
                    editorState.pages[i].rotation,
                  ),

                // Add Page Button (Key is required for reordering)
                _buildAddPageCard(context, l10n, const ValueKey('add_btn')),
              ],
            ),
          ),

          // Bottom Toolbar
          if (editorState.selectedPageIds.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: GlassToolbar(
                items: [
                  GlassToolbarItem(
                    icon: Icons.rotate_right,
                    label: l10n.rotate,
                    onTap: () {
                      for (var id in editorState.selectedPageIds) {
                        editorNotifier.rotatePage(id);
                      }
                    },
                  ),
                  GlassToolbarItem(
                    icon: Icons.delete_outline,
                    label: l10n.delete,
                    onTap: editorNotifier.deleteSelected,
                  ),
                  GlassToolbarItem(
                    icon: Icons.check_circle_outlined,
                    label: l10n.deselect,
                    onTap: editorNotifier.clearSelection,
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: GlassToolbar(
                items: [
                  GlassToolbarItem(icon: Icons.edit_outlined, label: l10n.sign),
                  GlassToolbarItem(icon: Icons.compress, label: l10n.compress),
                  GlassToolbarItem(
                    icon: Icons.crop,
                    label: l10n.extract,
                    onTap: () {
                      // Enter selection mode or open crop for single page?
                      // For now, maybe select all?
                    },
                  ),
                  GlassToolbarItem(icon: Icons.more_horiz, label: l10n.more),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageCard(
    BuildContext context,
    int index,
    String id,
    String path,
    bool isSelected,
    int rotation,
  ) {
    return GestureDetector(
      key: ValueKey(id),
      onTap: () {
        final state = ref.read(editorProvider);
        if (state.selectedPageIds.isNotEmpty) {
          ref.read(editorProvider.notifier).toggleSelection(id);
        } else {
          // Navigate to Edit Page
          context.push(AppRoutes.editPage.replaceFirst(':id', id));
        }
      },
      onLongPress: () {
        ref.read(editorProvider.notifier).toggleSelection(id);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: RotatedBox(
                      quarterTurns: rotation ~/ 90,
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPageCard(
    BuildContext context,
    AppLocalizations l10n,
    Key key,
  ) {
    return GestureDetector(
      key: key,
      onTap: () async {
        await context.push('${AppRoutes.camera}?from=editor');
        // After returning from camera (assuming it pops), import new pages
        ref.read(editorProvider.notifier).importFromCamera();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                strokeWidth: 1.5,
                gap: 5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  // color: Colors.transparent, // Important for drag target?
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addPage,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../core/services/document_models.dart';
import '../../core/services/providers.dart';
import '../../core/widgets/loading_overlay.dart';

class ManagePagesScreen extends ConsumerStatefulWidget {
  final String documentId;

  const ManagePagesScreen({super.key, required this.documentId});

  @override
  ConsumerState<ManagePagesScreen> createState() => _ManagePagesScreenState();
}

class _ManagePagesScreenState extends ConsumerState<ManagePagesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  DocumentModel? _document;
  List<DocumentPageModel> _pages = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final manager = ref.read(documentManagerProvider);
      final doc = manager.getDocumentSync(widget.documentId);
      if (doc == null) {
        throw StateError('Document not found');
      }

      setState(() {
        _document = doc;
        _pages = List.of(doc.pages);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _reorderPages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final items = List<DocumentPageModel>.from(_pages);
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      _pages = items;
    });
  }

  Future<void> _save() async {
    if (_document == null) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    LoadingOverlay.show(context, message: 'Saving...');

    try {
      final manager = ref.read(documentManagerProvider);
      await manager.reorderDocumentPages(
        documentId: widget.documentId,
        pages: _pages,
      );

      if (!mounted) return;
      LoadingOverlay.hide(context);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(documentManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_document?.title ?? 'Pages'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Done'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'Drag & drop pages to reorder.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ReorderableGridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                          onReorder: _reorderPages,
                          children: [
                            for (int i = 0; i < _pages.length; i++)
                              _PageTile(
                                key: ValueKey(_pages[i].id),
                                index: i,
                                page: _pages[i],
                                imagePath: manager.resolvePagePath(_pages[i]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PageTile extends StatelessWidget {
  final int index;
  final DocumentPageModel page;
  final String imagePath;

  const _PageTile({
    super.key,
    required this.index,
    required this.page,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: page.rotation ~/ 90,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.drag_handle, size: 16, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

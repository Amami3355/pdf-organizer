import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/image_processing_service.dart';
import '../../core/services/providers.dart';
import '../camera/models/scan_result.dart';
import 'providers/editor_provider.dart';
import '../signature/signature_overlay_preview.dart';

/// 🎨 Edit Page Screen
///
/// Allows applying filters, rotation, and potentially cropping.
class EditPageScreen extends ConsumerStatefulWidget {
  final String pageId;

  const EditPageScreen({
    super.key, 
    required this.pageId,
  });

  @override
  ConsumerState<EditPageScreen> createState() => _EditPageScreenState();
}

class _EditPageScreenState extends ConsumerState<EditPageScreen> {
  late ScanResult _page;
  late String _currentImagePath;
  ScanFilter _currentFilter = ScanFilter.original;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load page from provider
    final pages = ref.read(editorProvider).pages;
    try {
      _page = pages.firstWhere((p) => p.id == widget.pageId);
      _currentImagePath = _page.imagePath; // Start with current
      _currentFilter = _page.appliedFilter;
    } catch (e) {
      // Handle error (page not found)
      WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
    }
  }

  Future<void> _applyFilter(ScanFilter filter) async {
    if (_currentFilter == filter) return;
    
    setState(() => _isLoading = true);
    
    try {
      final service = ref.read(imageProcessingServiceProvider);
      // We always apply filter on the ORIGINAL image if we store it?
      // Currently `imagePath` points to the last version.
      // If we overwrite it, we lose original.
      // Ideally ScanResult should keep `originalPath`?
      // For now, we just chain filters or re-apply on current?
      // If we re-apply B&W on B&W, it's fine.
      // But "Original" requires the original file.
      // WE DO NOT STORE ORIGINAL PATH currently.
      // This is a limitation. I will assume we can't revert to exact original if we overwrite.
      // BUT `imagePath` is usually the captured file.
      // When applying filter, `ImageProcessingService` saves to NEW temp file.
      // So I can keep `_page.imagePath` as the "base" (if it was original)
      // Actually, if I save, I update the provider.
      
      final newPath = await service.applyFilter(_page.imagePath, filter);
      
      setState(() {
        _currentImagePath = newPath;
        _currentFilter = filter;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveChanges() {
    // Update provider
    // We need a method in EditorNotifier to update a specific page
    // For now we can't update just one field easily without exposure.
    // I'll add `updatePage` to Notifier.
    
    // BUT wait, I need to update the file path if it changed.
    final updatedPage = _page.copyWith(
      imagePath: _currentImagePath,
      appliedFilter: _currentFilter,
    );
    
    // I'll create `updatePage` in provider.
    // For now, I'll access the list and replace.
    // Better to add method to Notifier.
    ref.read(editorProvider.notifier).updatePage(updatedPage);
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(l10n.save, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SignatureOverlayPreview(
                pageImagePath: _currentImagePath,
                rotation: _page.rotation,
                fit: BoxFit.contain,
                placements: _page.signaturePlacements,
                signatureBaseDirPath: ref
                    .read(signatureManagerProvider)
                    .baseDirPath,
              ),
            ),
          ),
          _buildFilterBar(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 120,
      color: Colors.black,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ScanFilter.values.map((filter) {
          return GestureDetector(
            onTap: () => _applyFilter(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              width: 80,
              decoration: BoxDecoration(
                border: _currentFilter == filter 
                  ? Border.all(color: Colors.blue, width: 2) 
                  : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(filter.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    filter.displayName, 
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

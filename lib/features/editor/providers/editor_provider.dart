import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/document_manager.dart';
import '../../../core/services/document_models.dart';
import '../../../core/services/signature_models.dart';
import '../../camera/models/scan_result.dart';
import '../../camera/providers/camera_provider.dart';

/// 📝 Editor State
class EditorState {
  final List<ScanResult> pages;
  final Set<String> selectedPageIds;
  final bool isSaving;

  const EditorState({
    this.pages = const [],
    this.selectedPageIds = const {},
    this.isSaving = false,
  });

  EditorState copyWith({
    List<ScanResult>? pages,
    Set<String>? selectedPageIds,
    bool? isSaving,
  }) {
    return EditorState(
      pages: pages ?? this.pages,
      selectedPageIds: selectedPageIds ?? this.selectedPageIds,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  int get pageCount => pages.length;
}

/// Editor Notifier
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier(this.ref) : super(const EditorState()) {
    _initFromCamera();
  }

  final Ref ref;

  void _initFromCamera() {
    final cameraPages = ref.read(scanStateProvider).capturedImages;
    if (cameraPages.isNotEmpty) {
      state = state.copyWith(pages: List.from(cameraPages));
      // Schedule clearBatch to next microtask to avoid modifying provider during init
      Future.microtask(() {
        ref.read(scanStateProvider.notifier).clearBatch();
      });
    }
  }

  void importFromCamera() {
    final cameraPages = ref.read(scanStateProvider).capturedImages;
    if (cameraPages.isNotEmpty) {
      // Append new pages
      state = state.copyWith(pages: [...state.pages, ...cameraPages]);
      ref.read(scanStateProvider.notifier).clearBatch();
    }
  }

  void setPages(List<ScanResult> pages) {
    state = state.copyWith(pages: pages);
  }

  void toggleSelection(String id) {
    final selected = Set<String>.from(state.selectedPageIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedPageIds: selected);
  }

  void clearSelection() {
    state = state.copyWith(selectedPageIds: {});
  }

  void rotatePage(String id) {
    state = state.copyWith(
      pages: state.pages.map((page) {
        if (page.id == id) {
          final newRotation = (page.rotation + 90) % 360;
          final nextPlacements = page.signaturePlacements
              .map(_rotatePlacementClockwise90)
              .toList();
          return page.copyWith(
            rotation: newRotation,
            signaturePlacements: nextPlacements,
          );
        }
        return page;
      }).toList(),
    );
  }

  static double _clampDouble(num value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }

  static SignaturePlacementModel _rotatePlacementClockwise90(
    SignaturePlacementModel placement,
  ) {
    final nx = 1.0 - (placement.y + placement.height);
    final ny = placement.x;
    final nw = placement.height;
    final nh = placement.width;

    final maxX = (1.0 - nw).clamp(0.0, 1.0);
    final maxY = (1.0 - nh).clamp(0.0, 1.0);

    return placement.copyWith(
      x: _clampDouble(nx, 0.0, maxX),
      y: _clampDouble(ny, 0.0, maxY),
      width: _clampDouble(nw, 0.0, 1.0),
      height: _clampDouble(nh, 0.0, 1.0),
    );
  }

  void deleteSelected() {
    state = state.copyWith(
      pages: state.pages
          .where((p) => !state.selectedPageIds.contains(p.id))
          .toList(),
      selectedPageIds: {},
    );
  }

  void reorderPages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = List<ScanResult>.from(state.pages);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(pages: items);
  }

  void updatePage(ScanResult updatedPage) {
    state = state.copyWith(
      pages: state.pages
          .map((p) => p.id == updatedPage.id ? updatedPage : p)
          .toList(),
    );
  }

  void upsertSignaturePlacementForPages({
    required Iterable<String> pageIds,
    required SignaturePlacementModel placement,
  }) {
    final targetIds = pageIds.toSet();
    if (targetIds.isEmpty) return;

    state = state.copyWith(
      pages: state.pages.map((page) {
        if (!targetIds.contains(page.id)) return page;

        final next = [
          for (final p in page.signaturePlacements)
            if (p.signatureId != placement.signatureId) p,
          placement,
        ];

        return page.copyWith(signaturePlacements: next);
      }).toList(),
    );
  }

  void removeSignaturePlacementForPages({
    required Iterable<String> pageIds,
    required String signatureId,
  }) {
    final targetIds = pageIds.toSet();
    if (targetIds.isEmpty) return;

    state = state.copyWith(
      pages: state.pages.map((page) {
        if (!targetIds.contains(page.id)) return page;

        final next = [
          for (final p in page.signaturePlacements)
            if (p.signatureId != signatureId) p,
        ];

        return page.copyWith(signaturePlacements: next);
      }).toList(),
    );
  }

  Future<DocumentModel?> saveToLibrary({
    required DocumentManager documentManager,
    String? documentId,
    String title = '',
    DocumentSource source = DocumentSource.scan,
  }) async {
    if (state.pages.isEmpty) return null;
    if (state.isSaving) return null;

    state = state.copyWith(isSaving: true);
    try {
      final saved = documentId == null
          ? await documentManager.createDocumentFromPages(
              title: title,
              pages: state.pages,
              source: source,
            )
          : await documentManager.updateDocumentFromPages(
              documentId: documentId,
              title: title,
              pages: state.pages,
            );
      return saved;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final editorProvider =
    StateNotifierProvider.autoDispose<EditorNotifier, EditorState>((ref) {
      return EditorNotifier(ref);
    });

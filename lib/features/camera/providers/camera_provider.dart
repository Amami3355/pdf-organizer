import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';

/// 📷 Camera Provider
/// 
/// Manages the state of the camera/scan feature using Riverpod.

/// Scan state holder (renamed from CameraState to avoid conflict with CameraAwesome)
class ScanState {
  final CameraFlashMode flashMode;
  final List<ScanResult> capturedImages;
  final bool isDocumentDetected;
  final bool isDocumentStable;
  final List<ScanCorner>? currentCorners;
  final ImageFilter selectedFilter;
  final bool isCapturing;
  final bool isBatchMode;

  const ScanState({
    this.flashMode = CameraFlashMode.auto,
    this.capturedImages = const [],
    this.isDocumentDetected = false,
    this.isDocumentStable = false,
    this.currentCorners,
    this.selectedFilter = ImageFilter.original,
    this.isCapturing = false,
    this.isBatchMode = true,
  });

  ScanState copyWith({
    CameraFlashMode? flashMode,
    List<ScanResult>? capturedImages,
    bool? isDocumentDetected,
    bool? isDocumentStable,
    List<ScanCorner>? currentCorners,
    ImageFilter? selectedFilter,
    bool? isCapturing,
    bool? isBatchMode,
  }) {
    return ScanState(
      flashMode: flashMode ?? this.flashMode,
      capturedImages: capturedImages ?? this.capturedImages,
      isDocumentDetected: isDocumentDetected ?? this.isDocumentDetected,
      isDocumentStable: isDocumentStable ?? this.isDocumentStable,
      currentCorners: currentCorners ?? this.currentCorners,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isCapturing: isCapturing ?? this.isCapturing,
      isBatchMode: isBatchMode ?? this.isBatchMode,
    );
  }

  /// Number of pages scanned in current batch
  int get pageCount => capturedImages.length;
}

/// Scan state notifier
class ScanStateNotifier extends StateNotifier<ScanState> {
  ScanStateNotifier() : super(const ScanState());

  /// Toggle flash mode (auto -> on -> off -> auto)
  void toggleFlash() {
    final modes = CameraFlashMode.values;
    final currentIndex = modes.indexOf(state.flashMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    state = state.copyWith(flashMode: modes[nextIndex]);
  }

  /// Set flash mode directly
  void setFlashMode(CameraFlashMode mode) {
    state = state.copyWith(flashMode: mode);
  }

  /// Update document detection state
  void updateDocumentDetection({
    required bool isDetected,
    required bool isStable,
    List<ScanCorner>? corners,
  }) {
    state = state.copyWith(
      isDocumentDetected: isDetected,
      isDocumentStable: isStable,
      currentCorners: corners,
    );
  }

  /// Set capturing state
  void setCapturing(bool isCapturing) {
    state = state.copyWith(isCapturing: isCapturing);
  }

  /// Add a captured image to the batch
  void addCapturedImage(ScanResult result) {
    state = state.copyWith(
      capturedImages: [...state.capturedImages, result],
      isCapturing: false,
    );
  }

  /// Remove a captured image from the batch
  void removeCapturedImage(String id) {
    state = state.copyWith(
      capturedImages: state.capturedImages.where((img) => img.id != id).toList(),
    );
  }

  /// Update filter for a specific image
  void updateImageFilter(String id, ImageFilter filter) {
    state = state.copyWith(
      capturedImages: state.capturedImages.map((img) {
        if (img.id == id) {
          return img.copyWith(appliedFilter: filter);
        }
        return img;
      }).toList(),
    );
  }

  /// Set selected filter for new captures
  void setSelectedFilter(ImageFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Toggle batch mode
  void toggleBatchMode() {
    state = state.copyWith(isBatchMode: !state.isBatchMode);
  }

  /// Clear all captured images
  void clearBatch() {
    state = state.copyWith(capturedImages: []);
  }

  /// Reset camera state
  void reset() {
    state = const ScanState();
  }
}

/// Provider for scan state
final scanStateProvider = StateNotifierProvider<ScanStateNotifier, ScanState>(
  (ref) => ScanStateNotifier(),
);

/// Convenience providers
final flashModeProvider = Provider<CameraFlashMode>((ref) {
  return ref.watch(scanStateProvider).flashMode;
});

final capturedImagesProvider = Provider<List<ScanResult>>((ref) {
  return ref.watch(scanStateProvider).capturedImages;
});

final isDocumentStableProvider = Provider<bool>((ref) {
  return ref.watch(scanStateProvider).isDocumentStable;
});

final pageCountProvider = Provider<int>((ref) {
  return ref.watch(scanStateProvider).pageCount;
});

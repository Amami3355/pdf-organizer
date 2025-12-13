// 📷 Camera Feature - Models
// Data models for the camera/scan feature.

import '../../../core/services/signature_models.dart';

/// Represents a single scanned image result
class ScanResult {
  final String id;
  final String imagePath;
  final List<ScanCorner>? detectedCorners;
  final DateTime capturedAt;
  final ScanFilter appliedFilter;
  final bool isPerspectiveCorrected;
  final int rotation; // 0, 90, 180, 270
  final List<SignaturePlacementModel> signaturePlacements;

  const ScanResult({
    required this.id,
    required this.imagePath,
    this.detectedCorners,
    required this.capturedAt,
    this.appliedFilter = ScanFilter.original,
    this.isPerspectiveCorrected = false,
    this.rotation = 0,
    this.signaturePlacements = const [],
  });

  ScanResult copyWith({
    String? id,
    String? imagePath,
    List<ScanCorner>? detectedCorners,
    DateTime? capturedAt,
    ScanFilter? appliedFilter,
    bool? isPerspectiveCorrected,
    int? rotation,
    List<SignaturePlacementModel>? signaturePlacements,
  }) {
    return ScanResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      detectedCorners: detectedCorners ?? this.detectedCorners,
      capturedAt: capturedAt ?? this.capturedAt,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      isPerspectiveCorrected: isPerspectiveCorrected ?? this.isPerspectiveCorrected,
      rotation: rotation ?? this.rotation,
      signaturePlacements: signaturePlacements ?? this.signaturePlacements,
    );
  }
}

/// Corner point for document detection
class ScanCorner {
  final double x;
  final double y;

  const ScanCorner({required this.x, required this.y});

  @override
  String toString() => 'ScanCorner(x: $x, y: $y)';
}

/// Available image filters
enum ScanFilter {
  original,
  blackAndWhite,
  magicColor,
  grayscale,
}

/// Extension for filter display names
extension ScanFilterExtension on ScanFilter {
  String get displayName {
    switch (this) {
      case ScanFilter.original:
        return 'Original';
      case ScanFilter.blackAndWhite:
        return 'B&W';
      case ScanFilter.magicColor:
        return 'Magic';
      case ScanFilter.grayscale:
        return 'Gray';
    }
  }

  String get icon {
    switch (this) {
      case ScanFilter.original:
        return '📷';
      case ScanFilter.blackAndWhite:
        return '⬛';
      case ScanFilter.magicColor:
        return '✨';
      case ScanFilter.grayscale:
        return '🔲';
    }
  }
}

/// Flash modes for the camera
enum CameraFlashMode {
  auto,
  on,
  off,
}

extension CameraFlashModeExtension on CameraFlashMode {
  String get displayName {
    switch (this) {
      case CameraFlashMode.auto:
        return 'Auto';
      case CameraFlashMode.on:
        return 'On';
      case CameraFlashMode.off:
        return 'Off';
    }
  }
}

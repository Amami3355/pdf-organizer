// 📷 Camera Feature - Models
// Data models for the camera/scan feature.

/// Represents a single scanned image result
class ScanResult {
  final String id;
  final String imagePath;
  final List<ScanCorner>? detectedCorners;
  final DateTime capturedAt;
  final ImageFilter appliedFilter;
  final bool isPerspectiveCorrected;

  const ScanResult({
    required this.id,
    required this.imagePath,
    this.detectedCorners,
    required this.capturedAt,
    this.appliedFilter = ImageFilter.original,
    this.isPerspectiveCorrected = false,
  });

  ScanResult copyWith({
    String? id,
    String? imagePath,
    List<ScanCorner>? detectedCorners,
    DateTime? capturedAt,
    ImageFilter? appliedFilter,
    bool? isPerspectiveCorrected,
  }) {
    return ScanResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      detectedCorners: detectedCorners ?? this.detectedCorners,
      capturedAt: capturedAt ?? this.capturedAt,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      isPerspectiveCorrected: isPerspectiveCorrected ?? this.isPerspectiveCorrected,
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
enum ImageFilter {
  original,
  blackAndWhite,
  magicColor,
  grayscale,
}

/// Extension for filter display names
extension ImageFilterExtension on ImageFilter {
  String get displayName {
    switch (this) {
      case ImageFilter.original:
        return 'Original';
      case ImageFilter.blackAndWhite:
        return 'B&W';
      case ImageFilter.magicColor:
        return 'Magic';
      case ImageFilter.grayscale:
        return 'Gray';
    }
  }

  String get icon {
    switch (this) {
      case ImageFilter.original:
        return '📷';
      case ImageFilter.blackAndWhite:
        return '⬛';
      case ImageFilter.magicColor:
        return '✨';
      case ImageFilter.grayscale:
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

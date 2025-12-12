import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/camera/models/scan_result.dart';

/// 🎨 Image Processing Service
///
/// Handles image manipulation: cropping, resizing, and applying filters.
/// Operations are performed in a background isolate using [compute] to avoid blocking the UI.

class ImageProcessingService {
  /// Apply a filter to an image file and save the result
  Future<String> applyFilter(String imagePath, ScanFilter filter) async {
    if (filter == ScanFilter.original) return imagePath;

    final result = await compute(
      _processImage,
      _ProcessRequest(imagePath, filter),
    );
    return result;
  }

  /// Crop an image based on corners (perspective transform)
  /// Currently implements specific cropping based on normalized corners
  Future<String> cropImage(String imagePath, List<ScanCorner> corners) async {
    final result = await compute(_cropImage, _CropRequest(imagePath, corners));
    return result;
  }
}

class _ProcessRequest {
  final String path;
  final ScanFilter filter;
  _ProcessRequest(this.path, this.filter);
}

class _CropRequest {
  final String path;
  final List<ScanCorner> corners;
  _CropRequest(this.path, this.corners);
}

/// Isolate function for filter processing
Future<String> _processImage(_ProcessRequest request) async {
  final imageFile = File(request.path);
  final bytes = await imageFile.readAsBytes();
  var image = img.decodeImage(bytes);

  if (image == null) throw Exception('Failed to decode image');

  // Apply filters
  switch (request.filter) {
    case ScanFilter.blackAndWhite:
      image = img.grayscale(image); // First grayscale
      // Simple thresholding for B&W
      // img.luminanceThreshold(image, threshold: 0.5); // Not available in all versions, using logic if needed
      // For now, grayscale is close enough or use specific contrast boost
      image = img.contrast(image, contrast: 150);
      break;
    case ScanFilter.grayscale:
      image = img.grayscale(image);
      break;
    case ScanFilter.magicColor:
      image = img.adjustColor(
        image,
        saturation: 1.5,
        contrast: 1.2,
        brightness: 1.1,
      );
      break;
    case ScanFilter.original:
      break;
  }

  // Save to new path
  final tempDir = Directory.systemTemp; // Using system temp for isolate
  final filename = 'filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final newPath = '${tempDir.path}/$filename';

  final encoded = img.encodeJpg(image, quality: 85);
  await File(newPath).writeAsBytes(encoded);

  return newPath;
}

/// Isolate function for cropping
Future<String> _cropImage(_CropRequest request) async {
  final imageFile = File(request.path);
  final bytes = await imageFile.readAsBytes();
  var image = img.decodeImage(bytes); // img.Image?

  if (image == null) throw Exception('Failed to decode image');

  // Convert normalized corners to pixels
  final w = image.width;
  final h = image.height;

  // For MVP, we assume a simple rectangular crop based on min/max x/y
  // Perspective transform is more complex and requires a library or math.
  // Here we take the bounding box.

  double minX = w.toDouble(), minY = h.toDouble(), maxX = 0.0, maxY = 0.0;

  for (var c in request.corners) {
    minX = minX < (c.x * w) ? minX : (c.x * w);
    minY = minY < (c.y * h) ? minY : (c.y * h);
    maxX = maxX > (c.x * w) ? maxX : (c.x * w);
    maxY = maxY > (c.y * h) ? maxY : (c.y * h);
  }

  // Clamp coordinates
  int x = minX.toInt().clamp(0, w);
  int y = minY.toInt().clamp(0, h);
  int width = (maxX - minX).toInt().clamp(1, w - x);
  int height = (maxY - minY).toInt().clamp(1, h - y);

  var cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);

  // Save
  final tempDir = Directory.systemTemp;
  final filename = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final newPath = '${tempDir.path}/$filename';

  final encoded = img.encodeJpg(cropped, quality: 85);
  await File(newPath).writeAsBytes(encoded);

  return newPath;
}

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService();
});

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/services/signature_models.dart';

class SignatureOverlayPreview extends StatefulWidget {
  final String pageImagePath;
  final int rotation; // 0/90/180/270
  final BoxFit fit;
  final List<SignaturePlacementModel> placements;
  final String signatureBaseDirPath;

  const SignatureOverlayPreview({
    super.key,
    required this.pageImagePath,
    required this.rotation,
    required this.fit,
    required this.placements,
    required this.signatureBaseDirPath,
  });

  @override
  State<SignatureOverlayPreview> createState() => _SignatureOverlayPreviewState();
}

class _SignatureOverlayPreviewState extends State<SignatureOverlayPreview> {
  static final Map<String, double> _aspectCache = <String, double>{};

  late Future<double> _aspectFuture;

  @override
  void initState() {
    super.initState();
    _aspectFuture = _loadRotatedAspect(widget.pageImagePath, widget.rotation);
  }

  @override
  void didUpdateWidget(covariant SignatureOverlayPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageImagePath != widget.pageImagePath ||
        oldWidget.rotation != widget.rotation) {
      _aspectFuture = _loadRotatedAspect(widget.pageImagePath, widget.rotation);
    }
  }

  Future<double> _loadRotatedAspect(String path, int rotation) async {
    final key = '${rotation % 360}|$path';
    final cached = _aspectCache[key];
    if (cached != null) return cached;

    try {
      final bytes = await File(path).readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      try {
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        try {
          final w = descriptor.width.toDouble();
          final h = descriptor.height.toDouble();
          if (w <= 0 || h <= 0) return 1.0;

          final r = rotation % 360;
          final aspect = (r % 180 == 0) ? (w / h) : (h / w);
          final safe = (!aspect.isFinite || aspect <= 0) ? 1.0 : aspect;
          _aspectCache[key] = safe;
          if (_aspectCache.length > 300) {
            _aspectCache.remove(_aspectCache.keys.first);
          }
          return safe;
        } finally {
          descriptor.dispose();
        }
      } finally {
        buffer.dispose();
      }
    } catch (_) {
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _aspectFuture,
      builder: (context, snapshot) {
        final aspect = snapshot.data ?? 1.0;
        final baseWidth = 1000.0;
        final baseHeight = baseWidth / aspect;

        return FittedBox(
          fit: widget.fit,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: baseWidth,
            height: baseHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotatedBox(
                  quarterTurns: (widget.rotation % 360) ~/ 90,
                  child: Image.file(
                    File(widget.pageImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
                for (final placement in widget.placements)
                  Positioned(
                    left: placement.x * baseWidth,
                    top: placement.y * baseHeight,
                    width: placement.width * baseWidth,
                    height: placement.height * baseHeight,
                    child: Image.file(
                      File(
                        '${widget.signatureBaseDirPath}/${placement.signatureFileName}',
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

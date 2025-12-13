import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import '../../core/services/signature_models.dart';
import '../camera/models/scan_result.dart';

class PlaceSignatureResult {
  final SignaturePlacementModel? placement;
  final bool removed;

  const PlaceSignatureResult._({
    required this.placement,
    required this.removed,
  });

  const PlaceSignatureResult.applied(SignaturePlacementModel placement)
    : this._(placement: placement, removed: false);

  const PlaceSignatureResult.removed() : this._(placement: null, removed: true);
}

class PlaceSignatureScreen extends ConsumerStatefulWidget {
  final ScanResult page;
  final SignatureModel signature;
  final SignaturePlacementModel? initialPlacement;

  const PlaceSignatureScreen({
    super.key,
    required this.page,
    required this.signature,
    this.initialPlacement,
  });

  @override
  ConsumerState<PlaceSignatureScreen> createState() =>
      _PlaceSignatureScreenState();
}

class _PlaceSignatureScreenState extends ConsumerState<PlaceSignatureScreen> {
  Size? _pageSize;
  Size? _signatureSize;
  Rect? _rectNorm;

  Rect? _gestureStartRect;
  Offset? _gestureStartFocalPoint;
  double _gestureStartScale = 1.0;

  int get _rotation => widget.page.rotation % 360;

  @override
  void initState() {
    super.initState();
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    try {
      final signaturePath = ref
          .read(signatureManagerProvider)
          .resolveSignaturePath(widget.signature);
      final pageSize = await _decodeImageSize(widget.page.imagePath);
      final signatureSize = await _decodeImageSize(signaturePath);
      if (!mounted) return;

      final initial = widget.initialPlacement;
      Rect? rect;
      if (initial != null && initial.signatureId == widget.signature.id) {
        rect = Rect.fromLTWH(
          initial.x,
          initial.y,
          initial.width,
          initial.height,
        );
      }
      rect ??= _defaultRectNorm(
        pageSize: pageSize,
        signatureSize: signatureSize,
      );

      setState(() {
        _pageSize = pageSize;
        _signatureSize = signatureSize;
        _rectNorm = rect;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading images: $e')));
      Navigator.of(context).maybePop();
    }
  }

  Future<Size> _decodeImageSize(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    return size;
  }

  Size _rotatedPageSize(Size original) {
    if (_rotation % 180 == 0) return original;
    return Size(original.height, original.width);
  }

  Rect _defaultRectNorm({required Size pageSize, required Size signatureSize}) {
    final rotatedPage = _rotatedPageSize(pageSize);
    final pageAspect = rotatedPage.width / rotatedPage.height; // W/H
    final sigAspect = signatureSize.height / signatureSize.width; // H/W

    final widthNorm = 0.42;
    final heightNorm = (widthNorm * pageAspect * sigAspect).clamp(0.05, 0.9);
    const margin = 0.06;

    return _clampRect(
      Rect.fromLTWH(
        1 - widthNorm - margin,
        1 - heightNorm - margin,
        widthNorm,
        heightNorm,
      ),
    );
  }

  Rect _clampRect(Rect rect) {
    const minW = 0.12;
    const minH = 0.05;
    const maxW = 0.95;
    const maxH = 0.95;

    final w = rect.width.clamp(minW, maxW);
    final h = rect.height.clamp(minH, maxH);

    var left = rect.left;
    var top = rect.top;
    if (left < 0) left = 0;
    if (top < 0) top = 0;
    if (left + w > 1) left = 1 - w;
    if (top + h > 1) top = 1 - h;
    return Rect.fromLTWH(left, top, w, h);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartRect = _rectNorm;
    _gestureStartFocalPoint = details.focalPoint;
    _gestureStartScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size containerSize) {
    if (_gestureStartRect == null || _gestureStartFocalPoint == null) return;
    final start = _gestureStartRect!;

    final dx = details.focalPoint.dx - _gestureStartFocalPoint!.dx;
    final dy = details.focalPoint.dy - _gestureStartFocalPoint!.dy;
    final translate = Offset(
      dx / containerSize.width,
      dy / containerSize.height,
    );

    final scaleFactor = (details.scale / _gestureStartScale).clamp(0.3, 6.0);

    final scaled = Rect.fromCenter(
      center: start.center,
      width: start.width * scaleFactor,
      height: start.height * scaleFactor,
    );
    final moved = scaled.shift(translate);

    setState(() => _rectNorm = _clampRect(moved));
  }

  void _apply() {
    final rect = _rectNorm;
    if (rect == null) return;

    final placement = SignaturePlacementModel(
      signatureId: widget.signature.id,
      signatureFileName: widget.signature.fileName,
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
    Navigator.of(context).pop(PlaceSignatureResult.applied(placement));
  }

  void _remove() {
    Navigator.of(context).pop(const PlaceSignatureResult.removed());
  }

  @override
  Widget build(BuildContext context) {
    final pageSize = _pageSize;
    final signatureSize = _signatureSize;
    if (pageSize == null || signatureSize == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rotatedPage = _rotatedPageSize(pageSize);
    final pageAspect = rotatedPage.width / rotatedPage.height;
    final signaturePath = ref
        .read(signatureManagerProvider)
        .resolveSignaturePath(widget.signature);

    final hasExistingPlacement = widget.initialPlacement != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place signature'),
        actions: [
          if (hasExistingPlacement)
            IconButton(
              tooltip: 'Remove',
              onPressed: _remove,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _apply, child: const Text('Done')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: AspectRatio(
              aspectRatio: pageAspect,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final rect = _rectNorm!;
                  final rectPx = Rect.fromLTWH(
                    rect.left * w,
                    rect.top * h,
                    rect.width * w,
                    rect.height * h,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RotatedBox(
                            quarterTurns: _rotation ~/ 90,
                            child: Image.file(
                              File(widget.page.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fromRect(
                            rect: rectPx,
                            child: GestureDetector(
                              onScaleStart: _onScaleStart,
                              onScaleUpdate: (d) =>
                                  _onScaleUpdate(d, Size(w, h)),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.95),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Image.file(
                                    File(signaturePath),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Drag to move • Pinch to resize',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

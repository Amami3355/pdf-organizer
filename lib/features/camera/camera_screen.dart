import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';
import 'models/scan_result.dart';
import 'painters/document_overlay_painter.dart';
import 'providers/camera_provider.dart';
import 'widgets/camera_controls.dart';

/// 📷 Camera Screen
/// 
/// Main camera interface for document scanning.
/// Uses CameraAwesome for the camera preview and custom overlay for edge detection.

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayAnimation;
  
  // Simulated document detection corners (will be replaced with ML Kit)
  List<Offset>? _detectedCorners;
  final bool _isDocumentStable = false;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOut,
    );
    _overlayAnimationController.forward();
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    super.dispose();
  }

  Future<String> _getSavePath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/scan_$timestamp.jpg';
  }

  void _onCapture(String imagePath) {
    final scanNotifier = ref.read(scanStateProvider.notifier);
    
    final result = ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      capturedAt: DateTime.now(),
      appliedFilter: ref.read(scanStateProvider).selectedFilter,
    );
    
    scanNotifier.addCapturedImage(result);
    
    // In batch mode, continue scanning. Otherwise, go to preview.
    final state = ref.read(scanStateProvider);
    if (!state.isBatchMode) {
      _navigateToEditor();
    }
  }

  void _navigateToEditor() {
    // Navigate to editor with captured images
    context.push(AppRoutes.editor);
  }

  FlashMode _mapFlashMode(CameraFlashMode mode) {
    switch (mode) {
      case CameraFlashMode.auto:
        return FlashMode.auto;
      case CameraFlashMode.on:
        return FlashMode.always;
      case CameraFlashMode.off:
        return FlashMode.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = ref.watch(scanStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview with CameraAwesome
          CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(
              pathBuilder: (sensors) async {
                final path = await _getSavePath();
                return SingleCaptureRequest(path, sensors.first);
              },
            ),
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              flashMode: _mapFlashMode(scanState.flashMode),
              aspectRatio: CameraAspectRatios.ratio_4_3,
            ),
            previewFit: CameraPreviewFit.cover,
            onMediaCaptureEvent: (event) {
              if (event.status == MediaCaptureStatus.success) {
                final captureRequest = event.captureRequest;
                final path = captureRequest.when(
                  single: (single) => single.file?.path,
                  multiple: (multiple) => multiple.fileBySensor.values.first?.path,
                );
                if (path != null) {
                  _onCapture(path);
                }
              }
            },
            topActionsBuilder: (state) => _buildTopBar(context, l10n, state),
            middleContentBuilder: (state) => _buildOverlay(size),
            bottomActionsBuilder: (state) => _buildBottomBar(context, scanState, state),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n, CameraState camState) {
    final scanState = ref.watch(scanStateProvider);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
            
            // Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.scanNew,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Batch counter
            BatchCounter(
              count: scanState.pageCount,
              onTap: () {
                // Show batch preview
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(Size size) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: DocumentOverlayPainter(
            corners: _detectedCorners,
            isStable: _isDocumentStable,
            animationValue: _overlayAnimation.value,
            previewSize: size,
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, ScanState scanState, CameraState camState) {
    final scanNotifier = ref.read(scanStateProvider.notifier);
    
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter selector (placeholder for now)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ImageFilter.values.map((filter) {
                  final isSelected = scanState.selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => scanNotifier.setSelectedFilter(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        filter.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Main controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash button
                FlashButton(
                  flashMode: scanState.flashMode,
                  onPressed: scanNotifier.toggleFlash,
                ),
                
                // Capture button
                AwesomeCaptureButton(
                  state: camState,
                ),
                
                // Done button
                DoneButton(
                  pageCount: scanState.pageCount,
                  onPressed: _navigateToEditor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

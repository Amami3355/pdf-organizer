import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';
import 'models/scan_result.dart';
import 'providers/camera_provider.dart';

/// 📷 Camera Screen
///
/// Cross-platform scan using `cunning_document_scanner`:
/// - Android: Google ML Kit document scanner (auto capture + edge detection + crop)
/// - iOS: VisionKit document camera (auto crop)
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isScanning = false;
  String? _error;

  bool get _fromEditor =>
      GoRouterState.of(context).uri.queryParameters['from'] == 'editor';

  void _finishFlow() {
    if (_fromEditor) {
      context.pop();
    } else {
      context.pushReplacement(AppRoutes.editor);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _error = null;
    });

    // Always start with a fresh batch for this scan session.
    ref.read(scanStateProvider.notifier).clearBatch();

    try {
      final images = await CunningDocumentScanner.getPictures(
        noOfPages: 24,
        isGalleryImportAllowed: true,
        iosScannerOptions: const IosScannerOptions(
          imageFormat: IosImageFormat.jpg,
          jpgCompressionQuality: 0.85,
        ),
      );

      if (!mounted) return;

      // User cancelled.
      if (images == null || images.isEmpty) {
        context.pop();
        return;
      }

      final now = DateTime.now();
      final pages = <ScanResult>[];
      for (int i = 0; i < images.length; i++) {
        pages.add(
          ScanResult(
            id: '${now.millisecondsSinceEpoch}_$i',
            imagePath: images[i],
            detectedCorners: null, // already cropped by native scanner
            capturedAt: now,
            appliedFilter: ScanFilter.original,
            isPerspectiveCorrected: true,
          ),
        );
      }

      ref.read(scanStateProvider.notifier).setCapturedImages(pages);
      _finishFlow();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.document_scanner, color: Colors.white, size: 72),
              const SizedBox(height: 16),
              Text(
                l10n.scanNew,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ??
                    'Détection automatique des bords, recadrage et filtres.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.3),
              ),
              const SizedBox(height: 24),
              if (_isScanning)
                const CircularProgressIndicator(color: Colors.white)
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Scanner'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _openAppSettings,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: const Text('Ouvrir les réglages'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

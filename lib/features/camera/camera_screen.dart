import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';
import 'models/scan_result.dart';
import 'providers/camera_provider.dart';

/// 📷 Camera Screen
///
/// Launches the native ML Kit Document Scanner (Google Play services) to handle
/// edge detection, capture, and post-processing with a high-quality UI.

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isLaunching = false;
  String? _error;

  void _navigateToEditor() {
    // Check if we came from editor
    final shouldPop =
        GoRouterState.of(context).uri.queryParameters['from'] == 'editor';

    if (shouldPop) {
      context.pop();
    } else {
      // Allow replacement to avoid stacking too many pages and cameras
      context.pushReplacement(AppRoutes.editor);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDocumentScanner();
    });
  }

  Future<void> _startDocumentScanner() async {
    if (!mounted || _isLaunching) return;

    if (!Platform.isAndroid) {
      setState(() {
        _error = 'Le scanner ML Kit n’est disponible que sur Android.';
        _isLaunching = false;
      });
      return;
    }

    setState(() {
      _isLaunching = true;
      _error = null;
    });

    try {
      final options = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.full, // full UI: filters + crop + rotation
        pageLimit: 24, // allow generous multi-page sessions
        isGalleryImport: true,
      );

      final scanner = DocumentScanner(options: options);
      final result = await scanner.scanDocument();
      await scanner.close();

      if (!mounted) return;

      // If user cancels or no images, just pop back.
      if (result.images.isEmpty) {
        context.pop();
        return;
      }

      final now = DateTime.now();
      final pages = <ScanResult>[];
      for (int i = 0; i < result.images.length; i++) {
        pages.add(
          ScanResult(
            id: '${now.millisecondsSinceEpoch}_$i',
            imagePath: result.images[i],
            detectedCorners: null, // ML Kit already crops; corners not exposed
            capturedAt: now,
            appliedFilter: ScanFilter.original,
            isPerspectiveCorrected: true,
          ),
        );
      }

      // Replace batch with scanned pages
      ref.read(scanStateProvider.notifier).setCapturedImages(pages);

      // Navigate to editor
      _navigateToEditor();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.document_scanner, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                l10n.scanNew,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error == null
                    ? 'Lancement du scanner ML Kit (bordures auto, filtres, multi-page)...'
                    : 'Échec du scanner : $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (_isLaunching)
                const CircularProgressIndicator(color: Colors.white)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _startDocumentScanner,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Relancer le scan'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Annuler'),
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

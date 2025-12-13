import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/camera/models/scan_result.dart';

/// Service to generate PDF documents from scanned pages
class PdfGeneratorService {
  /// Generate a PDF file from a list of ScanResult pages
  Future<File> generatePdf(
    List<ScanResult> pages, {
    String fileName = 'scan_document.pdf',
    Directory? outputDirectory,
  }) async {
    final pdf = pw.Document();
    final appDocs = await getApplicationDocumentsDirectory();
    final signatureCache = <String, img.Image>{};

    for (final page in pages) {
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final hasSignatures = page.signaturePlacements.isNotEmpty;

      // Fast path: no signature overlays, keep the lightweight PDF transform.
      if (!hasSignatures) {
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Transform.rotate(
                  angle: page.rotation * math.pi / 180,
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              );
            },
            margin: pw.EdgeInsets.zero,
          ),
        );
        continue;
      }

      // Signed pages: rotate pixels and composite signature overlays before embedding.
      var decoded = img.decodeImage(imageBytes);
      if (decoded == null) continue;

      if ((page.rotation % 360) != 0) {
        decoded = img.copyRotate(decoded, angle: page.rotation);
      }

      for (final placement in page.signaturePlacements) {
        final rel = placement.signatureFileName;
        final signatureFile = File('${appDocs.path}/$rel');
        if (!await signatureFile.exists()) continue;

        var signature = signatureCache[rel];
        if (signature == null) {
          final sigBytes = await signatureFile.readAsBytes();
          signature = img.decodeImage(sigBytes);
          if (signature == null) continue;
          signatureCache[rel] = signature;
        }

        var dstX = (placement.x * decoded.width).round();
        var dstY = (placement.y * decoded.height).round();
        var dstW = (placement.width * decoded.width).round();
        var dstH = (placement.height * decoded.height).round();

        if (dstW <= 0 || dstH <= 0) continue;

        if (dstX < 0) {
          dstW += dstX;
          dstX = 0;
        }
        if (dstY < 0) {
          dstH += dstY;
          dstY = 0;
        }
        if (dstX + dstW > decoded.width) {
          dstW = decoded.width - dstX;
        }
        if (dstY + dstH > decoded.height) {
          dstH = decoded.height - dstY;
        }

        if (dstW <= 0 || dstH <= 0) continue;

        img.compositeImage(
          decoded,
          signature,
          dstX: dstX,
          dstY: dstY,
          dstW: dstW,
          dstH: dstH,
        );
      }

      final composedBytes = Uint8List.fromList(
        img.encodeJpg(decoded, quality: 90),
      );
      final composed = pw.MemoryImage(composedBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(composed, fit: pw.BoxFit.contain));
          },
          margin: pw.EdgeInsets.zero,
        ),
      );
    }

    final output = outputDirectory ?? await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

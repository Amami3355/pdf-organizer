import 'dart:io';
import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/camera/models/scan_result.dart';

/// Service to generate PDF documents from scanned pages
class PdfGeneratorService {
  
  /// Generate a PDF file from a list of ScanResult pages
  Future<File> generatePdf(List<ScanResult> pages, {String fileName = 'scan_document.pdf'}) async {
    final pdf = pw.Document();

    for (final page in pages) {
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      // Add page to PDF
      // We calculate aspect ratio or fit to page?
      // Usually full page image.
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
               child: pw.Transform.rotate(
                 angle: page.rotation * math.pi / 180,
                 child: pw.Image(
                   image,
                   fit: pw.BoxFit.contain,
                 ),
               ),
            );
          },
          margin:  pw.EdgeInsets.zero, // Full bleed or small margin?
          // If we want margin:
          // margin: const pw.EdgeInsets.all(20),
          // But for scans, typically we want full size or close to it.
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

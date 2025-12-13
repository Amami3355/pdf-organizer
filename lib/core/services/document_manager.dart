import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../features/camera/models/scan_result.dart';
import 'document_models.dart';
import 'pdf_generator_service.dart';

class DocumentManager {
  DocumentManager._();

  static final DocumentManager instance = DocumentManager._();

  static const int _schemaVersion = 1;
  static const String _metaBoxName = 'documents_meta';
  static const String _documentsBoxName = 'documents_data';
  static const String _schemaVersionKey = 'schema_version';

  bool _initialized = false;
  late final Box _metaBox;
  late final Box _documentsBox;
  late final Directory _baseDir;
  late final PdfGeneratorService _pdfService;

  Directory get documentsDir => Directory('${_baseDir.path}/documents');
  Directory get thumbnailsDir => Directory('${_baseDir.path}/thumbnails');
  Directory get pagesRootDir => Directory('${_baseDir.path}/pages');
  Directory get tmpRootDir => Directory('${_baseDir.path}/tmp');

  Future<void> init({PdfGeneratorService? pdfService}) async {
    if (_initialized) return;

    _pdfService = pdfService ?? PdfGeneratorService();

    _metaBox = await Hive.openBox(_metaBoxName);
    final current = _metaBox.get(_schemaVersionKey);
    if (current == null) {
      await _metaBox.put(_schemaVersionKey, _schemaVersion);
    } else if (current != _schemaVersion) {
      debugPrint(
        'DocumentManager: schema version mismatch ($current != $_schemaVersion).',
      );
      // Future migration hook (keep running for now).
    }

    _documentsBox = await Hive.openBox(_documentsBoxName);

    _baseDir = await getApplicationDocumentsDirectory();
    await _ensureDirectories();
    _initialized = true;

    debugPrint('DocumentManager: Initialized (${_baseDir.path})');
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('DocumentManager not initialized. Call init() first.');
    }
  }

  Future<void> _ensureDirectories() async {
    await documentsDir.create(recursive: true);
    await thumbnailsDir.create(recursive: true);
    await pagesRootDir.create(recursive: true);
    await tmpRootDir.create(recursive: true);
  }

  List<DocumentModel> _readAllSync() {
    final docs = <DocumentModel>[];
    for (final entry in _documentsBox.toMap().entries) {
      final value = entry.value;
      if (value is! Map) continue;
      try {
        docs.add(DocumentModel.fromJson(Map<String, dynamic>.from(value)));
      } catch (e) {
        debugPrint('DocumentManager: Failed to parse document: $e');
      }
    }

    docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return docs;
  }

  Future<List<DocumentModel>> listDocuments() async {
    _ensureInitialized();
    return _readAllSync();
  }

  Stream<List<DocumentModel>> watchDocuments() async* {
    _ensureInitialized();
    yield _readAllSync();
    await for (final _ in _documentsBox.watch()) {
      yield _readAllSync();
    }
  }

  DocumentModel? getDocumentSync(String documentId) {
    _ensureInitialized();
    final raw = _documentsBox.get(documentId);
    if (raw is! Map) return null;
    return DocumentModel.fromJson(Map<String, dynamic>.from(raw));
  }

  String resolvePdfPath(DocumentModel document) {
    _ensureInitialized();
    return File('${documentsDir.path}/${document.pdfFileName}').path;
  }

  String? resolveThumbnailPath(DocumentModel document) {
    _ensureInitialized();
    final fileName = document.thumbnailFileName;
    if (fileName == null || fileName.isEmpty) return null;
    return File('${thumbnailsDir.path}/$fileName').path;
  }

  String resolvePagePath(DocumentPageModel page) {
    _ensureInitialized();
    return File('${_baseDir.path}/${page.imageFileName}').path;
  }

  Future<List<ScanResult>> loadDocumentPages(String documentId) async {
    _ensureInitialized();
    final document = getDocumentSync(documentId);
    if (document == null) return const [];

    return document.pages
        .map(
          (p) => ScanResult(
            id: p.id,
            imagePath: resolvePagePath(p),
            capturedAt: document.createdAt,
            appliedFilter: p.appliedFilter,
            isPerspectiveCorrected: true,
            rotation: p.rotation,
            signaturePlacements: p.signaturePlacements,
          ),
        )
        .toList();
  }

  Future<DocumentModel> reorderDocumentPages({
    required String documentId,
    required List<DocumentPageModel> pages,
  }) async {
    _ensureInitialized();
    if (pages.isEmpty) {
      throw ArgumentError.value(pages, 'pages', 'Must not be empty');
    }

    final existing = getDocumentSync(documentId);
    if (existing == null) {
      throw StateError('Document not found: $documentId');
    }

    final now = DateTime.now();
    final thumbFileName = (existing.thumbnailFileName?.trim().isNotEmpty ??
            false)
        ? existing.thumbnailFileName!
        : '$documentId.jpg';

    final tmpRoot = Directory(
      '${tmpRootDir.path}/$documentId.reorder.${now.millisecondsSinceEpoch}',
    );
    final tmpDocuments = Directory('${tmpRoot.path}/documents');
    final tmpThumbnails = Directory('${tmpRoot.path}/thumbnails');

    await tmpDocuments.create(recursive: true);
    await tmpThumbnails.create(recursive: true);

    try {
      final scanPages = pages
          .map(
            (p) => ScanResult(
              id: p.id,
              imagePath: resolvePagePath(p),
              capturedAt: existing.createdAt,
              appliedFilter: p.appliedFilter,
              isPerspectiveCorrected: true,
              rotation: p.rotation,
              signaturePlacements: p.signaturePlacements,
            ),
          )
          .toList();

      for (final page in scanPages) {
        final file = File(page.imagePath);
        if (!await file.exists()) {
          throw StateError('Missing page file: ${file.path}');
        }
      }

      final pdfFile = await _pdfService.generatePdf(
        scanPages,
        fileName: existing.pdfFileName,
        outputDirectory: tmpDocuments,
      );
      final pdfSizeBytes = await pdfFile.length();

      final thumbDest = File('${tmpThumbnails.path}/$thumbFileName');
      await _generateThumbnail(
        sourceImage: File(scanPages.first.imagePath),
        destinationFile: thumbDest,
      );

      final finalPdf = File('${documentsDir.path}/${existing.pdfFileName}');
      if (await finalPdf.exists()) {
        await finalPdf.delete();
      }
      await pdfFile.rename(finalPdf.path);

      if (await thumbDest.exists()) {
        final finalThumb = File('${thumbnailsDir.path}/$thumbFileName');
        if (await finalThumb.exists()) {
          await finalThumb.delete();
        }
        await thumbDest.rename(finalThumb.path);
      }

      final updated = existing.copyWith(
        updatedAt: now,
        pages: pages,
        pdfSizeBytes: pdfSizeBytes,
        thumbnailFileName: thumbFileName,
        isSigned: pages.any((p) => p.signaturePlacements.isNotEmpty),
      );
      await _documentsBox.put(documentId, updated.toJson());
      return updated;
    } finally {
      if (await tmpRoot.exists()) {
        await tmpRoot.delete(recursive: true);
      }
    }
  }

  Future<void> deleteDocument(String documentId) async {
    _ensureInitialized();

    final existing = getDocumentSync(documentId);
    await _documentsBox.delete(documentId);

    final pdfFileName = existing?.pdfFileName ?? '$documentId.pdf';
    final thumbFileName = existing?.thumbnailFileName ?? '$documentId.jpg';

    final pdfFile = File('${documentsDir.path}/$pdfFileName');
    final thumbFile = File('${thumbnailsDir.path}/$thumbFileName');
    final pagesDir = Directory('${pagesRootDir.path}/$documentId');

    await Future.wait([
      if (await pdfFile.exists()) pdfFile.delete(),
      if (await thumbFile.exists()) thumbFile.delete(),
      if (await pagesDir.exists()) pagesDir.delete(recursive: true),
    ]);
  }

  Future<void> updateTitle(String documentId, String title) async {
    _ensureInitialized();
    final existing = getDocumentSync(documentId);
    if (existing == null) return;

    final updated = existing.copyWith(
      title: title.trim(),
      updatedAt: DateTime.now(),
    );
    await _documentsBox.put(documentId, updated.toJson());
  }

  Future<void> markSigned(String documentId, {required bool isSigned}) async {
    _ensureInitialized();
    final existing = getDocumentSync(documentId);
    if (existing == null) return;

    final updated = existing.copyWith(
      isSigned: isSigned,
      updatedAt: DateTime.now(),
    );
    await _documentsBox.put(documentId, updated.toJson());
  }

  Future<DocumentModel> createDocumentFromPages({
    required String title,
    required List<ScanResult> pages,
    DocumentSource source = DocumentSource.scan,
  }) async {
    _ensureInitialized();
    if (pages.isEmpty) {
      throw ArgumentError.value(pages, 'pages', 'Must not be empty');
    }

    final docId = _newId();
    final now = DateTime.now();
    final titleTrimmed = title.trim();
    final defaultPrefix = source == DocumentSource.importPdf
        ? 'Import'
        : 'Scan';
    final safeTitle = titleTrimmed.isEmpty
        ? '$defaultPrefix ${_formatDate(now)}'
        : titleTrimmed;

    final pdfFileName = '$docId.pdf';
    final thumbFileName = '$docId.jpg';

    final tmpRoot = Directory('${tmpRootDir.path}/$docId');
    final tmpDocuments = Directory('${tmpRoot.path}/documents');
    final tmpThumbnails = Directory('${tmpRoot.path}/thumbnails');
    final tmpPagesDir = Directory('${tmpRoot.path}/pages/$docId');

    await tmpDocuments.create(recursive: true);
    await tmpThumbnails.create(recursive: true);
    await tmpPagesDir.create(recursive: true);

    try {
      final stagedPages = <ScanResult>[];
      final pageModels = <DocumentPageModel>[];

      for (int i = 0; i < pages.length; i++) {
        final src = File(pages[i].imagePath);
        if (!await src.exists()) {
          throw StateError('Missing page file: ${src.path}');
        }

        final ext = _extensionOrDefault(src.path, 'jpg');
        final pageFileName = '${i.toString().padLeft(4, '0')}.$ext';
        final relative = 'pages/$docId/$pageFileName';
        final dest = File('${tmpRoot.path}/$relative');
        await dest.parent.create(recursive: true);
        await src.copy(dest.path);

        final pageId = '${docId}_$i';
        pageModels.add(
          DocumentPageModel(
            id: pageId,
            imageFileName: relative,
            rotation: pages[i].rotation,
            appliedFilter: pages[i].appliedFilter,
            signaturePlacements: pages[i].signaturePlacements,
          ),
        );

        stagedPages.add(pages[i].copyWith(id: pageId, imagePath: dest.path));
      }

      final pdfFile = await _pdfService.generatePdf(
        stagedPages,
        fileName: pdfFileName,
        outputDirectory: tmpDocuments,
      );
      final pdfSizeBytes = await pdfFile.length();

      final thumbDest = File('${tmpThumbnails.path}/$thumbFileName');
      await _generateThumbnail(
        sourceImage: File(stagedPages.first.imagePath),
        destinationFile: thumbDest,
      );

      await _commitStaged(
        tmpRoot: tmpRoot,
        docId: docId,
        pdfFileName: pdfFileName,
        thumbFileName: thumbFileName,
      );

      final document = DocumentModel(
        id: docId,
        title: safeTitle,
        pdfFileName: pdfFileName,
        thumbnailFileName: thumbFileName,
        createdAt: now,
        updatedAt: now,
        source: source,
        pages: pageModels,
        pdfSizeBytes: pdfSizeBytes,
        isSigned: pageModels.any((p) => p.signaturePlacements.isNotEmpty),
      );

      await _documentsBox.put(docId, document.toJson());
      return document;
    } catch (_) {
      // Best-effort cleanup.
      if (await tmpRoot.exists()) {
        await tmpRoot.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<DocumentModel> updateDocumentFromPages({
    required String documentId,
    required List<ScanResult> pages,
    String? title,
  }) async {
    _ensureInitialized();
    if (pages.isEmpty) {
      throw ArgumentError.value(pages, 'pages', 'Must not be empty');
    }

    final existing = getDocumentSync(documentId);
    if (existing == null) {
      throw StateError('Document not found: $documentId');
    }

    final now = DateTime.now();
    final nextTitle = (title ?? existing.title).trim();

    final pdfFileName = existing.pdfFileName;
    final thumbFileName =
        (existing.thumbnailFileName?.trim().isNotEmpty ?? false)
        ? existing.thumbnailFileName!
        : '$documentId.jpg';

    final tmpRoot = Directory('${tmpRootDir.path}/$documentId');
    final tmpDocuments = Directory('${tmpRoot.path}/documents');
    final tmpThumbnails = Directory('${tmpRoot.path}/thumbnails');
    final tmpPagesDir = Directory('${tmpRoot.path}/pages/$documentId');

    await tmpDocuments.create(recursive: true);
    await tmpThumbnails.create(recursive: true);
    await tmpPagesDir.create(recursive: true);

    try {
      final stagedPages = <ScanResult>[];
      final pageModels = <DocumentPageModel>[];

      for (int i = 0; i < pages.length; i++) {
        final src = File(pages[i].imagePath);
        if (!await src.exists()) {
          throw StateError('Missing page file: ${src.path}');
        }

        final ext = _extensionOrDefault(src.path, 'jpg');
        final pageFileName = '${i.toString().padLeft(4, '0')}.$ext';
        final relative = 'pages/$documentId/$pageFileName';
        final dest = File('${tmpRoot.path}/$relative');
        await dest.parent.create(recursive: true);
        await src.copy(dest.path);

        final pageId = '${documentId}_$i';
        pageModels.add(
          DocumentPageModel(
            id: pageId,
            imageFileName: relative,
            rotation: pages[i].rotation,
            appliedFilter: pages[i].appliedFilter,
            signaturePlacements: pages[i].signaturePlacements,
          ),
        );

        stagedPages.add(pages[i].copyWith(id: pageId, imagePath: dest.path));
      }

      final pdfFile = await _pdfService.generatePdf(
        stagedPages,
        fileName: pdfFileName,
        outputDirectory: tmpDocuments,
      );
      final pdfSizeBytes = await pdfFile.length();

      final thumbDest = File('${tmpThumbnails.path}/$thumbFileName');
      await _generateThumbnail(
        sourceImage: File(stagedPages.first.imagePath),
        destinationFile: thumbDest,
      );

      await _commitStaged(
        tmpRoot: tmpRoot,
        docId: documentId,
        pdfFileName: pdfFileName,
        thumbFileName: thumbFileName,
      );

      final updated = existing.copyWith(
        title: nextTitle.isEmpty ? existing.title : nextTitle,
        updatedAt: now,
        pages: pageModels,
        pdfSizeBytes: pdfSizeBytes,
        thumbnailFileName: thumbFileName,
        isSigned: pageModels.any((p) => p.signaturePlacements.isNotEmpty),
      );

      await _documentsBox.put(documentId, updated.toJson());
      return updated;
    } catch (_) {
      if (await tmpRoot.exists()) {
        await tmpRoot.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<DocumentModel> mergeDocuments({
    required List<String> documentIds,
    String title = '',
  }) async {
    _ensureInitialized();
    if (documentIds.length < 2) {
      throw ArgumentError.value(
        documentIds,
        'documentIds',
        'Provide at least 2 documents',
      );
    }

    final mergedPages = <ScanResult>[];
    for (final id in documentIds) {
      mergedPages.addAll(await loadDocumentPages(id));
    }

    final safeTitle = title.trim().isEmpty
        ? 'Merged ${_formatDate(DateTime.now())}'
        : title.trim();

    return createDocumentFromPages(
      title: safeTitle,
      pages: mergedPages,
      source: DocumentSource.scan,
    );
  }

  Future<List<DocumentModel>> splitDocumentByGroups({
    required String documentId,
    required List<List<int>> pageIndexGroups,
    String baseTitle = '',
  }) async {
    _ensureInitialized();
    final existing = getDocumentSync(documentId);
    if (existing == null) {
      throw StateError('Document not found: $documentId');
    }

    final allPages = await loadDocumentPages(documentId);
    if (allPages.isEmpty) return const [];

    final effectiveBaseTitle = baseTitle.trim().isEmpty
        ? existing.title
        : baseTitle.trim();

    final results = <DocumentModel>[];
    for (int i = 0; i < pageIndexGroups.length; i++) {
      final indices = pageIndexGroups[i];
      final groupPages = <ScanResult>[];
      for (final index in indices) {
        if (index < 0 || index >= allPages.length) continue;
        groupPages.add(allPages[index]);
      }
      if (groupPages.isEmpty) continue;

      results.add(
        await createDocumentFromPages(
          title: '$effectiveBaseTitle (${i + 1})',
          pages: groupPages,
          source: existing.source,
        ),
      );
    }

    return results;
  }

  /// Option A: Rasterize an imported PDF to page images so it can be edited
  /// using the exact same pipeline as scans (reorder/merge/split/export).
  ///
  /// Returns a list of temporary [ScanResult] pages (stored in the app cache dir).
  Future<List<ScanResult>> rasterizePdfToPages(
    File pdfFile, {
    double dpi = 144,
    int maxPages = 50,
  }) async {
    _ensureInitialized();
    if (!await pdfFile.exists()) {
      throw StateError('PDF file does not exist: ${pdfFile.path}');
    }

    final cacheDir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final outDir = Directory('${cacheDir.path}/pdf_import_$stamp');
    await outDir.create(recursive: true);

    final pdfBytes = await pdfFile.readAsBytes();
    final now = DateTime.now();

    final pages = <ScanResult>[];
    var index = 0;
    await for (final raster in Printing.raster(pdfBytes, dpi: dpi)) {
      if (index >= maxPages) break;

      final pngBytes = await raster.toPng();
      final decoded = img.decodeImage(pngBytes);
      if (decoded == null) {
        index++;
        continue;
      }

      final jpgBytes = img.encodeJpg(decoded, quality: 85);
      final fileName = '${index.toString().padLeft(4, '0')}.jpg';
      final file = File('${outDir.path}/$fileName');
      await file.writeAsBytes(jpgBytes);

      pages.add(
        ScanResult(
          id: '${stamp}_$index',
          imagePath: file.path,
          detectedCorners: null,
          capturedAt: now,
          appliedFilter: ScanFilter.original,
          isPerspectiveCorrected: true,
          rotation: 0,
        ),
      );

      index++;
    }

    return pages;
  }

  Future<void> _commitStaged({
    required Directory tmpRoot,
    required String docId,
    required String pdfFileName,
    required String thumbFileName,
  }) async {
    final stagedPdf = File('${tmpRoot.path}/documents/$pdfFileName');
    final stagedThumb = File('${tmpRoot.path}/thumbnails/$thumbFileName');
    final stagedPages = Directory('${tmpRoot.path}/pages/$docId');

    final finalPdf = File('${documentsDir.path}/$pdfFileName');
    final finalThumb = File('${thumbnailsDir.path}/$thumbFileName');
    final finalPages = Directory('${pagesRootDir.path}/$docId');

    if (await finalPages.exists()) {
      await finalPages.delete(recursive: true);
    }

    await stagedPages.rename(finalPages.path);

    if (await finalPdf.exists()) {
      await finalPdf.delete();
    }
    await stagedPdf.rename(finalPdf.path);

    if (await finalThumb.exists()) {
      await finalThumb.delete();
    }
    await stagedThumb.rename(finalThumb.path);

    // Cleanup remaining staging folder (should be empty-ish).
    if (await tmpRoot.exists()) {
      await tmpRoot.delete(recursive: true);
    }
  }

  Future<void> _generateThumbnail({
    required File sourceImage,
    required File destinationFile,
  }) async {
    try {
      final bytes = await sourceImage.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;

      final resized = img.copyResize(decoded, width: 320);
      final encoded = img.encodeJpg(resized, quality: 80);
      await destinationFile.writeAsBytes(encoded);
    } catch (e) {
      debugPrint('DocumentManager: Failed to generate thumbnail: $e');
    }
  }

  String _newId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  String _extensionOrDefault(String path, String fallback) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return fallback;
    return path.substring(dot + 1).toLowerCase();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

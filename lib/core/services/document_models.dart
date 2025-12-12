import '../../features/camera/models/scan_result.dart';

enum DocumentSource { scan, importPdf }

class DocumentPageModel {
  final String id;

  /// Relative file name (never absolute), e.g. `pages/<docId>/0000.jpg`
  final String imageFileName;
  final int rotation; // 0/90/180/270
  final ScanFilter appliedFilter;

  const DocumentPageModel({
    required this.id,
    required this.imageFileName,
    this.rotation = 0,
    this.appliedFilter = ScanFilter.original,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageFileName': imageFileName,
      'rotation': rotation,
      'appliedFilter': appliedFilter.name,
    };
  }

  factory DocumentPageModel.fromJson(Map<String, dynamic> json) {
    final filterName = json['appliedFilter'] as String?;
    final filter = ScanFilter.values.firstWhere(
      (f) => f.name == filterName,
      orElse: () => ScanFilter.original,
    );

    return DocumentPageModel(
      id: json['id'] as String,
      imageFileName: json['imageFileName'] as String,
      rotation: (json['rotation'] as num?)?.toInt() ?? 0,
      appliedFilter: filter,
    );
  }
}

class DocumentModel {
  final String id;
  final String title;

  /// Relative file name (never absolute), e.g. `<id>.pdf`
  final String pdfFileName;

  /// Relative file name (never absolute), e.g. `<id>.jpg`
  final String? thumbnailFileName;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSigned;
  final DocumentSource source;
  final int pdfSizeBytes;

  /// Persisted pages allow reorder/merge/split even after relaunch.
  final List<DocumentPageModel> pages;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.pdfFileName,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    required this.pages,
    this.thumbnailFileName,
    this.isSigned = false,
    this.pdfSizeBytes = 0,
  });

  int get pageCount => pages.length;

  DocumentModel copyWith({
    String? id,
    String? title,
    String? pdfFileName,
    String? thumbnailFileName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSigned,
    DocumentSource? source,
    int? pdfSizeBytes,
    List<DocumentPageModel>? pages,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSigned: isSigned ?? this.isSigned,
      source: source ?? this.source,
      pdfSizeBytes: pdfSizeBytes ?? this.pdfSizeBytes,
      pages: pages ?? this.pages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'id': id,
      'title': title,
      'pdfFileName': pdfFileName,
      'thumbnailFileName': thumbnailFileName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSigned': isSigned,
      'source': source.name,
      'pdfSizeBytes': pdfSizeBytes,
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source'] as String?;
    final source = DocumentSource.values.firstWhere(
      (s) => s.name == sourceName,
      orElse: () => DocumentSource.scan,
    );

    final rawPages = (json['pages'] as List?) ?? const [];
    final pages = rawPages
        .whereType<Map>()
        .map((p) => DocumentPageModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      pdfFileName: json['pdfFileName'] as String,
      thumbnailFileName: json['thumbnailFileName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSigned: (json['isSigned'] as bool?) ?? false,
      source: source,
      pdfSizeBytes: (json['pdfSizeBytes'] as num?)?.toInt() ?? 0,
      pages: pages,
    );
  }
}

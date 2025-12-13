class SignatureModel {
  final String id;

  /// Display name for the user.
  final String name;

  /// Relative file name (never absolute), e.g. `signatures/<id>.png`
  final String fileName;

  final DateTime createdAt;

  const SignatureModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'id': id,
      'name': name,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Signature',
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SignaturePlacementModel {
  final String signatureId;

  /// Relative file name (never absolute), e.g. `signatures/<id>.png`
  final String signatureFileName;

  /// Normalized coordinates (0..1) relative to the displayed page image
  /// (after applying the page rotation).
  final double x;
  final double y;
  final double width;
  final double height;

  const SignaturePlacementModel({
    required this.signatureId,
    required this.signatureFileName,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  SignaturePlacementModel copyWith({
    String? signatureId,
    String? signatureFileName,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return SignaturePlacementModel(
      signatureId: signatureId ?? this.signatureId,
      signatureFileName: signatureFileName ?? this.signatureFileName,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signatureId': signatureId,
      'signatureFileName': signatureFileName,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory SignaturePlacementModel.fromJson(Map<String, dynamic> json) {
    return SignaturePlacementModel(
      signatureId: json['signatureId'] as String,
      signatureFileName: json['signatureFileName'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }
}


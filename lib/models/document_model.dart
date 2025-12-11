class Document {
  final String id;
  final String title;
  final String size;
  final String timeAgo;
  final String status; // 'Synced', 'OCR Ready', 'Secured'
  final bool isSecured;
  final int pageCount;
  final String previewImage; // For now just a color or placeholder

  Document({
    required this.id,
    required this.title,
    required this.size,
    required this.timeAgo,
    required this.status,
    this.isSecured = false,
    this.pageCount = 1,
    this.previewImage = '',
  });
}

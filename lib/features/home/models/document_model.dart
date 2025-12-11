class Document {
  final String id;
  final String title;
  final String size;
  final String timeAgo;
  final String status; // 'SYNCED', 'OCR READY', 'SECURED'
  final bool isSecured;
  final int pageCount;
  final String previewImage;

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

import '../models/document_model.dart';

class DummyData {
  static List<Document> recentDocuments = [
    Document(
      id: '1',
      title: 'Contract_Final_Signed.pdf',
      size: '2.4 MB',
      timeAgo: '2 mins ago',
      status: 'SYNCED',
      pageCount: 3,
    ),
    Document(
      id: '2',
      title: 'Invoice_Oct_2023.pdf',
      size: '1.1 MB',
      timeAgo: '1 hour ago',
      status: 'OCR READY',
      pageCount: 1,
    ),
    Document(
      id: '3',
      title: 'Legal_Brief_Confidential...',
      size: '4.5 MB',
      timeAgo: 'Yesterday',
      status: 'SECURED',
      isSecured: true,
      pageCount: 12,
    ),
    Document(
      id: '4',
      title: 'Tax_Return_2022.pdf',
      size: '3.2 MB',
      timeAgo: '3 days ago',
      status: 'SYNCED',
      pageCount: 5,
    ),
  ];
}

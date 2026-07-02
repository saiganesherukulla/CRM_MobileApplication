part of 'models.dart';

class LeadDocumentFile {
  final String id;
  final String name;
  final String fileName;
  final String url;
  final String uploadedAt;
  final String contentType;
  final int size;

  const LeadDocumentFile({
    required this.id,
    required this.name,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    required this.contentType,
    required this.size,
  });

  factory LeadDocumentFile.fromJson(Map<String, dynamic> json) {
    return LeadDocumentFile(
      id: _string(json['id']),
      name: _string(json['name'], _string(json['fileName'], 'Document')),
      fileName: _string(json['fileName'], _string(json['name'], 'Document')),
      url: _string(json['url']),
      uploadedAt: _date(json['uploadedAt']),
      contentType: _string(json['contentType']),
      size: _int(json['size']),
    );
  }
}

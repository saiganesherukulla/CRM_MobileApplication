part of 'models.dart';

class LeadTimelineEntry {
  final String status;
  final String notes;
  final String author;
  final String timestamp;
  final List<LeadDocumentFile> documents;

  const LeadTimelineEntry({
    required this.status,
    required this.notes,
    required this.author,
    required this.timestamp,
    required this.documents,
  });

  factory LeadTimelineEntry.fromJson(Map<String, dynamic> json) {
    return LeadTimelineEntry(
      status: _string(json['status'], 'New'),
      notes: _string(json['notes']),
      author: _string(json['author'], 'System'),
      timestamp: _date(json['timestamp']),
      documents:
          _mapList(json['documents']).map(LeadDocumentFile.fromJson).toList(),
    );
  }
}

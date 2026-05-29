part of 'models.dart';

class WorkflowItem {
  final String id;
  final String title;
  final String clientId;
  final String client;
  final String assignee;
  final String priority;
  final String due;
  final List<String> tags;
  final String stage;
  final List<WorkflowDocumentFile> documents;

  const WorkflowItem({
    required this.id,
    required this.title,
    required this.clientId,
    required this.client,
    required this.assignee,
    required this.priority,
    required this.due,
    required this.tags,
    required this.stage,
    required this.documents,
  });

  factory WorkflowItem.fromJson(Map<String, dynamic> json) {
    return WorkflowItem(
      id: _string(json['id']),
      title: _string(json['title'], 'Untitled item'),
      clientId: _string(json['clientId']),
      client: _string(json['client'], 'No client'),
      assignee: _string(json['assignee'], 'NA'),
      priority: _string(json['priority'], 'Medium'),
      due: _date(json['due']),
      tags: _stringList(json['tags']),
      stage: _string(json['stage'], 'Lead Capture'),
      documents:
          _mapList(json['documents']).map(WorkflowDocumentFile.fromJson).toList(),
    );
  }
}

class WorkflowDocumentFile {
  final String id;
  final String name;
  final String fileName;
  final String url;
  final String uploadedAt;

  const WorkflowDocumentFile({
    required this.id,
    required this.name,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
  });

  factory WorkflowDocumentFile.fromJson(Map<String, dynamic> json) {
    return WorkflowDocumentFile(
      id: _string(json['id']),
      name: _string(json['name'], _string(json['fileName'], 'document')),
      fileName: _string(json['fileName']),
      url: _string(json['url']),
      uploadedAt: _date(json['uploadedAt']),
    );
  }
}

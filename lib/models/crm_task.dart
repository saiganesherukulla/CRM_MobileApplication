part of 'models.dart';

class CrmTask {
  final String id;
  final String title;
  final String assignee;
  final String assigneeId;
  final String clientId;
  final String client;
  final String status;
  final String priority;
  final String due;
  final String? project;
  final String projectId;
  final int comments;
  final String description;
  final List<TaskComment> commentThread;

  const CrmTask({
    required this.id,
    required this.title,
    required this.assignee,
    required this.assigneeId,
    required this.clientId,
    required this.client,
    required this.status,
    required this.priority,
    required this.due,
    this.project,
    required this.projectId,
    required this.comments,
    required this.description,
    required this.commentThread,
  });

  factory CrmTask.fromJson(Map<String, dynamic> json) {
    final project = _string(json['project']);
    return CrmTask(
      id: _string(json['id']),
      title: _string(json['title'], 'Untitled task'),
      assignee: _string(json['assignee'], 'Unassigned'),
      assigneeId: _string(json['assigneeId']),
      clientId: _string(json['clientId']),
      client: _string(json['client'], 'No client'),
      status: _string(json['status'], 'New'),
      priority: _string(json['priority'], 'Medium'),
      due: _date(json['due']),
      project: project.isEmpty ? null : project,
      projectId: _string(json['projectId']),
      comments: _int(json['comments']),
      description: _string(json['description']),
      commentThread: _taskCommentList(json['commentThread']),
    );
  }
}

List<TaskComment> _taskCommentList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.map((key, val) => MapEntry(key.toString(), val)))
      .map(TaskComment.fromJson)
      .toList();
}

class TaskComment {
  final String id;
  final String message;
  final String author;
  final String authorId;
  final String createdAt;

  const TaskComment({
    required this.id,
    required this.message,
    required this.author,
    required this.authorId,
    required this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: _string(json['id']),
      message: _string(json['message']),
      author: _string(json['author'], 'CRM User'),
      authorId: _string(json['authorId']),
      createdAt: _date(json['createdAt']),
    );
  }
}

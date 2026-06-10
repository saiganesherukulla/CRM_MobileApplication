part of 'models.dart';

class Project {
  final String id;
  final String name;
  final String client;
  final String clientId;
  final String status;
  final int progress;
  final String startDate;
  final String dueDate;
  final String owner;
  final String ownerId;
  final String ownerEmail;
  final String ownerPhone;
  final String ownerDesignation;
  final List<String> team;
  final int milestones;
  final int completedMilestones;
  final List<ProjectMilestone> milestoneDetails;
  final String? budget;
  final String description;

  const Project({
    required this.id,
    required this.name,
    required this.client,
    required this.clientId,
    required this.status,
    required this.progress,
    required this.startDate,
    required this.dueDate,
    required this.owner,
    required this.ownerId,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.ownerDesignation,
    required this.team,
    required this.milestones,
    required this.completedMilestones,
    required this.milestoneDetails,
    this.budget,
    required this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: _string(json['id']),
      name: _string(json['name'], 'Untitled project'),
      client: _string(json['client'], 'No client'),
      clientId: _string(json['clientId']),
      status: _string(json['status'], 'Active'),
      progress: _int(json['progress']).clamp(0, 100).toInt(),
      startDate: _date(json['startDate']),
      dueDate: _date(json['dueDate']),
      owner: _string(json['owner'], 'Unassigned'),
      ownerId: _string(json['ownerId']),
      ownerEmail: _string(json['ownerEmail']),
      ownerPhone: _string(json['ownerPhone']),
      ownerDesignation: _string(json['ownerDesignation']),
      team: _stringList(json['team']),
      milestones: _int(json['milestones']),
      completedMilestones: _int(json['completedMilestones']),
      milestoneDetails: _mapList(
        json['milestoneDetails'],
      ).map(ProjectMilestone.fromJson).toList(),
      budget: _money(json['budget']),
      description: _string(json['description']),
    );
  }
}

class ProjectMilestone {
  final String id;
  final String name;
  final String status;
  final String owner;
  final String dueDate;
  final List<WorkflowDocumentFile> documents;

  const ProjectMilestone({
    required this.id,
    required this.name,
    required this.status,
    required this.owner,
    required this.dueDate,
    required this.documents,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: _string(json['id']),
      name: _string(json['name'], 'Delivery phase'),
      status: _string(json['status'], 'Pending'),
      owner: _string(json['owner'], 'Unassigned'),
      dueDate: _date(json['dueDate']),
      documents: _mapList(
        json['documents'],
      ).map(WorkflowDocumentFile.fromJson).toList(),
    );
  }
}

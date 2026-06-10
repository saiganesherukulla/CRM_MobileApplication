part of 'models.dart';

class Client {
  final String id;
  final String name;
  final String industry;
  final String owner;
  final String status;
  final int health;
  final String activity;
  final String avatar;
  final String revenue;
  final String country;
  final String website;
  final String notes;
  final String audience;
  final String clientTenantId;
  final String loginUserId;
  final bool subscriptionActive;

  const Client({
    required this.id,
    required this.name,
    required this.industry,
    required this.owner,
    required this.status,
    required this.health,
    required this.activity,
    required this.avatar,
    required this.revenue,
    required this.country,
    required this.website,
    required this.notes,
    required this.audience,
    required this.clientTenantId,
    required this.loginUserId,
    required this.subscriptionActive,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    final name = _string(json['name'], 'Unnamed client');
    return Client(
      id: _string(json['id']),
      name: name,
      industry: _string(json['industry'], 'Unspecified'),
      owner: _string(json['owner'], 'Unassigned'),
      status: _string(json['status'], 'Active'),
      health: _int(json['health'], 75).clamp(0, 100).toInt(),
      activity: _string(json['activity'], 'No recent activity'),
      avatar: _string(json['avatar'], _initials(name)),
      revenue: _money(json['revenue']),
      country: _string(json['country'], 'Unknown'),
      website: _string(json['website']),
      notes: _string(json['notes']),
      audience: _string(json['audience'], 'ADMIN'),
      clientTenantId: _string(json['clientTenantId']),
      loginUserId: _string(json['loginUserId']),
      subscriptionActive: json['subscriptionActive'] == true,
    );
  }
}

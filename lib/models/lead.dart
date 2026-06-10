part of 'models.dart';

class Lead {
  final String id;
  final String name;
  final String industry;
  final String country;
  final String website;
  final String owner;
  final String status;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String contactDesignation;
  final String source;

  final List<String> duplicateLeadIds;
  final String notes;
  final String convertedClientId;
  final String createdAt;
  final String updatedAt;

  const Lead({
    required this.id,
    required this.name,
    required this.industry,
    required this.country,
    required this.website,
    required this.owner,
    required this.status,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactDesignation,
    required this.source,

    required this.duplicateLeadIds,
    required this.notes,
    required this.convertedClientId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: _string(json['id']),
      name: _string(json['name'], 'Unnamed lead'),
      industry: _string(json['industry']),
      country: _string(json['country']),
      website: _string(json['website']),
      owner: _string(json['owner']),
      status: _string(json['status'], 'New'),
      contactName: _string(json['contactName']),
      contactEmail: _string(json['contactEmail']),
      contactPhone: _string(json['contactPhone']),
      contactDesignation: _string(json['contactDesignation']),
      source: _string(json['source']),

      duplicateLeadIds: _stringList(json['duplicateLeadIds']),
      notes: _string(json['notes']),
      convertedClientId: _string(json['convertedClientId']),
      createdAt: _string(json['createdAt']),
      updatedAt: _string(json['updatedAt']),
    );
  }
}

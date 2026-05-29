part of 'crm_api.dart';

class SettingsSummary {
  final List<TeamMember> users;
  final List<RoleInfo> roles;
  final List<DepartmentInfo> departments;
  final List<EmailAccountInfo> emailAccounts;
  final List<EmailProviderInfo> emailProviders;

  const SettingsSummary({
    required this.users,
    required this.roles,
    required this.departments,
    required this.emailAccounts,
    required this.emailProviders,
  });

  factory SettingsSummary.fromJson(Map<String, dynamic> json) {
    return SettingsSummary(
      users: _mapList(json['users']).map(TeamMember.fromJson).toList(),
      roles: _mapList(json['roles']).map(RoleInfo.fromJson).toList(),
      departments:
          _mapList(json['departments']).map(DepartmentInfo.fromJson).toList(),
      emailAccounts: _mapList(
        json['emailAccounts'],
      ).map(EmailAccountInfo.fromJson).toList(),
      emailProviders:
          _mapList(json['emailProviders']).map(EmailProviderInfo.fromJson).toList(),
    );
  }

  SettingsSummary copyWith({
    List<EmailAccountInfo>? emailAccounts,
    List<EmailProviderInfo>? emailProviders,
  }) {
    return SettingsSummary(
      users: users,
      roles: roles,
      departments: departments,
      emailAccounts: emailAccounts ?? this.emailAccounts,
      emailProviders: emailProviders ?? this.emailProviders,
    );
  }
}

part of 'models.dart';

class EmailProviderInfo {
  final String id;
  final String provider;
  final String displayName;
  final String clientId;
  final String redirectUri;
  final String dataCenter;
  final List<String> scopes;
  final bool enabled;

  const EmailProviderInfo({
    required this.id,
    required this.provider,
    required this.displayName,
    required this.clientId,
    required this.redirectUri,
    required this.dataCenter,
    required this.scopes,
    required this.enabled,
  });

  factory EmailProviderInfo.fromJson(Map<String, dynamic> json) {
    return EmailProviderInfo(
      id: _string(json['id']),
      provider: _string(json['provider']),
      displayName: _string(json['displayName'], _string(json['provider'])),
      clientId: _string(json['clientId']),
      redirectUri: _string(json['redirectUri']),
      dataCenter: _string(json['dataCenter']),
      scopes: _stringList(json['scopes']),
      enabled: json['enabled'] != false,
    );
  }
}

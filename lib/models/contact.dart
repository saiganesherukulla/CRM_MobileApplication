part of 'models.dart';

class Contact {
  final String id;
  final String clientId;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final bool primary;

  const Contact({
    required this.id,
    required this.clientId,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.primary,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: _string(json['id']),
      clientId: _string(json['clientId']),
      name: _string(json['name'], 'Unnamed contact'),
      email: _string(json['email']),
      phone: _string(json['phone']),
      designation: _string(json['designation'], 'Contact'),
      primary: json['primaryContact'] == true || json['primary'] == true,
    );
  }
}

part 'activity_item.dart';
part 'app_notification.dart';
part 'client.dart';
part 'contact.dart';
part 'crm_task.dart';
part 'department_info.dart';
part 'email_account_info.dart';
part 'email_provider_info.dart';
part 'email_sync_result.dart';
part 'email_message.dart';
part 'lead.dart';
part 'project.dart';
part 'role_info.dart';
part 'team_member.dart';
part 'ticket.dart';
part 'workflow_item.dart';

String _string(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

int _int(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? fallback;
}

String _date(dynamic value) {
  final raw = _string(value);
  if (raw.isEmpty) return 'Not set';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
}

String _money(dynamic value) {
  if (value == null) return 'INR 0';
  final number = value is num ? value : num.tryParse(value.toString());
  if (number == null) return value.toString();
  final sign = number < 0 ? '-' : '';
  final amount = number.abs();
  if (amount >= 10000000) {
    return '${sign}INR ${(amount / 10000000).toStringAsFixed(1)}Cr';
  }
  if (amount >= 100000) {
    return '${sign}INR ${(amount / 100000).toStringAsFixed(1)}L';
  }
  if (amount >= 1000) {
    return '${sign}INR ${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '${sign}INR ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) return [value];
  return const [];
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is List) {
    return value.map((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) {
        return item.map((key, entry) => MapEntry(key.toString(), entry));
      }
      return <String, dynamic>{};
    }).toList();
  }
  return const [];
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'NA';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

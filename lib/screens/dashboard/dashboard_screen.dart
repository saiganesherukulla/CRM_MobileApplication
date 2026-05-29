import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_avatar.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/stat_card.dart';

part 'dashboard_screen_state.dart';
part 'stats_grid.dart';
part 'email_activity_chart.dart';
part 'client_health_chart.dart';
part 'legend.dart';
part 'task_tile.dart';
part 'activity_tile.dart';
part 'metric_meta.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

_MetricMeta _metricMeta(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('client')) {
    return const _MetricMeta(
        Icons.people_rounded, AppColors.primaryLight, Color(0xFFE0F2FE));
  }
  if (lower.contains('project')) {
    return const _MetricMeta(
        Icons.folder_rounded, AppColors.success, Color(0xFFD1FAE5));
  }
  if (lower.contains('task')) {
    return const _MetricMeta(
        Icons.check_box_rounded, AppColors.warning, Color(0xFFFEF3C7));
  }
  if (lower.contains('ticket')) {
    return const _MetricMeta(
        Icons.confirmation_number_rounded, AppColors.error, Color(0xFFFEE2E2));
  }
  return const _MetricMeta(
      Icons.analytics_rounded, AppColors.info, Color(0xFFDBEAFE));
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

int _number(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _valueFor(List<Map<String, dynamic>> rows, String name) {
  for (final row in rows) {
    if (row['name']?.toString() == name) return _number(row['value']);
  }
  return 0;
}

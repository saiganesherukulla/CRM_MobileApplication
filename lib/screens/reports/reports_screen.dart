import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/layout/app_shell.dart';

part 'reports_screen_state.dart';
part 'overview_tab.dart';
part 'email_analytics_tab.dart';
part 'workload_tab.dart';
part 'projects_tab.dart';
part 'tickets_tab.dart';
part 'chart_card.dart';
part 'table_card.dart';
part 'kpi_card.dart';
part 'small_stat.dart';
part 'legend.dart';
part 'legend_item.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
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

String _short(String value, int length) {
  if (value.length <= length) return value;
  return '${value.substring(0, length)}...';
}

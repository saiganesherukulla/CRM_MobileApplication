import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_avatar.dart';
import '../../widgets/layout/app_shell.dart';

part 'workflows_screen_state.dart';
part 'client_flow_screen.dart';
part 'client_flow_screen_state.dart';
part 'flow_intro.dart';
part 'project_flow_card.dart';
part 'flow_header.dart';
part 'timeline_stage.dart';
part 'workflow_card.dart';
part 'workflow_editor_sheet.dart';
part 'workflow_editor_sheet_state.dart';
part 'create_workflow_sheet.dart';
part 'create_workflow_sheet_state.dart';
part 'mini_pill.dart';
part 'tag.dart';
part 'workflow_data.dart';
part 'flow_record.dart';

List<String> get workflowStages => CrmApi.workflowStages;

const _stageHeaderPalette = [
  AppColors.primary,
  AppColors.info,
  AppColors.warning,
  Color(0xFF8B5CF6),
  Color(0xFFF97316),
  AppColors.success,
  Color(0xFF0F766E),
  Color(0xFFDC2626),
];

const _stageSurfacePalette = [
  Color(0xFFEFF6FF),
  Color(0xFFE0F2FE),
  Color(0xFFFFFBEB),
  Color(0xFFF5F3FF),
  Color(0xFFFFF7ED),
  Color(0xFFECFDF5),
  Color(0xFFF0FDFA),
  Color(0xFFFEF2F2),
];

Color _stageHeaderColor(String stage) {
  final index = workflowStages.indexOf(stage);
  if (index < 0) return AppColors.slate500;
  return _stageHeaderPalette[index % _stageHeaderPalette.length];
}

Color _stageSurfaceColor(String stage) {
  final index = workflowStages.indexOf(stage);
  if (index < 0) return AppColors.slate50;
  return _stageSurfacePalette[index % _stageSurfacePalette.length];
}

class WorkflowsScreen extends StatefulWidget {
  const WorkflowsScreen({super.key});

  @override
  State<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

int _progressFor(List<WorkflowItem> items) {
  if (items.isEmpty || workflowStages.isEmpty) return 0;
  var max = 0;
  for (final item in items) {
    final index = workflowStages.indexOf(item.stage);
    if (index > max) max = index;
  }
  return (((max + 1) / workflowStages.length) * 100).round();
}

String _latestDue(List<WorkflowItem> items) {
  if (items.isEmpty) return 'Not set';
  return items.last.due;
}

List<WorkflowItem> _uniqueFlowItems(Iterable<WorkflowItem> items) {
  final seen = <String>{};
  final output = <WorkflowItem>[];
  for (final item in items) {
    final key =
        '${item.client.toLowerCase()}|${item.stage.toLowerCase()}|${item.title.toLowerCase()}';
    if (seen.add(key)) {
      output.add(item);
    }
  }
  return output;
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

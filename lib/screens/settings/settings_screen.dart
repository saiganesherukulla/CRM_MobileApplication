import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_avatar.dart';
import '../../widgets/layout/app_shell.dart';

part 'settings_screen_state.dart';
part 'profile_section.dart';
part 'users_section.dart';
part 'roles_section.dart';
part 'departments_section.dart';
part 'email_config_section.dart';
part 'email_config_section_state.dart';
part 'email_account_card.dart';
part 'notifications_section.dart';
part 'notifications_section_state.dart';
part 'security_section.dart';
part 'security_section_state.dart';
part 'system_section.dart';
part 'audit_logs_section.dart';
part 'form_card.dart';
part 'toggle_tile.dart';
part 'chip.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

void _showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

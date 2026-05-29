part of 'settings_screen.dart';

class _NotificationsSectionState extends State<_NotificationsSection> {
  final Map<String, bool> _toggles = {
    'New ticket assigned': true,
    'Ticket status updated': true,
    'Task due reminder': true,
    'New email received': false,
    'Client health change': true,
    'Project milestone reached': true,
    'Team member mention': false,
    'Daily digest': true,
  };

  Future<void> _saveToggle(String key, bool value) async {
    setState(() => _toggles[key] = value);
    try {
      await CrmApi.instance.savePreference(
        'notifications.${key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
        {'enabled': value},
      );
    } catch (error) {
      if (mounted) _showInfo(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Notification Preferences',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Column(
              children: _toggles.entries
                  .map((entry) => _ToggleTile(
                      title: entry.key,
                      value: entry.value,
                      onChanged: (value) => _saveToggle(entry.key, value),
                      inCard: true))
                  .toList()),
        ),
      ],
    );
  }
}

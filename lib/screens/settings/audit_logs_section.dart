part of 'settings_screen.dart';

class _AuditLogsSection extends StatefulWidget {
  const _AuditLogsSection();

  @override
  State<_AuditLogsSection> createState() => _AuditLogsSectionState();
}

class _AuditLogsSectionState extends State<_AuditLogsSection> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.auditLogs();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.auditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ApiLoading();
        }
        if (snapshot.hasError) {
          return ApiErrorView(error: snapshot.error, onRetry: _reload);
        }
        final logs = snapshot.data ?? const <Map<String, dynamic>>[];
        if (logs.isEmpty) return const ApiEmpty('No audit logs recorded yet.');
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              final module = _auditText(log['module'], 'system');
              final action = _auditText(log['action'], 'Updated');
              final target = _auditText(log['target'], '-');
              final actor = _auditText(log['actorEmail'], 'System');
              final time = _auditText(log['timestamp'] ?? log['createdAt'], '');
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(action,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text('$module / $target',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.slate500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text('$actor $time',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

String _auditText(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

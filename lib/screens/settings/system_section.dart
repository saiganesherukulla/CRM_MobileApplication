part of 'settings_screen.dart';

class _SystemSection extends StatefulWidget {
  const _SystemSection();

  @override
  State<_SystemSection> createState() => _SystemSectionState();
}

class _SystemSectionState extends State<_SystemSection> {
  late Future<({Map<String, dynamic> health, Map<String, dynamic> profile})>
      _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({Map<String, dynamic> health, Map<String, dynamic> profile})>
      _load() async {
    final health = await CrmApi.instance.health();
    final profile = await CrmApi.instance.profileSettings();
    return (health: health, profile: profile);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({Map<String, dynamic> health, Map<String, dynamic> profile})>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ApiLoading();
        }
        if (snapshot.hasError) {
          return ApiErrorView(error: snapshot.error, onRetry: _reload);
        }
        final data = snapshot.data ??
            (health: const <String, dynamic>{}, profile: const <String, dynamic>{});
        final rows = {
          ...data.health.map((key, value) => MapEntry('Health $key', value)),
          ...data.profile,
        };
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('System Status',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
              const SizedBox(height: 14),
              ...rows.entries.map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder)),
                    child: Row(
                      children: [
                        const Icon(Icons.dns_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(entry.key,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate700)),
                        ),
                        Flexible(
                          child: Text('${entry.value}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.slate500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

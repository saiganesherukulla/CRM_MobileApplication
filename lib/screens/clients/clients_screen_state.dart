part of 'clients_screen.dart';

class _ClientsScreenState extends State<ClientsScreen> {
  String _search = '';
  String _statusFilter = 'All';
  String _industryFilter = 'All';
  String _countryFilter = 'All';
  bool _showMoreFilters = false;
  String? _handledLeadId;
  final _searchCtrl = TextEditingController();
  late Future<List<Client>> _future;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.clients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final leadId = GoRouterState.of(context).uri.queryParameters['leadId'];
    if (leadId == null || leadId.isEmpty || leadId == _handledLeadId) return;
    _handledLeadId = leadId;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _openLeadConversion(leadId));
  }

  Future<void> _openLeadConversion(String leadId) async {
    try {
      final lead = await CrmApi.instance.lead(leadId);
      if (!mounted) return;
      await _showAddClientSheet(lead);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) context.go('/clients');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.clients();
    });
  }

  List<Client> _filtered(List<Client> clients) {
    return clients.where((client) {
      final matchStatus =
          _statusFilter == 'All' || client.status == _statusFilter;
      final matchIndustry =
          _industryFilter == 'All' || client.industry == _industryFilter;
      final matchCountry =
          _countryFilter == 'All' || client.country == _countryFilter;
      final query = _search.toLowerCase();
      final matchSearch = client.name.toLowerCase().contains(query) ||
          client.industry.toLowerCase().contains(query) ||
          client.owner.toLowerCase().contains(query);
      return matchStatus && matchIndustry && matchCountry && matchSearch;
    }).toList();
  }

  List<String> _options(List<Client> clients, String Function(Client) picker) {
    final values = clients
        .map(picker)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Clients',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed:
                CrmApi.instance.canCreateClients ? _showAddClientSheet : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search clients...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'New', 'Active', 'At Risk', 'Inactive']
                        .map((status) {
                      final selected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _statusFilter = status),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showMoreFilters = !_showMoreFilters),
                    icon: const Icon(Icons.filter_list_rounded, size: 18),
                    label: Text(
                      _showMoreFilters ? 'Hide Filters' : 'More Filters',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final allClients = snapshot.data ?? const [];
                final industryOptions = _options(
                  allClients,
                  (client) => client.industry,
                );
                final countryOptions = _options(
                  allClients,
                  (client) => client.country,
                );
                if (!industryOptions.contains(_industryFilter)) {
                  _industryFilter = 'All';
                }
                if (!countryOptions.contains(_countryFilter)) {
                  _countryFilter = 'All';
                }
                final clients = _filtered(allClients);
                if (clients.isEmpty) {
                  return Column(
                    children: [
                      if (_showMoreFilters)
                        _ClientMoreFilters(
                          industry: _industryFilter,
                          country: _countryFilter,
                          industries: industryOptions,
                          countries: countryOptions,
                          onIndustryChanged: (value) =>
                              setState(() => _industryFilter = value ?? 'All'),
                          onCountryChanged: (value) =>
                              setState(() => _countryFilter = value ?? 'All'),
                          onClear: () => setState(() {
                            _search = '';
                            _searchCtrl.clear();
                            _statusFilter = 'All';
                            _industryFilter = 'All';
                            _countryFilter = 'All';
                          }),
                        ),
                      const Expanded(
                        child: ApiEmpty(
                          'No clients found. Add your first client to begin.',
                        ),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _reload(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_showMoreFilters) ...[
                        _ClientMoreFilters(
                          industry: _industryFilter,
                          country: _countryFilter,
                          industries: industryOptions,
                          countries: countryOptions,
                          onIndustryChanged: (value) =>
                              setState(() => _industryFilter = value ?? 'All'),
                          onCountryChanged: (value) =>
                              setState(() => _countryFilter = value ?? 'All'),
                          onClear: () => setState(() {
                            _search = '';
                            _searchCtrl.clear();
                            _statusFilter = 'All';
                            _industryFilter = 'All';
                            _countryFilter = 'All';
                          }),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ...clients.map(
                        (client) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ClientCard(client: client),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddClientSheet([Lead? lead]) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddClientSheet(lead: lead),
    );
    if (created == true) _reload();
  }
}

class _ClientMoreFilters extends StatelessWidget {
  final String industry;
  final String country;
  final List<String> industries;
  final List<String> countries;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onCountryChanged;
  final VoidCallback onClear;

  const _ClientMoreFilters({
    required this.industry,
    required this.country,
    required this.industries,
    required this.countries,
    required this.onIndustryChanged,
    required this.onCountryChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: industry,
            items: industries
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onIndustryChanged,
            decoration: const InputDecoration(labelText: 'Industry'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: country,
            items: countries
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onCountryChanged,
            decoration: const InputDecoration(labelText: 'Country'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClear,
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

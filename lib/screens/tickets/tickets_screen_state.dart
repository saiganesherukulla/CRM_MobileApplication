part of 'tickets_screen.dart';

class _TicketsScreenState extends State<TicketsScreen> {
  String _search = '';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  late Future<List<Ticket>> _future;

  static const _statusOverview = [
    _StatusMeta('Open', Icons.inbox_rounded, AppColors.info),
    _StatusMeta('In Progress', Icons.pending_rounded, AppColors.warning),
    _StatusMeta('Waiting', Icons.hourglass_empty_rounded, AppColors.slate400),
    _StatusMeta('Resolved', Icons.check_circle_rounded, AppColors.success),
  ];

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.tickets();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.tickets();
    });
  }

  List<Ticket> _filtered(List<Ticket> tickets) {
    return tickets.where((ticket) {
      final matchStatus =
          _statusFilter == 'All' || ticket.status == _statusFilter;
      final matchPriority =
          _priorityFilter == 'All' || ticket.priority == _priorityFilter;
      final query = _search.toLowerCase();
      final matchSearch = ticket.title.toLowerCase().contains(query) ||
          ticket.client.toLowerCase().contains(query);
      return matchStatus && matchPriority && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Tickets',
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: _showNewTicketSheet),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final allTickets = snapshot.data ?? const <Ticket>[];
          final tickets = _filtered(allTickets);
          return Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: _statusOverview.map((status) {
                    final count = allTickets
                        .where((ticket) => ticket.status == status.label)
                        .length;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: status.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: status.color.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(status.icon, size: 16, color: status.color),
                            const SizedBox(height: 4),
                            Text('$count',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: status.color)),
                            const SizedBox(height: 2),
                            Text(status.label,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.slate500,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        hintText: 'Search tickets...',
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18, color: AppColors.slate400),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FilterRow(
                      label: 'Status',
                      values: const [
                        'All',
                        'Open',
                        'In Progress',
                        'Waiting',
                        'Resolved'
                      ],
                      selected: _statusFilter,
                      onChanged: (value) =>
                          setState(() => _statusFilter = value),
                    ),
                    const SizedBox(height: 6),
                    _FilterRow(
                      label: 'Priority',
                      values: const [
                        'All',
                        'Critical',
                        'High',
                        'Medium',
                        'Low'
                      ],
                      selected: _priorityFilter,
                      dark: true,
                      onChanged: (value) =>
                          setState(() => _priorityFilter = value),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: tickets.isEmpty
                    ? const ApiEmpty('No tickets found.')
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => _reload(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: tickets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) => _TicketCard(
                              ticket: tickets[index],
                              onTap: () => _showTicketDetail(tickets[index])),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showTicketDetail(Ticket ticket) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TicketDetailSheet(ticket: ticket),
    );
    if (changed == true) _reload();
  }

  Future<void> _showNewTicketSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewTicketSheet(),
    );
    if (created == true) _reload();
  }
}

part of 'tickets_screen.dart';

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  late Ticket _ticket;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _notesCtrl;
  late String _priority;
  bool _saving = false;
  String? _error;

  Color get _slaColor {
    if (_ticket.sla == 'Breached') return AppColors.error;
    if (_ticket.sla == 'At Risk') return AppColors.warning;
    return AppColors.success;
  }

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _titleCtrl = TextEditingController(text: _ticket.title);
    _categoryCtrl = TextEditingController(text: _ticket.category);
    _notesCtrl = TextEditingController(text: _ticket.resolutionNotes);
    _priority = _ticket.priority;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(String status) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.updateTicketStatus(_ticket.id, status);
      if (mounted) setState(() => _ticket = updated);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveDetails() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ticket title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.updateTicket(_ticket.id, {
        'title': _titleCtrl.text.trim(),
        'priority': _priority,
        'status': _ticket.status,
        'client': _ticket.client,
        'clientId': _ticket.clientId,
        'assignee': _ticket.assignee,
        'assigneeId': _ticket.assigneeId,
        'sla': _ticket.sla,
        'category': _categoryCtrl.text.trim(),
        'resolutionNotes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        setState(() => _ticket = updated);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ticket saved.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteTicket() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ticket?'),
        content: Text(_ticket.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await CrmApi.instance.deleteTicket(_ticket.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _ticket;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(children: [
                    Text(ticket.ticketNumber,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                            fontFamily: 'monospace')),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _slaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: _slaColor.withOpacity(0.3))),
                      child: Text('SLA: ${ticket.sla}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _slaColor)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(ticket.title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    CrmBadge(ticket.status),
                    CrmBadge(ticket.priority)
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _Detail('Client', ticket.client),
                    const SizedBox(width: 10),
                    _Detail('Assignee', ticket.assignee)
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _Detail('Created', ticket.created),
                    const SizedBox(width: 10),
                    _Detail('Category', ticket.category)
                  ]),
                  const SizedBox(height: 20),
                  const Text('Update Status',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Open', 'In Progress', 'Waiting for Client', 'Resolved']
                        .map((status) {
                      final selected = ticket.status == status;
                      return GestureDetector(
                        onTap: _saving ? null : () => _changeStatus(status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(999)),
                          child: Text(status,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.slate600)),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_saving) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(color: AppColors.primary),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  const Text('Edit Ticket',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _titleCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Ticket Title')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ['Critical', 'High', 'Medium', 'Low']
                                .contains(_priority)
                            ? _priority
                            : 'Medium',
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: ['Critical', 'High', 'Medium', 'Low']
                            .map((item) => DropdownMenuItem(
                                value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _priority = value ?? _priority),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: _categoryCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Category'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration:
                        const InputDecoration(labelText: 'Resolution Notes'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _deleteTicket,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveDetails,
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Save'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

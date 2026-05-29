part of 'tickets_screen.dart';

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final _titleCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: 'Medium');
  final _categoryCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priorityCtrl.dispose();
    _categoryCtrl.dispose();
    _clientCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ticket title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.createTicket({
        'title': _titleCtrl.text.trim(),
        'priority': _priorityCtrl.text.trim().isEmpty
            ? 'Medium'
            : _priorityCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'client': _clientCtrl.text.trim(),
        'assignee': _assigneeCtrl.text.trim(),
        'status': 'Open',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Create New Ticket',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Ticket Title',
                          hintText: 'Describe the issue...')),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: _priorityCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Priority'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: _categoryCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Category'))),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: _clientCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Client'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: _assigneeCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Assign To'))),
                  ]),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Ticket'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

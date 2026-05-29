part of 'projects_screen.dart';

class _NewProjectSheetState extends State<_NewProjectSheet> {
  final _nameCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _dueCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _statusCtrl = TextEditingController(text: 'Active');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _startCtrl.dispose();
    _dueCtrl.dispose();
    _budgetCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Project name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final canViewFinancials = CrmApi.instance.canViewFinancials();
      await CrmApi.instance.createProject({
        'name': _nameCtrl.text.trim(),
        'client': _clientCtrl.text.trim(),
        'startDate': _startCtrl.text.trim(),
        'dueDate': _dueCtrl.text.trim(),
        if (canViewFinancials)
          'budget': num.tryParse(
                  _budgetCtrl.text.replaceAll(',', '').replaceAll('\$', '')) ??
              0,
        'status': _statusCtrl.text.trim().isEmpty
            ? 'Active'
            : _statusCtrl.text.trim(),
        'progress': 0,
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
    final canViewFinancials = CrmApi.instance.canViewFinancials();
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
              child: Text('New Project',
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
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Project Name',
                          hintText: 'e.g. Website Redesign')),
                  const SizedBox(height: 14),
                  TextField(
                      controller: _clientCtrl,
                      decoration: const InputDecoration(labelText: 'Client')),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: _startCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Start Date'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: _dueCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Due Date'))),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    if (canViewFinancials) ...[
                      Expanded(
                          child: TextField(
                              controller: _budgetCtrl,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Budget'))),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                        child: TextField(
                            controller: _statusCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Status'))),
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
                        : const Text('Create Project'),
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

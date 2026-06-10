part of 'projects_screen.dart';

class _NewProjectSheetState extends State<_NewProjectSheet> {
  final _nameCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _dueCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _ownerEmailCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _ownerDesignationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _statusCtrl = TextEditingController(text: 'Active');
  late Future<List<Client>> _clientsFuture;
  String? _clientId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientsFuture = CrmApi.instance.clients();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startCtrl.dispose();
    _dueCtrl.dispose();
    _budgetCtrl.dispose();
    _ownerCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _ownerDesignationCtrl.dispose();
    _descriptionCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _clientId == null ||
        _ownerCtrl.text.trim().isEmpty ||
        _ownerEmailCtrl.text.trim().isEmpty ||
        _ownerPhoneCtrl.text.trim().isEmpty ||
        _ownerDesignationCtrl.text.trim().isEmpty ||
        _startCtrl.text.trim().isEmpty ||
        _dueCtrl.text.trim().isEmpty) {
      setState(
        () => _error =
            'Project name, client, owner details, start date, and due date are required.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final canViewFinancials = CrmApi.instance.canViewFinancials();
      final clients = await _clientsFuture;
      final selectedClient = clients.firstWhere(
        (client) => client.id == _clientId,
      );
      await CrmApi.instance.createProject({
        'name': _nameCtrl.text.trim(),
        'client': selectedClient.name,
        'clientId': selectedClient.id,
        'startDate': _startCtrl.text.trim(),
        'dueDate': _dueCtrl.text.trim(),
        'owner': _ownerCtrl.text.trim(),
        'ownerEmail': _ownerEmailCtrl.text.trim(),
        'ownerPhone': _ownerPhoneCtrl.text.trim(),
        'ownerDesignation': _ownerDesignationCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        if (canViewFinancials)
          'budget':
              num.tryParse(
                _budgetCtrl.text.replaceAll(',', '').replaceAll('\$', ''),
              ) ??
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'New Project',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
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
                      hintText: 'e.g. Website Redesign',
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<Client>>(
                    future: _clientsFuture,
                    builder: (context, snapshot) {
                      final clients = snapshot.data ?? const [];
                      if (_clientId != null &&
                          clients.every((client) => client.id != _clientId)) {
                        _clientId = null;
                      }
                      return DropdownButtonFormField<String>(
                        value: _clientId,
                        decoration: const InputDecoration(labelText: 'Client'),
                        items: clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client.id,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged:
                            snapshot.connectionState == ConnectionState.waiting
                            ? null
                            : (value) => setState(() => _clientId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _ownerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Project Owner',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ownerEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Owner Email',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _ownerPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Owner Phone',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _ownerDesignationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Owner Designation',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _dueCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (canViewFinancials) ...[
                        Expanded(
                          child: TextField(
                            controller: _budgetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Budget',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _statusCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
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

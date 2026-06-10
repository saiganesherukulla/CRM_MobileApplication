part of 'workflows_screen.dart';

class _CreateWorkflowSheetState extends State<_CreateWorkflowSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _clientCtrl;
  final _assigneeCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: 'Medium');
  final _dueCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  late Future<List<Client>> _clientsFuture;
  late String _stage;
  String? _selectedClientId;
  List<PlatformFile> _documents = const [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _clientCtrl = TextEditingController(text: widget.initialClientName ?? '');
    _stage = widget.initialStage ?? workflowStages.first;
    _clientsFuture = CrmApi.instance.clients();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _clientCtrl.dispose();
    _assigneeCtrl.dispose();
    _priorityCtrl.dispose();
    _dueCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var clientName = _clientCtrl.text.trim();
      var clientId = _selectedClientId;
      if (clientId == null && clientName.isNotEmpty) {
        final savedClients = await _clientsFuture;
        final existingClient = savedClients.where((client) {
          return client.name.toLowerCase() == clientName.toLowerCase();
        }).firstOrNull;
        if (existingClient != null) {
          clientId = existingClient.id;
          clientName = existingClient.name;
        } else {
          try {
            final client = await CrmApi.instance.createClient({
              'name': clientName,
              'industry': 'New Lead',
              'country': 'India',
              'owner': _assigneeCtrl.text.trim(),
            });
            clientId = client.id;
            clientName = client.name;
          } catch (_) {
            // CRM flow can still record a lead name before the full client profile is created.
          }
        }
      }
      final created = await CrmApi.instance.createWorkflow({
        'title': _titleCtrl.text.trim(),
        'client': clientName,
        'clientId': clientId,
        'assignee': _assigneeCtrl.text.trim(),
        'priority': _priorityCtrl.text.trim().isEmpty
            ? 'Medium'
            : _priorityCtrl.text.trim(),
        'due': _dueCtrl.text.trim(),
        'stage': _stage,
        'tags': _tagsCtrl.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      });
      for (final document in _documents) {
        await CrmApi.instance.uploadWorkflowDocument(created.id, document);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'png',
        'jpg',
        'jpeg',
        'xlsx',
        'xls',
        'csv',
      ],
      withData: true,
    );
    if (result == null || !mounted) return;
    setState(() => _documents = result.files);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('New Flow Item',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate800)),
            const SizedBox(height: 16),
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            FutureBuilder<List<Client>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                final clients = snapshot.data ?? const <Client>[];
                return DropdownButtonFormField<String>(
                  value: clients.any((client) => client.id == _selectedClientId)
                      ? _selectedClientId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Client'),
                  hint: const Text('Select saved client'),
                  items: clients
                      .map((client) => DropdownMenuItem(
                            value: client.id,
                            child: Text(client.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (id) {
                    Client? selected;
                    for (final client in clients) {
                      if (client.id == id) {
                        selected = client;
                        break;
                      }
                    }
                    setState(() {
                      _selectedClientId = selected?.id;
                      _clientCtrl.text = selected?.name ?? '';
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _clientCtrl,
                onChanged: (_) => setState(() => _selectedClientId = null),
                decoration: const InputDecoration(
                    labelText: 'Client name',
                    hintText: 'Type a new client name if not saved yet')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _assigneeCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Assignee'))),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                      controller: _priorityCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Priority'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _dueCtrl,
                      decoration: const InputDecoration(labelText: 'Due'))),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _stage,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  items: workflowStages
                      .map((stage) => DropdownMenuItem(
                          value: stage,
                          child: Text(stage,
                              maxLines: 1, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _stage = value ?? _stage),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tags', hintText: 'Comma separated')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDocuments,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(_documents.isEmpty
                  ? 'Upload stage documents'
                  : '${_documents.length} document(s) selected'),
            ),
            if (_documents.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._documents.map((document) => Text(
                    document.name,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Item'),
            ),
          ],
        ),
      ),
    );
  }
}

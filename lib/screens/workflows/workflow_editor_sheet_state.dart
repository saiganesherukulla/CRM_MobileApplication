part of 'workflows_screen.dart';

class _WorkflowEditorSheetState extends State<_WorkflowEditorSheet> {
  late WorkflowItem _item;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _assigneeCtrl;
  late final TextEditingController _priorityCtrl;
  late final TextEditingController _dueCtrl;
  late final TextEditingController _tagsCtrl;
  final _docNameCtrl = TextEditingController();
  final _docUrlCtrl = TextEditingController();
  late String _stage;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    final item = _item;
    _titleCtrl = TextEditingController(text: item.title);
    _clientCtrl = TextEditingController(text: item.client);
    _assigneeCtrl = TextEditingController(text: item.assignee);
    _priorityCtrl = TextEditingController(text: item.priority);
    _dueCtrl = TextEditingController(text: item.due);
    _tagsCtrl = TextEditingController(text: item.tags.join(', '));
    _stage = item.stage;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _clientCtrl.dispose();
    _assigneeCtrl.dispose();
    _priorityCtrl.dispose();
    _dueCtrl.dispose();
    _tagsCtrl.dispose();
    _docNameCtrl.dispose();
    _docUrlCtrl.dispose();
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
      final updated = await CrmApi.instance.updateWorkflow(_item.id, {
        'title': _titleCtrl.text.trim(),
        'client': _clientCtrl.text.trim(),
        'assignee': _assigneeCtrl.text.trim(),
        'priority': _priorityCtrl.text.trim(),
        'due': _dueCtrl.text.trim(),
        'stage': _stage,
        'tags': _tagsCtrl.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      });
      if (mounted) {
        setState(() => _item = updated);
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete flow item?'),
        content: Text(_item.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await CrmApi.instance.deleteWorkflow(_item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addDocument() async {
    if (_docNameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Document name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.addWorkflowDocument(_item.id, {
        'name': _docNameCtrl.text.trim(),
        'fileName': _docNameCtrl.text.trim(),
        'url': _docUrlCtrl.text.trim(),
      });
      if (mounted) {
        setState(() {
          _item = updated;
          _docNameCtrl.clear();
          _docUrlCtrl.clear();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    setState(() => _saving = true);
    try {
      final updated =
          await CrmApi.instance.deleteWorkflowDocument(_item.id, documentId);
      if (mounted) setState(() => _item = updated);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copyDocumentLink(WorkflowDocumentFile document) async {
    final directUrl = document.url.trim();
    final link = directUrl.isNotEmpty
        ? directUrl
        : CrmApi.instance.workflowDocumentDownloadUrl(_item.id, document.id);
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Edit Flow Item',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate800)),
            const SizedBox(height: 16),
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(
                controller: _clientCtrl,
                decoration: const InputDecoration(labelText: 'Client')),
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
            const SizedBox(height: 18),
            const Text('Documents',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 8),
            if (_item.documents.isEmpty)
              const Text('No documents added for this stage yet.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400))
            else
              ..._item.documents.map((document) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            size: 16, color: AppColors.slate500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(document.name,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.slate700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined,
                              size: 18, color: AppColors.primary),
                          onPressed: _saving
                              ? null
                              : () => _copyDocumentLink(document),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.error),
                          onPressed: _saving
                              ? null
                              : () => _deleteDocument(document.id),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 8),
            TextField(
                controller: _docNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Document Name')),
            const SizedBox(height: 10),
            TextField(
                controller: _docUrlCtrl,
                decoration:
                    const InputDecoration(labelText: 'Document URL')),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _saving ? null : _addDocument,
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Add Document'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _deleteItem,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

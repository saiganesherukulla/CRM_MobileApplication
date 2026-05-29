part of 'tasks_screen.dart';

class _NewTaskSheetState extends State<_NewTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: 'Medium');
  final _dueCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priorityCtrl.dispose();
    _dueCtrl.dispose();
    _assigneeCtrl.dispose();
    _clientCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Task title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.createTask({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'priority': _priorityCtrl.text.trim().isEmpty
            ? 'Medium'
            : _priorityCtrl.text.trim(),
        'due': _dueCtrl.text.trim(),
        'assignee': _assigneeCtrl.text.trim(),
        'client': _clientCtrl.text.trim(),
        'status': 'New',
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
    Future<void> pickDueDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null) {
        _dueCtrl.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
              child: Text('Create New Task',
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
                          labelText: 'Task Title',
                          hintText: 'Short task title...')),
                  const SizedBox(height: 14),
                  TextField(
                      controller: _descriptionCtrl,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(
                          labelText: 'Task Description',
                          hintText:
                              'Explain the expected work, context, acceptance criteria, and client notes...')),
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
                            controller: _dueCtrl,
                            readOnly: true,
                            onTap: pickDueDate,
                            decoration:
                                const InputDecoration(
                                    labelText: 'Due Date',
                                    suffixIcon:
                                        Icon(Icons.calendar_today_rounded)))),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: _assigneeCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Assign To'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: _clientCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Client'))),
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
                        : const Text('Create Task'),
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

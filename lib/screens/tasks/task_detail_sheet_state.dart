part of 'tasks_screen.dart';

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late CrmTask _task;
  final _commentCtrl = TextEditingController();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _assigneeCtrl;
  late final TextEditingController _dueCtrl;
  late String _priority;
  bool _saving = false;
  bool _commentSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _titleCtrl = TextEditingController(text: _task.title);
    _descriptionCtrl = TextEditingController(text: _task.description);
    _assigneeCtrl = TextEditingController(text: _task.assignee);
    _dueCtrl = TextEditingController(text: _task.due == 'Not set' ? '' : _task.due);
    _priority = _task.priority;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _assigneeCtrl.dispose();
    _dueCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(String status) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.updateTaskStatus(_task.id, status);
      if (mounted) {
        setState(() => _task = updated);
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _postComment() async {
    final message = _commentCtrl.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _commentSaving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.addTaskComment(_task.id, message);
      if (mounted) {
        setState(() {
          _task = updated;
          _commentCtrl.clear();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _commentSaving = false);
    }
  }

  Future<void> _saveDetails() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Task title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await CrmApi.instance.updateTask(_task.id, {
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'assignee': _assigneeCtrl.text.trim(),
        'client': _task.client,
        'clientId': _task.clientId,
        'project': _task.project,
        'projectId': _task.projectId,
        'priority': _priority,
        'due': _dueCtrl.text.trim(),
        'status': _task.status,
      });
      if (mounted) {
        setState(() => _task = updated);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task saved.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(_task.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await CrmApi.instance.deleteTask(_task.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
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
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    CrmBadge(task.status),
                    CrmBadge(task.priority)
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _Detail('Client', task.client),
                    const SizedBox(width: 10),
                    _Detail('Due Date', task.due)
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _Detail('Assignee', task.assignee),
                    const SizedBox(width: 10),
                    _Detail('Project', task.project ?? 'None')
                  ]),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder)),
                      child: Text(task.description,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.slate600)),
                    ),
                  ],
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
                    children: [
                      'New',
                      'In Progress',
                      'Review',
                      'Waiting for Client',
                      'Done'
                    ].map((status) {
                      final selected = task.status == status;
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
                  const Text('Edit Task',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _titleCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Task Title')),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration:
                        const InputDecoration(labelText: 'Task Description'),
                  ),
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
                            controller: _dueCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Due Date'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _assigneeCtrl,
                      decoration: const InputDecoration(labelText: 'Assignee')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _deleteTask,
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
                  const SizedBox(height: 20),
                  Text('Comments (${task.comments})',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700)),
                  const SizedBox(height: 10),
                  if (task.commentThread.isEmpty)
                    const Text('No comments yet.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.slate400))
                  else
                    ...task.commentThread.map((comment) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.surfaceBorder)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(comment.author,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.slate700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(comment.createdAt,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.slate400)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.message,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: AppColors.slate600)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(hintText: 'Write a comment...'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _commentSaving ? null : _postComment,
                    icon: _commentSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 16),
                    label:
                        Text(_commentSaving ? 'Posting...' : 'Post Comment'),
                  ),
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

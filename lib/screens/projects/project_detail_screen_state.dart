part of 'projects_screen.dart';

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Overview', 'Tasks', 'Team', 'Updates'];
  static const _standardPhases = [
    'Requirements',
    'UI/UX Design',
    'Development',
    'Testing',
    'Deployment',
    'Handover',
  ];

  late TabController _tabCtrl;
  late Future<ProjectSummary> _future;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _future = CrmApi.instance.projectSummary(widget.projectId);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.projectSummary(widget.projectId);
    });
  }

  Future<void> _showEditProjectSheet(Project project) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProjectSheet(project: project),
    );
    if (changed == true) _reload();
  }

  Future<void> _showAddPhaseSheet(Project project) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ProjectPhaseSheet(project: project, phases: _standardPhases),
    );
    if (changed == true) _reload();
  }

  Future<void> _showAddTeamSheet(Project project) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectTeamSheet(project: project),
    );
    if (changed == true) _reload();
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(project.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await CrmApi.instance.deleteProject(project.id);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _updatePhaseStatus(
    Project project,
    ProjectMilestone phase,
    String status,
  ) async {
    await CrmApi.instance.updateProjectMilestone(project.id, phase.id, {
      'name': phase.name,
      'owner': phase.owner,
      'dueDate': phase.dueDate == 'Not set' ? null : phase.dueDate,
      'status': status,
    });
    _reload();
  }

  Future<void> _uploadPhaseDocument(
      Project project, ProjectMilestone phase) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;
    try {
      await CrmApi.instance.uploadProjectMilestoneDocument(
        project.id,
        phase.id,
        file,
      );
      _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _deletePhaseDocument(
    Project project,
    ProjectMilestone phase,
    String documentId,
  ) async {
    try {
      await CrmApi.instance.deleteProjectMilestoneDocument(
        project.id,
        phase.id,
        documentId,
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProjectSummary>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: ApiLoading(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: ApiErrorView(error: snapshot.error, onRetry: _reload),
          );
        }
        final summary = snapshot.data!;
        final project = summary.project;
        final progressColor = project.status == 'Completed'
            ? AppColors.success
            : project.status == 'At Risk'
                ? AppColors.error
                : AppColors.primary;
        final canManageProject = !CrmApi.instance.isClientUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (canManageProject)
                    IconButton(
                      tooltip: 'Delete project',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () => _deleteProject(project),
                    ),
                  if (canManageProject)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.primary,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') _showEditProjectSheet(project);
                        if (value == 'team') _showAddTeamSheet(project);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit project'),
                        ),
                        PopupMenuItem(
                          value: 'team',
                          child: Text('Add team member'),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _reload,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 66),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.folder_rounded,
                                color: progressColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.slate800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    project.client,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.slate400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            CrmBadge(project.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: project.progress / 100,
                                backgroundColor: AppColors.slate100,
                                valueColor: AlwaysStoppedAnimation(
                                  progressColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${project.progress}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.slate500,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                _ProjectOverview(
                  project: project,
                  onAddPhase: canManageProject
                      ? () => _showAddPhaseSheet(project)
                      : null,
                  onPhaseStatusChanged: (phase, status) =>
                      _updatePhaseStatus(project, phase, status),
                  onUploadPhaseDocument: canManageProject
                      ? (phase) => _uploadPhaseDocument(project, phase)
                      : null,
                  onDeletePhaseDocument: canManageProject
                      ? (phase, documentId) =>
                          _deletePhaseDocument(project, phase, documentId)
                      : null,
                ),
                _ProjectTasks(tasks: summary.tasks),
                _ProjectTeam(
                  project: project,
                  tasks: summary.tasks,
                  onAddMember: () => _showAddTeamSheet(project),
                ),
                _ProjectUpdates(project: project),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EditProjectSheet extends StatefulWidget {
  final Project project;

  const _EditProjectSheet({required this.project});

  @override
  State<_EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends State<_EditProjectSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _ownerEmailCtrl;
  late final TextEditingController _ownerPhoneCtrl;
  late final TextEditingController _ownerDesignationCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _dueCtrl;
  late final TextEditingController _descriptionCtrl;
  late String _status;
  late double _progress;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameCtrl = TextEditingController(text: project.name);
    _ownerCtrl = TextEditingController(text: project.owner);
    _ownerEmailCtrl = TextEditingController(text: project.ownerEmail);
    _ownerPhoneCtrl = TextEditingController(text: project.ownerPhone);
    _ownerDesignationCtrl = TextEditingController(
      text: project.ownerDesignation,
    );
    _startCtrl = TextEditingController(
      text: project.startDate == 'Not set' ? '' : project.startDate,
    );
    _dueCtrl = TextEditingController(
      text: project.dueDate == 'Not set' ? '' : project.dueDate,
    );
    _descriptionCtrl = TextEditingController(text: project.description);
    _status = project.status;
    _progress = project.progress.toDouble();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _ownerDesignationCtrl.dispose();
    _startCtrl.dispose();
    _dueCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _ownerCtrl.text.trim().isEmpty ||
        _ownerEmailCtrl.text.trim().isEmpty ||
        _ownerPhoneCtrl.text.trim().isEmpty ||
        _ownerDesignationCtrl.text.trim().isEmpty ||
        _startCtrl.text.trim().isEmpty ||
        _dueCtrl.text.trim().isEmpty) {
      setState(
        () => _error =
            'Project name, owner details, start date, and due date are required.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final project = widget.project;
    try {
      await CrmApi.instance.updateProject(project.id, {
        'name': _nameCtrl.text.trim(),
        'client': project.client,
        'clientId': project.clientId,
        'owner': _ownerCtrl.text.trim(),
        'ownerId': project.ownerId,
        'ownerEmail': _ownerEmailCtrl.text.trim(),
        'ownerPhone': _ownerPhoneCtrl.text.trim(),
        'ownerDesignation': _ownerDesignationCtrl.text.trim(),
        'status': _status,
        'progress': _progress.round(),
        'startDate': _startCtrl.text.trim(),
        'dueDate': _dueCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
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
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Edit Project',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerCtrl,
              decoration: const InputDecoration(labelText: 'Owner'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ownerEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Owner Email'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ownerPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Owner Phone'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerDesignationCtrl,
              decoration: const InputDecoration(labelText: 'Owner Designation'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: [
                'Active',
                'At Risk',
                'On Hold',
                'Completed',
              ].contains(_status)
                  ? _status
                  : 'Active',
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Active', 'At Risk', 'On Hold', 'Completed']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            Text(
              'Progress: ${_progress.round()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
            Slider(
              value: _progress,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) => setState(() => _progress = value),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startCtrl,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dueCtrl,
                    decoration: const InputDecoration(labelText: 'Due Date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
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
                  : const Text('Save Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectPhaseSheet extends StatefulWidget {
  final Project project;
  final List<String> phases;

  const _ProjectPhaseSheet({required this.project, required this.phases});

  @override
  State<_ProjectPhaseSheet> createState() => _ProjectPhaseSheetState();
}

class _ProjectPhaseSheetState extends State<_ProjectPhaseSheet> {
  late String _phase;
  late String _status;
  final _ownerCtrl = TextEditingController();
  final _dueCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phase = widget.phases.first;
    _status = 'Pending';
    _ownerCtrl.text = widget.project.owner;
  }

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _dueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.addProjectMilestone(widget.project.id, {
        'name': _phase,
        'status': _status,
        'owner': _ownerCtrl.text.trim(),
        'dueDate': _dueCtrl.text.trim(),
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
      initialChildSize: 0.62,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Add Delivery Phase',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _phase,
              decoration: const InputDecoration(labelText: 'Phase'),
              items: widget.phases
                  .map(
                    (phase) =>
                        DropdownMenuItem(value: phase, child: Text(phase)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _phase = value ?? _phase),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Pending', 'In Progress', 'Completed']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerCtrl,
              decoration: const InputDecoration(labelText: 'Owner'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dueCtrl,
              decoration: const InputDecoration(labelText: 'Due Date'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Add Phase'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTeamSheet extends StatefulWidget {
  final Project project;

  const _ProjectTeamSheet({required this.project});

  @override
  State<_ProjectTeamSheet> createState() => _ProjectTeamSheetState();
}

class _ProjectTeamSheetState extends State<_ProjectTeamSheet> {
  final _memberCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _memberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_memberCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Team member name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.addProjectTeamMember(
        widget.project.id,
        _memberCtrl.text.trim(),
      );
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
      initialChildSize: 0.42,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Add Team Member',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _memberCtrl,
              decoration: const InputDecoration(labelText: 'Member Name'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}

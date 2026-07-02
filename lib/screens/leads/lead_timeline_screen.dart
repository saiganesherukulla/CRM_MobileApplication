import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/app_shell.dart';

class LeadTimelineScreen extends StatefulWidget {
  final String leadId;

  const LeadTimelineScreen({super.key, required this.leadId});

  @override
  State<LeadTimelineScreen> createState() => _LeadTimelineScreenState();
}

class _LeadTimelineScreenState extends State<LeadTimelineScreen> {
  static const _statuses = [
    'New',
    'Contacted',
    'Qualified',
    'Converted',
    'Lost'
  ];

  late Future<Lead> _future;
  final _notesCtrl = TextEditingController();
  String _status = 'New';
  PlatformFile? _file;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<Lead> _load() async {
    final lead = await CrmApi.instance.lead(widget.leadId);
    _status = _statuses.contains(lead.status) ? lead.status : 'New';
    final latest = _latestEntryFor(lead, _status);
    _notesCtrl.text = latest?.notes ?? lead.notes;
    return lead;
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'png',
        'jpg',
        'jpeg'
      ],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _file = result.files.first);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.addLeadTimeline(
        widget.leadId,
        status: _status,
        notes: _notesCtrl.text.trim(),
      );
      if (_file != null) {
        await CrmApi.instance.uploadLeadTimelineDocument(
          widget.leadId,
          _status,
          _file!,
        );
      }
      _file = null;
      _reload();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Lead Timeline'),
      body: FutureBuilder<Lead>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final lead = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  title: lead.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${lead.contactName.isEmpty ? 'No contact' : lead.contactName} - ${lead.contactEmail}',
                              style: const TextStyle(color: AppColors.slate500),
                            ),
                          ),
                          CrmBadge(lead.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: _statuses
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _status = value;
                            _notesCtrl.text =
                                _latestEntryFor(lead, value)?.notes ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesCtrl,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Timeline Note',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: Text(
                            _file == null ? 'Attach Document' : _file!.name),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_saving ? 'Saving...' : 'Save Timeline'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (lead.timeline.isEmpty)
                  const ApiEmpty('No timeline history yet.')
                else
                  ...lead.timeline.reversed
                      .map((entry) => _TimelineEntryCard(entry)),
              ],
            ),
          );
        },
      ),
    );
  }

  LeadTimelineEntry? _latestEntryFor(Lead lead, String status) {
    final target = status.toLowerCase();
    for (final entry in lead.timeline.reversed) {
      if (entry.status.toLowerCase() == target) return entry;
    }
    return null;
  }
}

class _TimelineEntryCard extends StatelessWidget {
  final LeadTimelineEntry entry;

  const _TimelineEntryCard(this.entry);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CrmBadge(entry.status),
              const Spacer(),
              Text(
                entry.timestamp,
                style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.notes.isEmpty ? 'No notes added.' : entry.notes,
            style: const TextStyle(color: AppColors.slate700),
          ),
          const SizedBox(height: 6),
          Text(
            'By ${entry.author}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate400),
          ),
          if (entry.documents.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.documents
                  .map(
                    (doc) => Chip(
                      avatar: const Icon(Icons.description_outlined, size: 16),
                      label: Text(doc.fileName),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

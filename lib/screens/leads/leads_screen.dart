import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/layout/app_shell.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late Future<_LeadData> _future;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<_LeadData> _loadData() async {
    final leads = await CrmApi.instance.leads();
    var clients = const <Client>[];
    try {
      clients = await CrmApi.instance.clients();
    } catch (_) {
      clients = const <Client>[];
    }
    return _LeadData(leads: leads, clients: clients);
  }

  void _reload() => setState(() => _future = _loadData());

  Future<void> _showLeadSheet([Lead? lead]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeadSheet(lead: lead),
    );
    if (changed == true) _reload();
  }

  Future<void> _showLeadDetails(
    Lead lead,
    Set<String> liveClientIds,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeadDetailsSheet(
        lead: lead,
        hasLiveClient: lead.status == 'Converted' &&
            lead.convertedClientId.isNotEmpty &&
            liveClientIds.contains(lead.convertedClientId),
        onEdit: () async {
          Navigator.pop(context);
          await _showLeadSheet(lead);
        },
        onDelete: () async {
          Navigator.pop(context);
          await _delete(lead);
        },
        onEmail: () {
          Navigator.pop(context);
          _showLeadEmailSheet(lead);
        },
        onPrimary: () {
          Navigator.pop(context);
          if (lead.status == 'Converted' &&
              lead.convertedClientId.isNotEmpty &&
              liveClientIds.contains(lead.convertedClientId)) {
            context.go('/clients/${lead.convertedClientId}');
          } else {
            context.go('/clients?leadId=${lead.id}');
          }
        },
      ),
    );
  }

  Future<void> _showLeadEmailSheet(Lead lead) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeadEmailSheet(lead: lead),
    );
  }

  Future<void> _delete(Lead lead) async {
    try {
      await CrmApi.instance.deleteLead(lead.id);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Leads',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showLeadSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                hintText:
                    'Search leads by company, contact, email, or phone...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<_LeadData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final data = snapshot.data ?? _LeadData.empty();
                final liveClientIds =
                    data.clients.map((client) => client.id).toSet();
                final query = _search.toLowerCase();
                final leads = data.leads.where((lead) {
                  final text =
                      '${lead.name} ${lead.industry} ${lead.country} ${lead.contactName} ${lead.contactEmail} ${lead.contactPhone}'
                          .toLowerCase();
                  return text.contains(query);
                }).toList();
                if (leads.isEmpty) return const ApiEmpty('No leads found.');
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(AppColors.slate50),
                          columnSpacing: 22,
                          dataRowMinHeight: 68,
                          dataRowMaxHeight: 86,
                          columns: const [
                            DataColumn(label: Text('Company')),
                            DataColumn(label: Text('Industry')),
                            DataColumn(label: Text('Country')),
                            DataColumn(label: Text('Website')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Contact Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: leads.map((lead) {
                            final hasLiveClient = lead.status == 'Converted' &&
                                lead.convertedClientId.isNotEmpty &&
                                liveClientIds.contains(lead.convertedClientId);
                            return DataRow(
                              cells: [
                                DataCell(_cell(lead.name,
                                    width: 180, subtitle: lead.id)),
                                DataCell(_cell(lead.industry)),
                                DataCell(_cell(lead.country)),
                                DataCell(_cell(lead.website, width: 190)),
                                DataCell(CrmBadge(lead.status)),
                                DataCell(_cell(lead.contactName)),
                                DataCell(_cell(lead.contactEmail, width: 210)),
                                DataCell(_cell(lead.contactPhone)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _showLeadDetails(
                                            lead, liveClientIds),
                                        icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 16),
                                        label: const Text('View'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: lead.contactEmail.isEmpty
                                            ? null
                                            : () => _showLeadEmailSheet(lead),
                                        icon: const Icon(Icons.mail_outline,
                                            size: 16),
                                        label: const Text('Email'),
                                      ),
                                      const SizedBox(width: 8),
                                      if (hasLiveClient)
                                        TextButton(
                                          onPressed: () => context.go(
                                              '/clients/${lead.convertedClientId}'),
                                          child: const Text('Client'),
                                        )
                                      else
                                        ElevatedButton.icon(
                                          onPressed: () => context
                                              .go('/clients?leadId=${lead.id}'),
                                          icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16),
                                          label: const Text('Convert'),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String value, {double width = 140, String? subtitle}) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            display,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: display == '-' ? AppColors.slate400 : AppColors.slate700,
              fontWeight: subtitle == null ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
          if (subtitle != null && subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadDetailsSheet extends StatelessWidget {
  final Lead lead;
  final bool hasLiveClient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onEmail;
  final VoidCallback onPrimary;

  const _LeadDetailsSheet({
    required this.lead,
    required this.hasLiveClient,
    required this.onEdit,
    required this.onDelete,
    required this.onEmail,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      maxChildSize: 0.96,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lead.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate800,
                    ),
                  ),
                ),
                CrmBadge(lead.status),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _detail('Lead ID', lead.id),
                _detail('Company Name', lead.name),
                _detail('Industry', lead.industry),
                _detail('Country', lead.country),
                _detail('Website', lead.website),
                _detail('Status', lead.status),
                _detail('Contact Name', lead.contactName),
                _detail('Contact Email', lead.contactEmail),
                _detail('Contact Phone', lead.contactPhone),
                _detail('Designation', lead.contactDesignation),
                _detail('Lead Owner', lead.owner),
                _detail(
                  'Converted Client',
                  lead.convertedClientId.isEmpty
                      ? 'Not converted'
                      : lead.convertedClientId,
                ),
                _detail('Created', _formatLeadDate(lead.createdAt)),
                _detail('Updated', _formatLeadDate(lead.updatedAt)),
                _detail('Notes', lead.notes, wide: true),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: lead.contactEmail.isEmpty ? null : onEmail,
                  icon: const Icon(Icons.mail_outline, size: 16),
                  label: const Text('Email'),
                ),
                ElevatedButton.icon(
                  onPressed: onPrimary,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(hasLiveClient ? 'View Client' : 'Convert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value, {bool wide = false}) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return SizedBox(
      width: wide ? 360 : 170,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                display,
                maxLines: wide ? 6 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      display == '-' ? AppColors.slate400 : AppColors.slate700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadEmailSheet extends StatefulWidget {
  final Lead lead;

  const _LeadEmailSheet({required this.lead});

  @override
  State<_LeadEmailSheet> createState() => _LeadEmailSheetState();
}

class _LeadEmailSheetState extends State<_LeadEmailSheet> {
  late final TextEditingController _toCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _bodyCtrl;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _toCtrl = TextEditingController(text: widget.lead.contactEmail);
    _subjectCtrl = TextEditingController(text: 'Regarding ${widget.lead.name}');
    _bodyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_toCtrl.text.trim().isEmpty || _subjectCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Recipient and subject are required.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final user = CrmApi.instance.currentUser;
      await CrmApi.instance.sendEmail({
        'to': _toCtrl.text.trim(),
        'from': user?.name ?? 'CRM User',
        'fromEmail': user?.email ?? '',
        'client': widget.lead.name,
        'subject': _subjectCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.94,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Email Lead',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toCtrl,
              decoration: const InputDecoration(labelText: 'To'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write your message here...',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(_sending ? 'Sending...' : 'Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatLeadDate(String value) {
  if (value.trim().isEmpty) return '-';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year}';
}

class _LeadData {
  final List<Lead> leads;
  final List<Client> clients;

  const _LeadData({
    required this.leads,
    required this.clients,
  });

  factory _LeadData.empty() =>
      const _LeadData(leads: <Lead>[], clients: <Client>[]);
}

class _LeadSheet extends StatefulWidget {
  final Lead? lead;

  const _LeadSheet({this.lead});

  @override
  State<_LeadSheet> createState() => _LeadSheetState();
}

class _LeadSheetState extends State<_LeadSheet> {
  late final TextEditingController _name;
  late final TextEditingController _industry;
  late final TextEditingController _country;
  late final TextEditingController _website;
  late final TextEditingController _owner;
  late final TextEditingController _contactName;
  late final TextEditingController _contactEmail;
  late final TextEditingController _contactPhone;
  late final TextEditingController _designation;
  late final TextEditingController _notes;
  late String _status;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    _name = TextEditingController(text: lead?.name);
    _industry = TextEditingController(text: lead?.industry);
    _country = TextEditingController(text: lead?.country);
    _website = TextEditingController(text: lead?.website);
    _owner = TextEditingController(text: lead?.owner);
    _contactName = TextEditingController(text: lead?.contactName);
    _contactEmail = TextEditingController(text: lead?.contactEmail);
    _contactPhone = TextEditingController(text: lead?.contactPhone);
    _designation = TextEditingController(text: lead?.contactDesignation);
    _notes = TextEditingController(text: lead?.notes);
    _status = lead?.status ?? 'New';
  }

  @override
  void dispose() {
    for (final ctrl in [
      _name,
      _industry,
      _country,
      _website,
      _owner,
      _contactName,
      _contactEmail,
      _contactPhone,
      _designation,
      _notes,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Company name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final payload = {
      'name': _name.text.trim(),
      'industry': _industry.text.trim(),
      'country': _country.text.trim(),
      'website': _website.text.trim(),
      'owner': _owner.text.trim(),
      'status': _status,
      'contactName': _contactName.text.trim(),
      'contactEmail': _contactEmail.text.trim(),
      'contactPhone': _contactPhone.text.trim(),
      'contactDesignation': _designation.text.trim(),
      'notes': _notes.text.trim(),
    };
    try {
      if (widget.lead == null) {
        await CrmApi.instance.createLead(payload);
      } else {
        await CrmApi.instance.updateLead(widget.lead!.id, payload);
      }
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
      initialChildSize: 0.9,
      maxChildSize: 0.96,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.lead == null ? 'Add New Lead' : 'Edit Lead',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 16),
            _field(_name, 'Company Name'),
            _field(_industry, 'Industry'),
            _field(_country, 'Country'),
            _field(_website, 'Website'),
            _field(_owner, 'Lead Owner'),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['New', 'Contacted', 'Qualified', 'Converted', 'Lost']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            _field(_contactName, 'Contact Name'),
            _field(_contactEmail, 'Contact Email'),
            _field(_contactPhone, 'Contact Phone'),
            _field(_designation, 'Contact Designation'),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Lead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

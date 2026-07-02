part of 'client_detail_screen.dart';

class _Timeline extends StatelessWidget {
  final ClientSummary summary;

  const _Timeline({required this.summary});

  @override
  Widget build(BuildContext context) {
    final entries = _timelineEntries(summary);
    if (entries.isEmpty) {
      return const ApiEmpty('No timeline activity is available yet.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _TimelineCard(entry: entries[index]),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final _TimelineEntry entry;

  const _TimelineCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(entry.icon, size: 19, color: entry.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    if (entry.badge.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      CrmBadge(entry.badge),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  entry.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.slate500,
                  ),
                ),
                if (entry.when.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.slate400,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.when,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final String title;
  final String subtitle;
  final String when;
  final String badge;
  final IconData icon;
  final Color color;

  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.when,
    required this.badge,
    required this.icon,
    required this.color,
  });
}

List<_TimelineEntry> _timelineEntries(ClientSummary summary) {
  final client = summary.client;
  final entries = <_TimelineEntry>[
    _TimelineEntry(
      title: '${client.name} profile is ${client.status.toLowerCase()}',
      subtitle:
          'Account owner: ${client.owner}. ${client.notes.isEmpty ? client.activity : client.notes}',
      when: client.activity,
      badge: client.status,
      icon: Icons.business_rounded,
      color: statusColor(client.status),
    ),
  ];

  for (final contact in summary.contacts) {
    entries.add(
      _TimelineEntry(
        title: contact.primary
            ? 'Primary contact assigned'
            : 'Contact added to account',
        subtitle:
            '${contact.name} - ${contact.designation}${contact.email.isEmpty ? '' : ' - ${contact.email}'}',
        when: 'Contact',
        badge: contact.primary ? 'Primary' : '',
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.info,
      ),
    );
  }

  for (final project in summary.projects) {
    entries.add(
      _TimelineEntry(
        title: 'Project updated: ${project.name}',
        subtitle:
            '${project.progress}% complete. Owner: ${project.owner}. Due ${project.dueDate}.',
        when: project.dueDate,
        badge: project.status,
        icon: Icons.folder_rounded,
        color: statusColor(project.status),
      ),
    );
  }

  for (final task in summary.tasks) {
    entries.add(
      _TimelineEntry(
        title: 'Task scheduled: ${task.title}',
        subtitle:
            '${task.assignee} owns this ${task.priority.toLowerCase()} priority task.',
        when: task.due,
        badge: task.status,
        icon: Icons.check_box_rounded,
        color: priorityColor(task.priority),
      ),
    );
  }

  for (final email in summary.emails) {
    entries.add(
      _TimelineEntry(
        title: email.subject,
        subtitle:
            '${email.direction == 'inbound' ? 'Received from' : 'Sent by'} ${email.from}. ${email.preview}',
        when: email.time,
        badge: email.status,
        icon: Icons.mail_rounded,
        color: email.unread ? AppColors.primary : AppColors.slate400,
      ),
    );
  }

  for (final ticket in summary.tickets) {
    entries.add(
      _TimelineEntry(
        title: 'Ticket ${ticket.ticketNumber}: ${ticket.title}',
        subtitle:
            '${ticket.category} issue assigned to ${ticket.assignee}. SLA: ${ticket.sla}.',
        when: ticket.updated,
        badge: ticket.status,
        icon: Icons.confirmation_number_rounded,
        color: priorityColor(ticket.priority),
      ),
    );
  }

  entries.sort((a, b) => _timelineWeight(b).compareTo(_timelineWeight(a)));
  return entries;
}

int _timelineWeight(_TimelineEntry entry) {
  final parsed = DateTime.tryParse(entry.when);
  if (parsed == null) return 0;
  return parsed.millisecondsSinceEpoch;
}

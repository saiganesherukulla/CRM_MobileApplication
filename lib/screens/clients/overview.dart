part of 'client_detail_screen.dart';

class _Overview extends StatelessWidget {
  final ClientSummary summary;

  const _Overview({required this.summary});

  @override
  Widget build(BuildContext context) {
    final client = summary.client;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _QuickStat(
                'Contacts', summary.contacts.length.toString(), AppColors.info),
            const SizedBox(width: 10),
            _QuickStat(
                'Tasks', summary.tasks.length.toString(), AppColors.primary),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuickStat('Projects', summary.projects.length.toString(),
                AppColors.success),
            const SizedBox(width: 10),
            _QuickStat(
                'Tickets',
                summary.tickets
                    .where((ticket) => ticket.status != 'Resolved')
                    .length
                    .toString(),
                AppColors.warning),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Company Information',
          child: Column(
            children: [
              _InfoRow(Icons.business_outlined, 'Industry', client.industry),
              _InfoRow(Icons.location_on_outlined, 'Location', client.country),
              _InfoRow(Icons.public_rounded, 'Website',
                  client.website.isEmpty ? 'Not added' : client.website),
              _InfoRow(
                  Icons.access_time_rounded, 'Last Activity', client.activity),
              _InfoRow(
                  Icons.person_outline_rounded, 'Account Owner', client.owner),
              _InfoRow(
                  Icons.confirmation_number_outlined,
                  'Open Tickets',
                  summary.tickets
                      .where((ticket) => ticket.status != 'Resolved')
                      .length
                      .toString()),
            ],
          ),
        ),
      ],
    );
  }
}

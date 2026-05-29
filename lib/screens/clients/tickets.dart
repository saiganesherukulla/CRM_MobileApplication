part of 'client_detail_screen.dart';

class _Tickets extends StatelessWidget {
  final List<Ticket> tickets;

  const _Tickets({required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const ApiEmpty('No tickets for this client.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final ticket = tickets[index];
        return _CompactRow(
          leadingColor: priorityColor(ticket.priority),
          title: ticket.title,
          subtitle: '${ticket.ticketNumber} - SLA ${ticket.sla}',
          badge: ticket.status,
        );
      },
    );
  }
}

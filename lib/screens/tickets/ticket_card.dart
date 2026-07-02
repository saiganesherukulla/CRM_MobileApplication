part of 'tickets_screen.dart';

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  Color get _slaColor {
    if (ticket.sla == 'Breached') return AppColors.error;
    if (ticket.sla == 'At Risk') return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ticket.ticketNumber,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate400)),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _slaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: _slaColor.withOpacity(0.3))),
                      child: Text('SLA: ${ticket.sla}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _slaColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket.title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      CrmBadge(ticket.priority),
                      CrmBadge(ticket.status)
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CrmAvatar(_initials(ticket.assignee), size: AvatarSize.xs),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(ticket.assignee,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 12, color: AppColors.slate400),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(ticket.client,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.slate400),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(ticket.created,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
